FUNCTION STAR_MASK,imo,x,y,dr=dr,dx=dx,dy=dy,ds=ds
;+
;   create a star mask, including: diffraction spikes, saturation trail/spot
;-

im=imo*0.0

sz=size(im,/d)
dist_ellipse,temp,size(im,/d),x,y,1.0,0.,/double
if  n_elements(dr) ne 0 then begin
    if  dr gt 0.0 then begin
        im[where(temp le dr,/null)]=1.0
    endif
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
        px=[x+sz[0]+ds,x+sz[0]-ds,x-sz[0]-ds,x-sz[0]+ds]
        py=[y+sz[1]-ds,x+sz[1]+ds,x-sz[1]+ds,x-sz[1]-ds]
        obj=Obj_New('IDLanROI', px, py)
        temp=obj->ComputeMask(dim=sz)
        Obj_Destroy, obj
        im[where(temp gt 0,/null)]=1.0
        px=[x-sz[0]+ds,x-sz[0]-ds,x+sz[0]-ds,x+sz[0]+ds]
        py=[y+sz[1]+ds,x+sz[1]-ds,x-sz[1]-ds,x-sz[1]+ds]
        obj=Obj_New('IDLanROI', px, py)
        temp=obj->ComputeMask(dim=sz)
        Obj_Destroy, obj
        im[where(temp gt 0,/null)]=1.0
    endif
endif

return,im

END

PRO TEST_STAR_MASK

im=fltarr(500,500)

mask=star_mask(im,250,250,dr=40,dx=0.0,dy=10,ds=10)
cgimage,mask

END

