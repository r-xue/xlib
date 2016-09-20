FUNCTION HTAU_GRID_MKLINE, MODEL, linear=linear, decompose=decompose,obs_wl=obs_wl
;+
; NAME:
;   H2TAU_GRID_MKLINE
;
; PURPOSE:
;   calculate a synthetic UV spectrum using H2tau/HItau templates
;
; INPUTS:
;   MODEL   --  IDL strcuture including absorber model details for calculating the spectrum
;           .state      absorber id.
;           .n          absorber column density
;           .b          absorber b-value
;           .v          absorber velocity
;           .base_wave  wavelength grid for extra "tau" not included in the absorber model
;           .base_tau   extra "tau"
;
; OUTPUTS:
;   SPEC    --  IDL strcuture including the synthetic UV spectrum
;           .wl          spectrum wavelength grid
;           .fl          spectrum flux
;
; KEYWORDS:
;   decompose   --  absorber decomposition in the output
;   linear      --  the column density values are treated in a linear scale rather than log
;
; HISTORY:
;
;   20120810  RX    introduced
;   20130115  RX    speed up using matrix_multiply and save memory usage
;   20130328  RX    structure as input
;   20130329  RX    workaround the IDL structure acess bug and speedup the calculation
;                   by a factor of ~20
;   20140210  RX    switch to new templates including HD/DI
;   20140910  RX    map data into the struture (v8.2.2 will still have the structure overhead bug)
;   20150212  RX    speed up without interpolating 
;-

COMMON htau,htau_data,htau_grid

htau_grid_state_arr=htau_grid.state.toarray()
htau_grid_doppb_arr=htau_grid.doppb.toarray()

cspeed=2.998e5

; SET WAVERLENGTH GRID IN THE OBS FRFAME

state=model.state
vb=string(model.v)
vb_uniq=vb[rem_dup(vb)]
dopb=model.b[rem_dup(model.b)]
if  min(dopb) le 2.0 then wave_samp=[1e-6,900.,120000]
if  min(dopb) gt 2.0 then wave_samp=[3e-6,900*10.^(1e-6),40000]

dlogwv=wave_samp[0]
wave=wave_samp[1]*10.^(dindgen(wave_samp[2])*wave_samp[0])

obs_tau=double(wave)*0.0
if keyword_set(decompose) then obs_tau_dc=fltarr(n_elements(wave),n_elements(model.state))

for i=0,n_elements(vb_uniq)-1 do begin
        
    tag_uniq=where(vb eq vb_uniq[i])
    rvel=model.v[tag_uniq[0]]
    dopb=model.b[tag_uniq[0]]
    bandtau=double(wave*0.0)
    
    foreach ind,tag_uniq do begin

        n=model.n[ind]
        if not keyword_set(linear) then n=10.d^n
        tag_state=where(htau_grid_state_arr eq model.state[ind])
        blist=htau_grid_doppb_arr[tag_state]
        tag_near=(sort(abs(blist-model.b[ind]))) & tag_near=tag_near[[0,1]] & tag_near=tag_state[tag_near]
        blist=htau_grid_doppb_arr[tag_near]
        nwt=n
        wave_samp=htau_grid.wave[tag_near[0]]
        nbin0=round(wave_samp[0]/dlogwv)
        if  nbin0 gt 1 then begin
            test1=(nwt[0]/htau_grid.nn[tag_near[0]])*htau_grid.tau[tag_near[0]]
            test1=rebin(test1,n_elements(test1)*nbin0,/sample)
        endif else begin
            test1=(nwt[0]/htau_grid.nn[tag_near[0]])*htau_grid.tau[tag_near[0]]
        endelse
        bandtau[0]=bandtau+test1
        
    endforeach

    wvshift=round(alog10(cspeed/(cspeed-rvel))/dlogwv)
    tmp=shift(bandtau,wvshift)
    if  wvshift gt 0 then begin
        tmp[0:wvshift]=0.0
    endif
    if  wvshift lt 0 then begin
        tmp[wvshift:-1]=0.0
    endif
    obs_tau=obs_tau+tmp
    if  keyword_set(decompose) then obs_tau_dc[*,i]=tmp
    
endfor

;
if  keyword_set(obs_wl) then begin
    linterp,wave,obs_tau,obs_wl,tmp
    obst_tau=tmp
endif else begin
    obs_wl=wave
endelse

if  TAG_EXIST(model,'base_wave') then begin
    linterp,model.base_wave,model.base_tau,obs_wl,tmp
    ;tmp=rebinw(model.base_wave,model.base_tau,obs_wl)
    obs_tau=obs_tau+tmp
endif

obs_model=1d*exp(-double(obs_tau))
if  check_math(0,0) eq 32 then junk = check_math(1,1)
spec=CREATE_STRUCT(model,'wl',obs_wl,'fl',obs_model)
if  keyword_set(decompose) then begin
    obs_model_dc=1.0*exp(-obs_tau_dc)
    spec=CREATE_STRUCT(spec,'fldc',obs_model_dc)
endif


return,spec

END

FUNCTION HTAU_GRID_MKLINE_OLD, MODEL, linear=linear, decompose=decompose,obs_wl=obs_wl
;+
; NAME:
;   H2TAU_GRID_MKLINE (this is a retired version not using structure)
;
; PURPOSE:
;   calculate a synthetic UV spectrum using H2tau/HItau templates
;
; INPUTS:
;   MODEL   --  IDL strcuture including absorber model details for calculating the spectrum
;           .state      absorber id.
;           .n          absorber column density
;           .b          absorber b-value
;           .v          absorber velocity
;           .base_wave  wavelength grid for extra "tau" not included in the absorber model
;           .base_tau   extra "tau" 
;   
; OUTPUTS:
;   SPEC    --  IDL strcuture including the synthetic UV spectrum 
;           .wl          spectrum wavelength grid
;           .fl          spectrum flux
;           
; KEYWORDS:
;   decompose   --  absorber decomposition in the output
;   linear      --  the column density values are treated in a linear scale rather than log
; 
; HISTORY:
;
;   20120810  RX    introduced
;   20130115  RX    speed up using matrix_multiply and save memory usage 
;   20130328  RX    structure as input
;   20130329  RX    workaround the IDL structure acess bug and speedup the calculation
;                   by a factor of ~20
;   20140210  RX    switch to new templates including HD/DI
;-

; LOAD TEMPLATES from memory
COMMON htau_templates,$
    htau_grid_wave,$
    htau_grid_tau,$
    htau_grid_state,$
    htau_grid_nn,$
    htau_grid_doppb
;   htau_grid.wave     template wavelength grid
;   htau_grid.tau      templates (n_wave x n_state)
;   htau_grid.state    template state grid
;   htau_grid.nn       template fiducial column density grid
;   htau_grid.doppb    template b-value grid
COMMON htau,htau_data,htau_grid

;save,filename='test.dat',model
htau_grid_state_arr=htau_grid_state.toarray()
htau_grid_doppb_arr=htau_grid_doppb.toarray()

cspeed=2.998e5

; SET WAVERLENGTH GRID IN THE OBS FRFAME

state=model.state
vb=string(model.v)
vb_uniq=vb[UNIQ(vb, SORT(vb))]

dwl=0.0025
if  not keyword_set(obs_wl) then begin
    obs_wl=900+findgen(ceil((1200.-900.)/dwl))*dwl
endif

obs_tau=double(obs_wl)*0.0

if keyword_set(decompose) then obs_tau_dc=fltarr(n_elements(obs_wl),n_elements(model.state))
for i=0,n_elements(vb_uniq)-1 do begin

    tag_uniq=where(vb eq vb_uniq[i])
    rvel=model.v[tag_uniq[0]]
    dopb=model.b[tag_uniq[0]]
    bandtau=double(obs_wl*0.0)
    foreach ind,tag_uniq do begin
        
        n=model.n[ind]
        if not keyword_set(linear) then n=10.d^n

;        tag_state=where(htau_grid_state_arr eq model.state[ind])
;        blist=htau_grid_doppb_arr[tag_state]
;        
;        tag_near=(sort(abs(blist-model.b[ind]))) & tag_near=tag_near[[0,1]] & tag_near=tag_state[tag_near]
;        blist=htau_grid_doppb_arr[tag_near]
;        nwt=[blist[1]-model.b[ind],model.b[ind]-blist[0]]/(blist[1]-blist[0])*n
;        
;        wave_samp=htau_grid_wave[tag_near[0]]
;        nbin0=ceil(wave_samp[2]/dwl)
;        wave_samp=htau_grid_wave[tag_near[1]]
;        nbin1=ceil(wave_samp[2]/dwl)
;        if  model.state[ind] eq "H I,1,*,*,*,*,*" then begin
;            nwt=[0.0,total(nwt)]
;        endif
;        if nbin0 gt 1 then begin
;            test1=(nwt[0]/htau_grid_nn[tag_near[0]])*htau_grid_tau[tag_near[0]]
;            test1=rebin(test1,n_elements(test1)*nbin0,/sample)
;        endif else begin
;            test1=(nwt[0]/htau_grid_nn[tag_near[0]])*htau_grid_tau[tag_near[0]]
;        endelse    
;        if nbin1 gt 1 then begin
;            test2=(nwt[1]/htau_grid_nn[tag_near[1]])*htau_grid_tau[tag_near[1]]
;            test2=rebin(test2,n_elements(test2)*nbin1,/sample)
;        endif else begin
;            test2=(nwt[1]/htau_grid_nn[tag_near[1]])*htau_grid_tau[tag_near[1]]
;        endelse
;        bandtau[0]=bandtau $
;            +test1 $
;            +test2


        tag_state=where(htau_grid_state_arr eq model.state[ind])
        blist=htau_grid_doppb_arr[tag_state]

        tag_near=(sort(abs(blist-model.b[ind]))) & tag_near=tag_near[[0,1]] & tag_near=tag_state[tag_near]
        blist=htau_grid_doppb_arr[tag_near]
        
        nwt=n

        wave_samp=htau_grid_wave[tag_near[0]]
        nbin0=ceil(wave_samp[2]/dwl)
        
 
        if nbin0 gt 1 then begin
            test1=(nwt[0]/htau_grid_nn[tag_near[0]])*htau_grid_tau[tag_near[0]]
            test1=rebin(test1,n_elements(test1)*nbin0,/sample)
        endif else begin
            test1=(nwt[0]/htau_grid_nn[tag_near[0]])*htau_grid_tau[tag_near[0]]
        endelse
        bandtau[0]=bandtau $
            +test1      
            
    endforeach

    wave=obs_wl
    wl=cspeed/(cspeed-rvel)*wave
    linterp,wl,bandtau,obs_wl,tmp
    ;tmp=rebinw(wl,bandtau,obs_wl)
    ;tmp=((cspeed-rvel)/cspeed)*interpol(bandtau,wl,obs_wl)
    obs_tau=obs_tau+tmp
    if  keyword_set(decompose) then obs_tau_dc[*,i]=tmp
    
endfor

if  TAG_EXIST(model,'base_wave') then begin
    linterp,model.base_wave,model.base_tau,obs_wl,tmp
    ;tmp=rebinw(model.base_wave,model.base_tau,obs_wl)
    obs_tau=obs_tau+tmp
endif

obs_tau=double(obs_tau)
obs_model=1.0*exp(-double(obs_tau))
if  check_math(0,0) eq 32 then junk = check_math(1,1)
spec=CREATE_STRUCT(model,'wl',obs_wl,'fl',obs_model)

if  keyword_set(decompose) then begin 
obs_model_dc=1.0*exp(-obs_tau_dc)
spec=CREATE_STRUCT(spec,'fldc',obs_model_dc)
endif


return,spec

END


PRO TEST_HTAU_GRID_MKLINE

state=[ "H2,X,*,0,*,0,*",$
    "H2,X,*,0,*,1,*",$
    "H2,X,*,0,*,2,*",$
    "H2,X,*,0,*,3,*",$
    "H2,X,*,0,*,4,*",$
    "H2,X,*,0,*,5,*",$
    "H2,X,*,0,*,6,*",$
    "H I,1,*,*,*,*,*"]
state=[state,state]
n1=[1.2730183e+20,   0,   0,   0,   0.0,   0.0,   1.0000000e+12,1.0000000e+21]*1.0
n2=[1.2730183e+17,   0.0,   0.0,  0.0,   0.0,   0.0,   0.0,0.0]
n=[n1,n2]
v1=replicate(-30,8)
v2=replicate(0,8)
v=[v1,v2]
b1=replicate(1.6,8)
b2=replicate(1.2,8)
b=[b1,b2]

;state=state[8]
;n=n[8]
;b=b[8]
;v=v[8]
model2={    name: 'h2test',$
    state:state,$
    n:n,$
    b:b,$
    v:v}

T=SYSTIME(1)
for i=0,0 do begin
spec=htau_grid_mkline(model2,/linear)
endfor

;restore,'test.dat',/v
;spec=htau_grid_mkline(model,/linear)

dwl=0.013*5.0
grid=900.+findgen(ceil((1200.-900.)/dwl))*dwl
x=900.+findgen(ceil((1200.-900.)/dwl))*dwl-dwl/2.0
;T=SYSTIME(1)

print,spec.wl[0]-spec.wl[1]
;PRINT, '>> total time:   ',SYSTIME(1)-T, 'S'
;PRINT, '>> total time:   ',SYSTIME(1)-T, 'S'
;T=SYSTIME(1)

window,1

plot,spec.wl,spec.fl,pos=[0.1,0.1,0.9,0.9],yrange=[-0.2,1.2],ystyle=1,psym=10,xstyle=1;,xrange=[1091.7,1092.5],/nodata



fl=HTAU_SIMOBS(spec.wl,spec.fl,fwhm=20)

oplot,spec.wl,fl,psym=10,color=cgcolor('red')

T=SYSTIME(1)
linterp,spec.wl,fl,grid,y
PRINT, '>> total time:   ',strtrim(SYSTIME(1)-T,2), 'S'
oplot,grid,y,color=cgcolor('white'),psym=10

T=SYSTIME(1)
y=interpol(fl,spec.wl,grid)
PRINT, '>> total time:   ',strtrim(SYSTIME(1)-T,2), 'S'
oplot,grid,y,color=cgcolor('green'),psym=10


T=SYSTIME(1)
y=rebinw(fl,spec.wl,x)
PRINT, '>> total time:   ',strtrim(SYSTIME(1)-T,2), 'S'
oplot,x+dwl/2.0,y,color=cgcolor('red'),psym=10

T=SYSTIME(1)
y=pp_resample(fl,spec.wl,grid)
PRINT, '>> total time:   ',strtrim(SYSTIME(1)-T,2), 'S'
oplot,grid,y,color=cgcolor('blue'),psym=4,symsize=2
T=SYSTIME(1)
y=im_linear_rebin(spec.wl,fl,minwave=min(grid),maxwave=max(grid),$
    dwave=dwl,/conserve)
PRINT, '>> total time:   ',strtrim(SYSTIME(1)-T,2), 'S'

oplot,grid,y,color=cgcolor('blue'),psym=2,symsize=5


htau_plot_hmarker,[0,255],[0,1]

END

; below are old scripts making comparison

PRO TEST_H2TAU_GRID_MKLINE

    h2model={ h_info:[272,22.0,1.4,19.42,19.38,17.75,17.83,15.88,15.36,14.20,0.00,$
        10,22.0, 1.4,18.50,18.50,17.50,17.50,00.00,0.00,0.00,0.00]}
    T=SYSTIME(1)
    h2spec=H2TAU_GRID_MKLINE(h2model)
    PRINT, '>> total time:   ',SYSTIME(1)-T, 'S'
    T=SYSTIME(1)

    window,2
    wl=h2spec.wl
    fl=h2spec.fl
    plot,wl,fl

    ;oplot,h2spec.wl,h2spec.flv[*,2],color=cgcolor('blue')
    ;print,size(h2spec.flv)

END

PRO TEST_LINEAR_H2TAU_GRID_MKLINE

    h2model={ h_info:[ 272,10.^22, 4.8,10.^[19.42,19.38,17.75,17.83,15.88,15.36,14.20,0.00],$
        10, 10.^23, 1.4,10.^[18.50,18.50,17.50,17.50,00.00,0.00,0.00,0.00] ],$
        base_wave:[900.,2000.],$
        base_tau:[0.0,0.0]}
    T=SYSTIME(1)
    h2spec=H2TAU_GRID_MKLINE(h2model,/linear)
    PRINT, '>> total time:   ',SYSTIME(1)-T, 'S'
    T=SYSTIME(1)

    ; PLOT SPECTRUM
    wl=h2spec.wl
    fl=h2spec.fl

    path=ProgramRootDir()
    psfile=path+'../templates/h2tau_grid_mkline_test.eps'
    set_plot,'ps'
    device, file=psfile, /color, bits=8, /cmyk, /encapsulated,$
        ;/land,xsize=11,ysize=8.5,/inches
        xsize=14,ysize=10.0,/inches,xoffset=0.0,yoffset=0.0
    !p.thick=2.0
    !x.thick = 2.0
    !y.thick = 2.0
    !z.thick = 2.0
    !p.charsize=1.0
    !p.charthick=1.0

    loadct,13
    wvlen=50
    wvs=900
    clist=findgen(4)*255/4
    cthin=6-indgen(4)
    !P.MULTI = [0, 1, 8]
    for j=0,7 do begin
        plot, [wvs+j*wvlen,wvs+j*wvlen+wvlen],[0.0,1.1],/nodata,$
            xrange=[wvs+j*wvlen,wvs+j*wvlen+wvlen],$
            yrange=[0.0,1.1],$
            xstyle=1,ystyle=1
        oplot,wl,fl
    endfor
    loadct,0

    device,/close
    set_plot,'x'
    ;
    ;  window,2


    ;oplot,h2spec.wl,h2spec.flv[*,2],color=cgcolor('blue')
    ;print,size(h2spec.flv)

END


