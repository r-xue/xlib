PRO DISP_FITS,im,hd,refhd,_extra=extra,subrange=subrange
;+
; NAME:
;   disp_fits
; 
; PURPOSE:
;   plot a fits image in a pre-defined region
; 
; INPUTS:
;   IM          data image
;   HD          data hd
;   REFHD       fits header defining the plotting region
;               note: refhd pixel size doesn't really matter here.
;   
;   _EXTRA      any keywords for imcontour and cgimgscl
;   
; OUTPUTS:
;   SUBRANGE    [xmin,xmax,ymin,ymax] 
;               index range of the smallest rectangle covering the plotted
;               region 
; HISTORY:
;
;   20120701  RX  introduced    
;   20131019  RX  performace enhancement
;                 rename it to disp_fits.pro
;-

dummy=intarr(sxpar(refhd,'NAXIS1'),sxpar(refhd,'NAXIS2'),/nozero)
nxy=size(dummy,/d)

; GET REF BOUNDARY IN THE TARGET IMAGE
refbx=[]
refby=[]
refbx=[refbx,findgen(nxy[0]+2)-1]
refby=[refby,replicate(-1.,nxy[0]+2)]
refbx=[refbx,replicate(nxy[0],nxy[1]+2)]
refby=[refby,findgen(nxy[1]+2)-1]
refbx=[refbx,reverse(findgen(nxy[0]+2)-1)]
refby=[refby,replicate(nxy[1],nxy[0]+2)]
refbx=[refbx,replicate(-1,nxy[1]+2)]
refby=[refby,reverse(findgen(nxy[1]+2)-1)]
xyxy,refhd,hd,refbx,refby,bx,by

; IDENTIFY IMAGES PIXELS IN THE REF BOUNDARY
nxy=size(im,/d)
xmin=floor(min(bx))>0.0
xmax=ceil(max(bx))<nxy[0]-1.0
ymin=floor(min(by))>0.0
ymax=ceil(max(by))<nxy[1]-1.0
make_2d,findgen(xmax-xmin+1)+xmin,findgen(ymax-ymin+1)+ymin,xx,yy
obj_roi=obj_new('IDLanROI',round(bx),round(by))
tag_roi=obj_roi->containspoints(xx[*],yy[*])
obj_destroy,obj_roi
tag_roi=where(tag_roi ne 0)
subrange=[xmin,xmax,ymin,ymax]

; GET THE XY POSITIONS OF EACH INTERESTED PIXEL IN REF FRAME
np=n_elements(tag_roi)
bx=cmreplicate(xx[tag_roi],4)
by=cmreplicate(yy[tag_roi],4)
bx[*,0]=bx[*,0]-0.5
bx[*,1]=bx[*,1]+0.5
bx[*,2]=bx[*,2]+0.5
bx[*,3]=bx[*,3]-0.5
by[*,0]=by[*,0]-0.5
by[*,1]=by[*,1]-0.5
by[*,2]=by[*,2]+0.5
by[*,3]=by[*,3]+0.5
xyxy,hd,refhd,bx,by

; IMAGE SCALING
subim=im[xmin:xmax,ymin:ymax]
min_value=min(subim,/nan)
max_value=max(subim,/nan)
sim = cgImgScl(subim, minvalue=min_value,maxvalue=max_value,_extra=extra)

; PLOTTING
;imcontour,dummy,refhd,levels=0,/noe,/nodata,_ref_extra=extra

for i=0,np-1 do begin
    polyfill,bx[i,*],by[i,*],color=sim[tag_roi[i]],noclip=0,/data
endfor

;imcontour,dummy,refhd,levels=0,/noe,/nodata,_ref_extra=extra

    
END



PRO TEST_DISP_FITS

im=readfits('/Users/Rui/Workspace/magclouds/sagemap/LMC_IRAC8.0_mosaic.fits',hd)
ra=82.7
dec=-71.11
refhd=MK_HD([ra,dec],500,1.)
print,refhd

set_plot, 'ps'
device, filename='test.eps', $
    bits_per_pixel=8,/encapsulated,$
    xsize=10,ysize=7,/inches,/col,xoffset=0,yoffset=0,/cmyk
!p.thick=2.0
!x.thick = 2.0
!y.thick = 2.0
!z.thick = 2.0
!p.charsize=1.0
!p.charthick=2.0

cgloadct,3,/rev
disp_fits,im,hd,refhd,pos=pos,/overlay,$
    xtitle=xtitle,ytitle=ytitle,subtitle=subtitle,xtickname=xtickname,ytickname=ytickname,$
    c_lab=0,Stretch=5
cgloadct,0
device, /close
set_plot,'X'


END