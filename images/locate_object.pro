FUNCTION LOCATE_OBJECT,FILENAME,RA,DEC,$
    ZERO=ZERO,NAN=NAN,GUARD=GUARD
;+
;   check if a point is on the image
;   usually we check NAN as out of image FOV
;   /zero we define both NAN pixels and pixel=0 as out of image FOV
;   
;   LOCATE_POINT is more effcient if
;       * handle fpack fits
;       * reduce memory footprint
;       *
;   GUARD: consider the pixels near the image edge as out of FOV  [arcsec] 
;-
if  n_elements(guard) eq 0 then guard=0.0

hd=headfits(filename)

getrot,hd,rotang,cdelt
psize=abs(cdelt[0]*60.*60.)
tmp=sxpar(hd,'znaxis1',count=c)
if  c gt 0 $
    then nsize=[sxpar(hd,'znaxis1'),sxpar(hd,'znaxis2')] $
    else nsize=[sxpar(hd,'naxis1'),sxpar(hd,'naxis2')]

guard_pix=round(guard/psize)

adxy,hd,ra,dec,x,y
x=round(x)
y=round(y)
in=ra*0.0

tag=where(x ge 0+guard_pix and x lt nsize[0]-guard_pix and y ge 0+guard_pix and y lt nsize[1]-guard_pix)
if  tag[0] ne -1 then begin
    if  keyword_set(zero) or keyword_set(nan) then begin
        tmp=replicate(0.0,n_elements(tag))
        for i=0,n_elements(tag)-1 do begin
            fxread,filename,tmp0,tmp0hd,x[tag[i]],x[tag[i]],y[tag[i]],y[tag[i]]
            tmp[i]=tmp0
        endfor
        if  keyword_set(zero) and keyword_set(nan) then tagshow=where(tmp eq tmp and tmp ne 0.0)
        if  keyword_set(zero) and ~keyword_set(nan) then tagshow=where(tmp ne 0.0)
        if  ~keyword_set(zero) and keyword_set(nan) then tagshow=where(tmp eq tmp)
        if  tagshow[0] ne -1 then in[tag[tagshow]]=1.0
    endif else begin
        in[tag]=1.0
    endelse
endif

return,in

END