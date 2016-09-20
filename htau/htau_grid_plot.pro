PRO HTAU_GRID_PLOT

;+
; NAME:
;   H1TAU_GRID_PLOT
;
; PURPOSE:
;   plot h1tau templates
;-

RESOLVE_ROUTINE,'htau_grid_mkline',/is_function
base_wave=[900.,2000.]
base_tau=[0.0,0.0]

; BUILD TEST MODEL1

model1={    name: 'h1test',$
            state:replicate("H I,1,*,*,*,*,*",4),$
            n:    replicate(21.,4),$
            b:    [1,5,10,20],$
            v:    replicate(0.0,4) }

state=[ "H2,X,*,0,*,0,*",$
    "H2,X,*,0,*,1,*",$
    "H2,X,*,0,*,2,*",$
    "H2,X,*,0,*,3,*",$
    "H2,X,*,0,*,4,*",$
    "H2,X,*,0,*,5,*",$
    "H2,X,*,0,*,6,*",$
    "H2,X,*,0,*,7,*",$
    "H2,X,*,0,*,8,*",$
    "H I,1,*,*,*,*,*"]
state=[state,state]
n1=[19.42,19.38,17.75,17.83,15.88,15.36,14.20,0.00,0.00,21.]
n2=[18.50,18.50,17.50,17.50,00.00,00.00,00.00,0.00,0.00,21.]
n=[n1,n2]
v1=replicate(272,10)
v2=replicate(10,10)
v=[v1,v2]
b1=replicate(4.8,10)
b2=replicate(4.8,10)
b=[b1,b2]

model2={    name: 'h2test',$
            state:state,$
            n:n,$
            b:b,$
            v:v,$
            base_wave:base_wave,$
            base_tau:base_tau}
            
model3={    name: 'h1vsd1',$
            state:["H I,1,*,*,*,*,*","D I,1,*,*,*,*,*"],$
            n:    [21,20],$
            b:    [5,5],$
            v:    [0,0] }

model4={    name: 'H2vsHD',$    
            state:["H2,X,*,0,*,0,*","HD,X,*,0,*,0,*","HD,X,*,0,*,1,*"],$
            n:    [20,20,19],$
            b:    [5,5,5],$
            v:    [0,0,0] }

model5={    name: 'onlyh20',$
            state:["H2,X,*,0,*,0,*"],$
            n:    [20.],$
            b:    [0.8],$
            v:    [0.] }


; BUILD TEST MODEL2

model=list(model1,model2,model3,model4)
model=list(model2)


for k=0,n_elements(model)-1 do begin
    
    nstate=n_elements(model[k].state)
    
    T=SYSTIME(1)
    ;for iii=0,100 do begin
    spec=htau_grid_mkline(model[k],/decomp)
    ;endfor
    PRINT, '>> total time:   ',SYSTIME(1)-T, 'S'
    T=SYSTIME(1)
    
    
;    psfile=path+'../templates/htau_grid_plot_'+model[k].name+'_dc.eps'
;    set_plot,'ps'
;    device, file=psfile, /color, bits=8, /cmyk, /encapsulated,$
;        ;/land,xsize=11,ysize=8.5,/inches
;        xsize=11.0,ysize=8.5,/inches,xoffset=0.0,yoffset=0.0
;    !p.thick=2.0
;    !x.thick = 2.0
;    !y.thick = 2.0
;    !z.thick = 2.0
;    !p.charsize=1.0
;    !p.charthick=1.0
;    
;    loadct,13
;    wvlen=50
;    wvs=900
;    ymin=-2.0
;    ymax=3.0
;    clist=findgen(nstate)/nstate*255.
;    cthin=6-indgen(nstate)*4./nstate
;    !P.MULTI = [0, 1, 8]
;
;    for j=0,7 do begin
;        plot, [wvs+j*wvlen,wvs+j*wvlen+wvlen],[ymin,ymax],/nodata,$
;            xrange=[wvs+j*wvlen,wvs+j*wvlen+wvlen],$
;            yrange=[ymin,ymax],$
;            xstyle=1,ystyle=1
;        for i=0,nstate-1 do begin
;            oplot, spec.wl,spec.fldc[*,i],color=clist[i],thick=cthin[i]
;        endfor
;    endfor
;
;    loadct,0
;    device,/close
;    set_plot,'x'
    
    ;    wvlen=50
;    wvs=900
;    ymin=-2.0
;    ymax=3.0

    psfile='htau_grid_plot_'+model[k].name+'.eps'
    set_plot,'ps'
    device, file=psfile, /color, bits=8, /cmyk, /encapsulated,$
        ;/land,xsize=11,ysize=8.5,/inches
        xsize=15,ysize=10.0,/inches,xoffset=0.0,yoffset=0.0
    !p.thick=2.0
    !x.thick = 2.0
    !y.thick = 2.0
    !z.thick = 2.0
    !p.charsize=1.0
    !p.charthick=1.0
    loadct,13
    wvlen=40
    wvs=900
    ymin=-2.0
    ymax=3.0
    clist=findgen(20)*255/20
    cthin=6-findgen(20)*0.2
    !P.MULTI = [0, 1, 7]
    for j=0,5 do begin
        plot, [wvs+j*wvlen,wvs+j*wvlen+wvlen],[ymin,ymax],/nodata,$
            xrange=[wvs+j*wvlen,wvs+j*wvlen+wvlen],$
            yrange=[ymin,ymax],$
            xstyle=5,ystyle=1
        oplot, spec.wl,spec.fl,color=0,thick=2.0
        htau_plot_hmarker,[0,255],[0,1]
    endfor
    plot, [wvs+j*wvlen,wvs+j*wvlen+wvlen],[ymin,ymax],/nodata,$
        xrange=[1140,1300],$
        yrange=[ymin,ymax],$
        xstyle=5,ystyle=1
    oplot, spec.wl,spec.fl,color=0,thick=2.0,psym=10
    htau_plot_hmarker,[0,255],[0,1]
    
    loadct,0
    device,/close
    set_plot,'x'
    

endfor

END




PRO HTAU_GRID_PLOT_H2_SLOW
;+
; this is essentially the same as HTAU_GRID_PLOT_H2, but not using htau templates
;-

base_wave=[900.,2000.]
base_tau=[0.0,0.0]

state=[ "H2,X,*,0,*,0,*",$
        "H2,X,*,0,*,1,*",$
        "H2,X,*,0,*,2,*",$
        "H2,X,*,0,*,3,*",$
        "H2,X,*,0,*,4,*",$
        "H2,X,*,0,*,5,*",$
        "H2,X,*,0,*,6,*",$
        "H2,X,*,0,*,7,*",$
        "H2,X,*,0,*,8,*",$
        "H I,1,*,*,*,*,*"]
state=[state,state]
n1=[19.42,19.38,17.75,17.83,15.88,15.36,14.20,0.00,0.00,22.]
n2=[18.50,18.50,17.50,17.50,00.00,00.00,00.00,0.00,0.00,23.]
n=[n1,n2]
v1=replicate(272,10)
v2=replicate(10,10)
v=[v1,v2]
b1=replicate(4.8,10)
b2=replicate(4.8,10)
b=[b1,b2]
        
model={ state:state,$
        n:n,$
        b:b,$
        v:v,$
        base_wave:base_wave,$
        base_tau:base_tau}
wave=findgen((1300.-900.)/0.0025)*0.0025+900.
cspeed=2.998e5

T=SYSTIME(1)  
tau_all=fltarr(n_elements(wave))
for i=0,n_elements(model.v)-1 do begin
    print,'tau',b[i]
    bandtau=$
    htau_line_calc(wave*(cspeed-model.v[i])/cspeed,$
        model.state[i],$
        10.^model.n[i],$
        model.b[i],/silent)
    tau_all=tau_all+bandtau
endfor
PRINT, '>> total time:   ',SYSTIME(1)-T, 'S'
T=SYSTIME(1)

psfile='htau_grid_plot_h2_slow.eps'
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
clist=findgen(20)*255/20
cthin=6-findgen(20)*0.2
!P.MULTI = [0, 1, 8]
for j=0,7 do begin
  plot, [wvs+j*wvlen,wvs+j*wvlen+wvlen],[0.0,1.1],/nodata,$
      xrange=[wvs+j*wvlen,wvs+j*wvlen+wvlen],$
      yrange=[0.0,1.1],$
      xstyle=1,ystyle=1
  oplot, wave,exp(-tau_all),color=0,thick=2.0
endfor
loadct,0
device,/close
set_plot,'x'

if  check_math(0,0) eq 32 then junk = check_math(1,1)
  
END

