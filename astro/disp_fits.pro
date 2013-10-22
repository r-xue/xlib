PRO DISP_FITS,im,hd,refhd,$
    position=position,_extra=extra,$
    subrange=subrange,subim=subim,dummy=dummy,noplot=noplot
;+
; NAME:
;   disp_fits
; 
; PURPOSE:
;   plot a fits image in a specified region
; 
; INPUTS:
;   IM          data image
;   HD          data hd
;   REFHD       header specifying the region to be plotted
;               note: refhd pixel size doesn't really matter here.
;   position   plott position
;   _EXTRA      any keywords for cgimgscl
;   
; KEYWORD:
;   noplot      don't plot, just for testing, or deriving subrange/subim
;   
; OUTPUTS:
;   SUBRANGE    [xmin,xmax,ymin,ymax] 
;               index range (defined in IM) of the smallest rectangle covering 
;               the plotted region
;   SUBIM       a cutoff from IM just large enough to cover the plotted region
;   DUMMY       a template from refhd 
;                
; HISTORY:
;
;   20120701  RX  introduced    
;   20131019  RX  performace enhancement
;                 rename it to disp_fits.pro
;                 
;-

dummy=fltarr(sxpar(refhd,'NAXIS1'),sxpar(refhd,'NAXIS2'))
dummy[*]=0
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
sim = cgImgScl(subim,_extra=extra)

; PLOTTING
if not keyword_set(noplot) then begin
    cgimage,dummy,position=position,_extra=extra
    imcontour,dummy,refhd,/noe,levels=[0],position=position,$
        xtitle='',ytitle='',subtitle=' ',xstyle=4,ystyle=4
    for i=0,np-1 do begin
        polyfill,bx[i,*],by[i,*],color=sim[tag_roi[i]],$
            noclip=0
    endfor
endif


END



PRO TEST_DISP_FITS

im=readfits('lmc_v9.co.vbin.sgm.mom0_roi14.fits',hd)
ra=85.61
dec=-71.34
refhd=MK_HD([ra,dec],[350,700],1.)
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

pos=[0.2,0.2,0.8,0.8]
cgloadct,3,/rev
disp_fits,im,hd,refhd,position=pos,stretch=5,/keep,dummy=dummy
cgloadct,0
imcontour,dummy,refhd,/noe,levels=[0],position=pos,TYPE=0,/overlay,/nodata


device, /close
set_plot,'X'


END