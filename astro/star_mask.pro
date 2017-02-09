FUNCTION STAR_MASK,imo,x,y,dr=dr,dx=dx,dy=dy,ds=ds,$
    px=px,py=py
;+
; NAME:
;   STAR_MASK
;   
; PURPOSE:
;   create a star mask to exclude: 
;       diffraction spikes
;       saturation trail/spot
; 
; INPUTS:
;   imo
;   x       star x-pos
;   y       star y-pos
;   dr      radius of a circle (if scalar)
;           inner/outer radii of a ring (if 2-elenents array)
;   dx      vertical strip width
;   dy      horizontal strip width
;   ds      diagonal strip width
;   px      polygon x-pos
;   py      polygon y-pos  
;   
;   
;-

im=imo*0.0

sz=size(im,/d)
dist_ellipse,temp,size(im,/d),x,y,1.0,0.,/double

if  n_elements(dr) eq 1 then begin
    im[where(temp le dr,/null)]=1.0
endif

if  n_elements(dr) eq 2 then begin
    im[where(temp ge min(dr) and temp le max(dr),/null)]=1.0
endif

if  n_elements(dx) ne 0 then begin
    if  dx gt 0.0 then begin
        im[round(x-dx):round(x+dx),*]=1.0
    endif
endif
if  n_elements(dy) ne 0 then begin
    if  dy gt 0.0 then begin
        im[*,round(y-dy):round(y+dy)]=1.0
    endif
endif
if  n_elements(ds) ne 0 then begin
    if  ds gt 0.0 then begin 
        tpx=[x+sz[0]+ds,x+sz[0]-ds,x-sz[0]-ds,x-sz[0]+ds]
        tpy=[y+sz[1]-ds,x+sz[1]+ds,x-sz[1]+ds,x-sz[1]-ds]
        obj=Obj_New('IDLanROI', tpx, tpy)
        temp=obj->ComputeMask(dim=sz)
        Obj_Destroy, obj
        im[where(temp gt 0,/null)]=1.0
        tpx=[x-sz[0]+ds,x-sz[0]-ds,x+sz[0]-ds,x+sz[0]+ds]
        tpy=[y+sz[1]+ds,x+sz[1]-ds,x-sz[1]-ds,x-sz[1]+ds]
        obj=Obj_New('IDLanROI', tpx, tpy)
        temp=obj->ComputeMask(dim=sz)
        Obj_Destroy, obj
        im[where(temp gt 0,/null)]=1.0
    endif
endif

if  n_elements(px) ge 3 then begin
    obj=Obj_New('IDLanROI', px, py)
    temp=obj->ComputeMask(dim=sz)
    Obj_Destroy, obj
    im[where(temp gt 0,/null)]=1.0
endif

return,im

END

PRO TEST_STAR_MASK

;im=fltarr(500,500)
;
;cgLoadCT, 0,/rev
;;mask=star_mask(im,250,250,dr=40,dx=0.0,dy=10,ds=10)
;;cgimage,mask
;mask=star_mask(im,250,250,dr=[50,70],dx=0.0,dy=10,ds=10)
;writefits,'test_star_mask.fits',mask


im=readfits('old_flg.fits',hd)
mask1=star_mask(im,5129,8000,dr=[170,230]/0.15)
mask2=star_mask(im,7200,9000,dr=[170,230]/0.15)
mask3=star_mask(im,3800,6400,dr=[170,230]/0.15)
mask4=star_mask(im,5130,8030,dr=50/0.15)
mask5=star_mask(im,7200,9150,dr=50/0.15)
mask6=star_mask(im,3600,6430,dr=50/0.15)
mask=(im or mask1 or mask2 or mask3 or mask4 or mask5 or mask6)

writefits,'old_flg_mask.fits',mask,hd


END

