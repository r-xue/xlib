FUNCTION CHECK_POINT,HD,RA,DEC
;+
;   check if a point is on the image
;-
adxy,hd,ra,dec,x,y
np=n_elements(ra)
tmp=sxpar(hd,'znaxis1',count=c)
if  c gt 0 $
    then nsize=[sxpar(hd,'znaxis1'),sxpar(hd,'znaxis2')] $
    else nsize=[sxpar(hd,'naxis1'),sxpar(hd,'naxis2')]
tag=where(x gt 0 and x lt nsize[0] and y gt 0 and y lt nsize[1],/null)
in=replicate(0.0,np)
in[tag]=1.0

return,in

END