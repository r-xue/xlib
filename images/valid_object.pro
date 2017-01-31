FUNCTION VALID_OBJECT,FILENAME,$
    RA,DEC,$
    ZERO=ZERO,NAN=NAN,GUARD=GUARD,FLAG=FLAG,SAT=SAT
;+
; NAME:
;   VALID_OBJECT
;   
; PURPOSE:
;   Validate if an object is located with a 2D image
;   this procedure checks not only a sky point is within the image boundary,
;   but also examine:
;       * whether its pixel value is valid (zero/NAN/flag).
;       * whether the object is close to the image edge.
;   
;   Usually one would mark the out  NAN as out of image FOV
;   /zero we define both NAN pixels and pixel=0 as out of image FOV
;   
;   VALIDE_OBJECT is optimized for effciency on large images:
;       * handle fpack fits
;       * limited memory footprint
; 
; RETURN:
; 
;   obj_in:     1   object with the 2D image and valid
;               0   object out of the 2D image or invalid
; 
; INPUTS:
;   FILENAME:   FITS image
;   GUARD:      consider the pixels near the image edge as out of FOV (invalid)  [arcsec] 
;               this value could be negative:
;                   an edge-padded image will be used for object validation
;                   (zero/nan/flag/sat will not work)  
;   
;   ZERO:       p=0 as out of FOV
;   NAN:        missing data as out of FOV
;   FLAG:       p=0 is considered *AS* FOV
;   SAT         p>sat as invalid
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

obj_in=(x ge 0+guard_pix and x lt nsize[0]-guard_pix and y ge 0+guard_pix and y lt nsize[1]-guard_pix)

if  guard_pix ge 0 then begin
    for i=0,n_elements(obj_in)-1 do begin
        if  obj_in[i] eq 0 then continue 
        fxread,filename,tmp0,tmp0hd,x[i],x[i],y[i],y[i]
        if  keyword_set(zero)       then obj_in[i]=obj_in[i]*(~(tmp0 eq 0))
        if  keyword_set(nan)        then obj_in[i]=obj_in[i]*(~(tmp0 ne tmp0))
        if  keyword_set(flag)       then obj_in[i]=obj_in[i]*(~(tmp0 ne 0))
        if  n_elements(sat) eq 1    then obj_in[i]=obj_in[i]*(~(tmp0 ge sat))
    endfor
endif

return,obj_in

END