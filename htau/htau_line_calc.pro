FUNCTION htau_line_calc,wave,state,nn,bb,silent=silent
;+
; NAME:
;   H2TAU_LINE_CAL
;
; PURPOSE:
;   calculate optical depth contributed by a species at the specified energe state
;
; INPUTS:
;   wave    -- sampling wavelength
;   state   -- lower energy state(s), e.g.: 
;              "H2,X,*,0,*,1,*":    spec=H2,nl=X,nu=*,nvl=0,nvu=*,njl=1,nju=*
;              "H I,1,*,*,*,*,*" :  spec=HI,nl=1,nu=*,nvl=*,nvu=*,njl=*,nju=*
;   nn      -- fiducial value of species column density at the specified eneger state
;              (in cm^-2) (scaler or vector with the same length of <state>)
;   doppb   -- b-values (scaler or vector with the same length of <state>)
;
; OUTPUTS:
;   bandtau:  with a size of n_wave x n_state
;
; NOTES:
;   although the calculation is parallelized, derving a large
;   < n_wave x n_state > grid can easily consume all physical memory.
;   choose your input values wisely!! n_state = 8 is okay for an 8GB machine.
;
; HISTORY:
;
;   20120810  RX    introduced
;   20120812  RX    vogit profile calculations have been parallelized
;                   using multi-d array.
;   20120813  RX    add some output related to memory usage
;   20130110  RX    use an updated H2 LW line table from McCandliss (2003)
;   20130118  RX    both lrot and doppb can be a vector; verify on neon
;   20130214  RX    nn can be a vector with the same size of lrot
;   20140217  RX    switch to atomic/molecular data from Meudon
;   20150310  RX    major performance improvement
;-

; LOAD LINE DATA
COMMON htau,htau_data,htau_grid
tmp1=memory(/current)
T = SYSTIME(1)

; FIND INTERESTED LINES
tag=[]        ; line index
nn_line=[]    ; fiducial column density for each line
bb_line=[]    ; b value for each line
num_line=[]   ; number of lines from each energy state
n=nn
b=bb
if n_elements(n) ne n_elements(state) then n=replicate(nn,n_elements(state))
if n_elements(b) ne n_elements(state) then b=replicate(bb,n_elements(state))

if  not keyword_set(silent) then print,''
for i=0,n_elements(state)-1 do begin
    s=strsplit(state[i],',',/extract)
    pick=(htau_data.spec eq htau_data.spec)
    if s[0] ne '*' then pick[where(htau_data.spec ne s[0],/null)]=0
    if s[1] ne '*' then pick[where(htau_data.nl ne s[1],/null)]=0
    if s[2] ne '*' then pick[where(htau_data.nu ne s[2],/null)]=0
    if s[3] ne '*' then pick[where(htau_data.nvl ne s[3],/null)]=0
    if s[4] ne '*' then pick[where(htau_data.nvu ne s[4],/null)]=0
    if s[5] ne '*' then pick[where(htau_data.njl ne s[5],/null)]=0
    if s[6] ne '*' then pick[where(htau_data.nju ne s[6],/null)]=0
    tag=[tag,where(pick eq 1,/null,ct)]
    nn_line=[nn_line,replicate(n[i],ct)]
    bb_line=[bb_line,replicate(b[i],ct)]  
    num_line=[num_line,ct]
    if  not keyword_set(silent) then begin
        print,'State/n/b/nline: '+state[i]+' / '+$
            strtrim(n[i],2)+' / '+$
            string(b[i],format='(f0.2)')+' / '+$
            strtrim(ct,2)
    endif
endfor
if  not keyword_set(silent) then print,''


; PREPARE GRID

nwave=n_elements(wave)
ntag=n_elements(tag)
nstate=n_elements(state)

cspeed=2.99792458e18
pi=3.141592653589793
e=4.8032e-10    ;esu
me=1.6726231e-24/1836.        ;grams mass electron
xcoeff=sqrt(pi)*e^2/(me*(cspeed)*1.0e5) ;or 1.497d-15

;wave_grid=fltarr(n_elements(wave),n_elements(tag),/nozero)
;doppb_grid=fltarr(nwave,ntag,/nozero)
;wl_grid=fltarr(nwave,ntag,/nozero)
;Nf_grid=fltarr(nwave,ntag,/nozero)
;gamma_grid=fltarr(nwave,ntag,/nozero)
;for i=0,n_elements(tag)-1 do begin
;    wave_grid[i*nwave]=wave
;    replicate_inplace,doppb_grid,bb_line[i],1,[0,i]
;    replicate_inplace,wl_grid,htau_data[tag[i]].wl,1,[0,i]
;    replicate_inplace,Nf_grid,htau_data[tag[i]].f*nn_line[i],1,[0,i]
;    replicate_inplace,gamma_grid,htau_data[tag[i]].gamma,1,[0,i]
;endfor
;f1=(1./wave_grid-1./wl_grid)*cspeed
;delnud=doppb_grid*1e13/wl_grid
;tau0=xcoeff*Nf_grid*wl_grid/doppb_grid
;a=(1./pi/4.)*gamma_grid/delnud
;u=f1/delnud
;linetau=tau0*voigt(a_grid,u_grid)


a_grid=fltarr(nwave,ntag,/nozero)
u_grid=fltarr(nwave,ntag,/nozero)
tau_grid=fltarr(nwave,ntag,/nozero)
for i=0,n_elements(tag)-1 do begin
    replicate_inplace,a_grid,1./pi/4/(bb_line[i]*1e13/htau_data[tag[i]].wl)*htau_data[tag[i]].gamma,1,[0,i]
    replicate_inplace,tau_grid,xcoeff*htau_data[tag[i]].f*nn_line[i]*htau_data[tag[i]].wl/bb_line[i],1,[0,i]
    u_grid[i*nwave]=cspeed/(bb_line[i]*1e13/htau_data[tag[i]].wl)*(-1./htau_data[tag[i]].wl+1./wave)
endfor
; VOIGT PROFILE CALL

tau_grid=tau_grid*voigt(a_grid,u_grid)
DELVARX,a_grid
DELVARX,u_grid

; SUMMING TAU FOR EACH J LEVLE
bandtau=fltarr(nwave,nstate,/nozero)
first=-1
last=-1
for i=0,n_elements(state)-1 do begin
    first=last+1
    last=first+num_line[i]-1
    bandtau[i*nwave]=total(tau_grid[*,first:last],2)
endfor

if  not keyword_set(silent) then begin
    tmp2=memory(/current)
    print, 'Memory Usage:     ',(tmp2-tmp1)*9.53674316e-7, 'MB'
    print, '>> num of dim:    ',size(bandtau,/dim)
    print, '>> bandtau range: ',min(bandtau),max(bandtau)
    PRINT, '>> total time:    ',strtrim(string(round(SYSTIME(1)-T)),2), 'S'
    print, ''
endif

if check_math(0,0) eq 32 then junk = check_math(1,1)

return, bandtau

END

PRO TETS_htau_line_calc

state=[ "H2,X,*,0,*,0,*",$
    "H2,X,*,0,*,1,*",$
    "H2,X,*,0,*,2,*",$
    "H2,X,*,0,*,3,*",$
    "H2,X,*,0,*,4,*",$
    "H2,X,*,0,*,5,*",$
    "H2,X,*,0,*,6,*",$
    "H2,X,*,0,*,7,*",$
    "H2,X,*,0,*,8,*",$
    "HD,X,*,0,*,0,*",$
    "HD,X,*,0,*,1,*",$
    "HD,X,*,0,*,2,*",$
    "HD,X,*,0,*,3,*",$
    "HD,X,*,0,*,4,*"]
n=10.^21
doppb=1.0
wave_samp=[1e-6,900.,120000]
wave=wave_samp[1]*10.^(dindgen(wave_samp[2])*wave_samp[0])
tau=htau_line_calc(wave,state,n,doppb,silent=0)

END



PRO htau_line_calc_TEST

!p.thick=3.0
!x.thick = 3.0
!y.thick = 3.0
!z.thick = 3.0
!p.charsize=2.0
!p.charthick=3.0


cspeed=2.99792458d18
e=4.8032d-10    ;esu
me=1.6726231e-24/1836.        ;grams mass electron
xcoeff=sqrt(!dpi)*e^2/(me*(cspeed)*1.0e5) 
;or 1.497d-15


wl_grid=1000.       ; A
doppb_grid=1.0       ; km/s
ds=0.0025
offset=0.0025
gamma_grid=1.0e9    ; typical 1.0e9->2.0e9
xrange=[-0.1,0.1]
s=10.0
dl=10.0

plot,[0],[0],psym=10,/nodata,thick=2,$
    yrange=[0,1.2],ystyle=1,$
    xrange=xrange,xstyle=1
    
;+
;   gamma_grid/delnud/!dpi/4.
;   tyical value: 0.0041497608     0.016428296
;-
dv=0.000001d
nn=ceil((dl/dv))
wave_grid=wl_grid+(findgen(nn*2)-nn)*dv
f1=cspeed/wave_grid-cspeed/wl_grid
delnud=doppb_grid*1.d13/wl_grid
lprofile=voigt(gamma_grid/delnud/!dpi/4., f1/delnud)*s
oplot,wave_grid-wl_grid,exp(-lprofile),color=cgcolor('red'),thick=2
t1=total((1-exp(-lprofile))*dv)


dv=ds
; Direct Injection
nn=ceil((dl/dv))
wave_grid=wl_grid+(findgen(nn*2)-nn)*dv+offset
f1=cspeed/wave_grid-cspeed/wl_grid
delnud=doppb_grid*1.d13/wl_grid
lprofile=voigt(gamma_grid/delnud/!dpi/4., f1/delnud)*s
oplot,wave_grid-wl_grid,exp(-lprofile),color=cgcolor('blue'),psym=10,thick=2
oplot,wave_grid-wl_grid,exp(-lprofile),color=cgcolor('yellow'),thick=2,psym=cgsymcat(1),symsize=5
t2=total((1-exp(-lprofile))*dv)
print,t1,t2,(t1-t2)/t1*100,'%'

; Center Injection
nn=ceil((dl/dv))
wave_grid=wl_grid+(findgen(nn*2)-nn)*dv
f1=cspeed/wave_grid-cspeed/wl_grid
delnud=doppb_grid*1.d13/wl_grid
lprofile=voigt(gamma_grid/delnud/!dpi/4., f1/delnud)*s
;oplot,wave_grid-wl_grid+offset,exp(-lprofile),color=cgcolor('green'),psym=10,thick=2
;oplot,wave_grid-wl_grid+offset,exp(-lprofile),color=cgcolor('red'),thick=2,psym=cgsymcat(1),symsize=5
t2=total((1-exp(-lprofile))*dv)
print,t1,t2,(t1-t2)/t1*100,'%'


plot,[0],[0],psym=10,/nodata,thick=2,$
    yrange=[0,1.2],ystyle=1,$
    xrange=xrange,xstyle=1,/noe

print,dv/wl_grid*cspeed/1e10/1e3
    
;print,linetau
;tmp=htau_line_calc([1],"H2,X,*,0,*,0,*",1e20,1)

;ind=findgen(n_elements(wave_grid))
;tag=where((ind mod 20) eq 19)
;oplot,wave_grid[tag],linetau[tag],psym=10
;print,n_elements(wave_grid),n_elements(tag)

END


PRO htau_line_calc_TEST2

    !p.thick=3.0
    !x.thick = 3.0
    !y.thick = 3.0
    !z.thick = 3.0
    !p.charsize=2.0
    !p.charthick=3.0
    
    
    cspeed=2.99792458d18
    e=4.8032d-10    ;esu
    me=1.6726231e-24/1836.        ;grams mass electron
    xcoeff=sqrt(!dpi)*e^2/(me*(cspeed)*1.0e5)
    ;or 1.497d-15
    
    
    wl_grid=1200.       ; A
    ds=0.01
    offset=0.000
    gamma_grid=2.0e9    ; typical 1.0e9->2.0e9
    xrange=[-0.4,0.4]
    s=1
    dl=10.0
    
    plot,[0],[0],psym=10,/nodata,thick=2,$
        yrange=[0,1.2],ystyle=1,$
        xrange=xrange,xstyle=1
        
    ;+
    ;   gamma_grid/delnud/!dpi/4.
    ;   tyical value: 0.0041497608     0.016428296
    ;-
    dv=0.00001d
    doppb_grid=1.0       ; km/s
    nn=ceil((dl/dv))
    wave_grid=wl_grid+(findgen(nn*2)-nn)*dv
    f1=cspeed/wave_grid-cspeed/wl_grid
    delnud=doppb_grid*1.d13/wl_grid
    lprofile=voigt(gamma_grid/delnud/!dpi/4., f1/delnud)*s
    oplot,wave_grid-wl_grid,exp(-lprofile),color=cgcolor('red'),thick=2
    t1=total((1-exp(-lprofile))*dv)
    spec1=(1-exp(-lprofile))
    
;    dv=0.01d
;    doppb_grid=10.0
;    nn=ceil((dl/dv))
;    wave_grid=wl_grid+(findgen(nn*2)-nn)*dv+offset
;    f1=cspeed/wave_grid-cspeed/wl_grid
;    delnud=doppb_grid*1.d13/wl_grid
;    lprofile=voigt(gamma_grid/delnud/!dpi/4., f1/delnud)*s
;    oplot,wave_grid-wl_grid,exp(-lprofile),color=cgcolor('blue'),psym=10,thick=2
;    oplot,wave_grid-wl_grid,exp(-lprofile),color=cgcolor('yellow'),thick=2,psym=cgsymcat(1),symsize=5
;    t2=total((1-exp(-lprofile))*dv)
;    print,t1,t2,(t1-t2)/t1*100,'%'


    dv=0.00001d
    doppb_grid=1.5       ; km/s
    nn=ceil((dl/dv))
    wave_grid=wl_grid+(findgen(nn*2)-nn)*dv
    f1=cspeed/wave_grid-cspeed/wl_grid
    delnud=doppb_grid*1.d13/wl_grid
    lprofile=voigt(gamma_grid/delnud/!dpi/4., f1/delnud)*s
    oplot,wave_grid-wl_grid,exp(-lprofile),color=cgcolor('red'),thick=2
    t2=total((1-exp(-lprofile))*dv)
    spec2=(1-exp(-lprofile))
    print,(t1-t2)/t2
    print,max(abs(spec1-spec2))

    
;    dv=0.01d
;    doppb_grid=11.0
;    nn=ceil((dl/dv))
;    wave_grid=wl_grid+(findgen(nn*2)-nn)*dv+offset
;    f1=cspeed/wave_grid-cspeed/wl_grid
;    delnud=doppb_grid*1.d13/wl_grid
;    lprofile=voigt(gamma_grid/delnud/!dpi/4., f1/delnud)*s
;    oplot,wave_grid-wl_grid,exp(-lprofile),color=cgcolor('blue'),psym=10,thick=2
;    oplot,wave_grid-wl_grid,exp(-lprofile),color=cgcolor('yellow'),thick=2,psym=cgsymcat(1),symsize=5
;    t2=total((1-exp(-lprofile))*dv)
;    print,t1,t2,(t1-t2)/t1*100,'%'
        
    
    plot,[0],[0],psym=10,/nodata,thick=2,$
        yrange=[0,1.2],ystyle=1,$
        xrange=xrange,xstyle=1,/noe
        
    ;print,dv/wl_grid*cspeed/1e10/1e3
    
    ;print,linetau
    ;tmp=htau_line_calc([1],"H2,X,*,0,*,0,*",1e20,1)
    
    ;ind=findgen(n_elements(wave_grid))
    ;tag=where((ind mod 20) eq 19)
    ;oplot,wave_grid[tag],linetau[tag],psym=10
    ;print,n_elements(wave_grid),n_elements(tag)
    
END


