FUNCTION VALID_OBJECT,FILENAME,$
    RA,DEC,$
    ZERO=ZERO,NAN=NAN,GUARD=GUARD,FLAG=FLAG,SAT=SAT
;+
;   check if an object is on the image
;   usually we check NAN as out of image FOV
;   /zero we define both NAN pixels and pixel=0 as out of image FOV
;   
;   LOCATE_POINT is more effcient if
;       * handle fpack fits
;       * reduce memory footprint
;       *
;   GUARD: consider the pixels near the image edge as out of FOV  [arcsec] 
;   
;   ZERO:   p=0 is considered out of FOV
;   NAN:    missing data is consisdered out of FOV
;   FLAG:   p=0 is considered *AS* FOV
;   GUARD:  guard image edges as out of FOV
;   SAT     p>sat will be flagged out
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
for i=0,n_elements(obj_in)-1 do begin
    
    if  obj_in[i] eq 0 then continue 
    fxread,filename,tmp0,tmp0hd,x[i],x[i],y[i],y[i]
    
    if  keyword_set(zero)       then obj_in[i]=obj_in[i]*(~(tmp0 eq 0))
    if  keyword_set(nan)        then obj_in[i]=obj_in[i]*(~(tmp0 ne tmp0))
    if  keyword_set(flag)       then obj_in[i]=obj_in[i]*(~(tmp0 ne 0))
    if  n_elements(sat) eq 1    then obj_in[i]=obj_in[i]*(~(tmp0 ge sat))
    
endfor


return,obj_in

END