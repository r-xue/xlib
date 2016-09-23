FUNCTION CHECK_POINT,HD,RA,DEC,IM=IM, zero=zero
;+
;   check if a point is on the image
;   usually we check NAN as out of image FOV
;   /zero we define both NAN pixels and pixel=0 as out of image FOV
;   
;   VALID_OBJECT.PRO is more effcient 
;-
adxy,hd,ra,dec,x,y
np=n_elements(ra)
tmp=sxpar(hd,'znaxis1',count=c)
if  c gt 0 $
    then nsize=[sxpar(hd,'znaxis1'),sxpar(hd,'znaxis2')] $
    else nsize=[sxpar(hd,'naxis1'),sxpar(hd,'naxis2')]
in=replicate(0.0,np)
x=round(x)
y=round(y)

tag=where(x ge 0 and x lt nsize[0] and y ge 0 and y lt nsize[1])
if  tag[0] ne -1 then begin
    if  n_elements(im) ne 0 then begin
        if  keyword_set(zero) then tagshow=where(im[x[tag],y[tag]] eq im[x[tag],y[tag]] and im[x[tag],y[tag]] ne 0.0)
        if  ~keyword_set(zero) then tagshow=where(im[x[tag],y[tag]] eq im[x[tag],y[tag]])
        if  tagshow[0] ne -1 then in[tag[tagshow]]=1.0
    endif else begin
        in[tag]=1.0
    endelse
endif

return,in

END