PRO OPLOTMS,x,y,color=color,_extra=_extra,lsize=lsize,xexp=xexp,yexp=yexp,exp=exp
;+
; over plot errorbar + lower limit
; /exp: data points will be plotted as 10^[x,y]
;       errorbar will be plotted as 10.^[x-xe,x-ye] & 10.^[y-ye,y-ye] 
; xlim=0:   detected
; xlim=-1:  upper limit (not detected)
; xlim=1:   lower limit (saturated)
; lsize:    upper/lower limit arrow length, in units of !d.x_size/64
; 
; exp: value are in log but plot after converting to linear
;-



if not keyword_set(lsize) then lsize=4.0

nd=n_elements(x)
for i=0,nd-1 do begin

    if ( x.value eq x.value and y.value eq y.value ) eq 0 then continue
    
    xt=x.value
    yt=y.value
    xl=x.value-(x.limits)[0]
    xu=x.value+(x.limits)[1]
    yl=y.value-(y.limits)[0]
    yu=y.value+(y.limits)[1]
    
    if  keyword_set(exp) or keyword_set(xexp)  then begin
        xt=10.^xt
        xl=10.^xl
        xu=10.^xu
    endif
    if  keyword_set(exp) or keyword_set(yexp)  then begin
        yt=10.^yt
        yl=10.^yl
        yu=10.^yu
    endif    

    
  ; get a "1/3-sigma error box"
;  xt=x[i]+[0.0,-1.0,1.0,-3.0,3.0]*abs(xe[i])
;  yt=y[i]+[0.0,-1.0,1.0,-3.0,3.0]*abs(ye[i])


    aextra=_extra
    ;aextra.psym=0
    oplot,[xt],[yt],color=color,_extra=aextra

  
    ; for x-axis error bar

    case x.limited of
        -1: begin
            tmp=convert_coord(xt[0],yt[0],/data,/to_device)
            cgarrow,tmp[0,0,0],tmp[1,0,0],tmp[0,0,0]-!d.x_size/64*lsize,tmp[1,0,0],/solid,$
                /device,hsize=!d.x_size/64./2.0,noclip=0,color=color
            end
        1:  begin
            tmp=convert_coord(xt[0],yt[0],/data,/to_device)
            cgarrow,tmp[0,0,0],tmp[1,0,0],tmp[0,0,0]+!d.x_size/64*lsize,tmp[1,0,0],/solid,$
                /device,hsize=!d.x_size/64./2.0,noclip=0,color=color
            end            
        else: begin
            oploterror,xt[i],yt[i],xt[i]-xl[i],0.0,/nohat,color=color,$
                /lobar,_extra=_extra
            oploterror,xt[i],yt[i],xu[i]-xt[i],0.0,/nohat,color=color,$
                /hibar,_extra=_extra
        endelse
    endcase
    ; for y-axis error bar
    case y.limited of
        -1: begin
            tmp=convert_coord(xt[0],yt[0],/data,/to_device)
            cgarrow,tmp[0,0,0],tmp[1,0,0],tmp[0,0,0],tmp[1,0,0]-!d.y_size/64*lsize,/solid,$
                /device,hsize=!d.x_size/64./2.0,noclip=0,color=color
            end
        1:  begin
            tmp=convert_coord(xt[0],yt[0],/data,/to_device)
            cgarrow,tmp[0,0,0],tmp[1,0,0],tmp[0,0,0],tmp[1,0,0]+!d.y_size/64*lsize,/solid,$
                /device,hsize=!d.x_size/64./2.0,noclip=0,color=color
            end            
        else: begin
        oploterror,xt[0],yt[0],0.0,yt[0]-yl[0],/nohat,color=color,$
            /lobar,_extra=_extra
        oploterror,xt[0],yt[0],0.0,yu[0]-yt[0],/nohat,color=color,$
            /hibar,_extra=_extra
        endelse
    endcase
  
endfor


END