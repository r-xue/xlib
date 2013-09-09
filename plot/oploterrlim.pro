PRO OPLOTERRLIM,x,y,xe,ye,_extra=_extra,exp=exp,$
  xlim=xlim,ylim=ylim,lsize=lsize
;+
; over plot errorbar + lower limit
; /exp: data points will be plotted as 10^[x,y]
;       errorbar will be plotted as 10.^[x-xe,x-ye] & 10.^[y-ye,y-ye] 
; xlim=0:   detected
; xlim=-1:  upper limit (not detected)
; xlim=1:   lower limit (saturated)
; lsize:    upper/lower limit arrow length, in units of !d.x_size/64
;-



nd=n_elements(x)
if not keyword_set(lsize) then lsize=2.0
for i=0,nd-1 do begin
  
  ; get a "1/3-sigma error box"
  xt=x[i]+[0.0,-1.0,1.0,-3.0,3.0]*abs(xe[i])
  yt=y[i]+[0.0,-1.0,1.0,-3.0,3.0]*abs(ye[i])
  if keyword_set(exp) then begin
    xt=10.^xt
    yt=10.^yt
  endif

  aextra=_extra
  aextra.psym=0
  
  oplot,[xt[0]],[yt[0]],_extra=_extra
  ; for x-axis error bar
  if not keyword_set(xlim) then xlim=-(xt[3] le 0.0)
  if xlim eq -1 then begin
    tmp=convert_coord(xt[0],yt[0],/data,/to_device)
    cgarrow,tmp[0,0],tmp[1,0],tmp[0,0]-!d.x_size/64*lsize,tmp[1,0],/solid,$
      /device,hsize=!d.x_size/64./2.0,noclip=0,_extra=aextra
  endif else begin
    oploterror,xt[0],yt[0],xt[1]-xt[0],0.0,/nohat,$
      /lobar,_extra=_extra
    oploterror,xt[0],yt[0],xt[2]-xt[0],0.0,/nohat,$
      /hibar,_extra=_extra
  endelse

  ; for y-axis error bar
  if not keyword_set(ylim) then ylim=-(yt[3] le 0.0)
  if ylim eq -1 then begin
    tmp=convert_coord(xt[0],yt[0],/data,/to_device)
    cgarrow,tmp[0,0],tmp[1,0],tmp[0,0],tmp[1,0]-!d.x_size/64*lsize,/solid,$
      /device,hsize=!d.x_size/64./2.0,noclip=0,_extra=aextra
  endif else begin
    oploterror,xt[0],yt[0],0.0,yt[1]-yt[0],/nohat,$
      /lobar,_extra=_extra
    oploterror,xt[0],yt[0],0.0,yt[2]-yt[0],/nohat,$
      /hibar,_extra=_extra
  endelse

  
endfor


END