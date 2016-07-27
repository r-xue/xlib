PRO XWIN,WINID,xysize=xysize
;+
;   set up x-window. if the window already exists, re-use it.
;-
if  n_elements(xysize) eq 2 then begin
    xsize=xysize[0]
    ysize=xysize[1]
endif else begin
    xsize=800
    ysize=800
endelse

if  ~windowavailable(WINID) then window,WINID,xsize=xsize,ysize=ysize else wset,WINID

END