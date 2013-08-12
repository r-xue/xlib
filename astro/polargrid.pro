PRO POLARGRID,im,hd,imout,hdout,ang,rad,$
  radlog=radlog

;+
; NAME:
;   POLARGRID
;
; PURPOSE:
;   regrid an image into a polar coordinate system
;
; INPUTS:
;   im,hd         original image and fits header
;   rad           the radius sampling vector (in arcsec)
;   ang           the polar angle sampling vector 
;                 (in degree, in respect of astronomical north)
;
; KEYWORDS:
;   radsc lin or log, default: lin
;
; OUTPUTS:
;   imout,hdout   output image and header
;
; HISTORY:
;
;   20120526  RX  introduced
;
;-


; [xi,yi] in the polar coords
; [xo,yo] in the cart coords

; FIND MAP REF CENTER
x_pos=sxpar(hd,'CRPIX1')-1.0
y_pos=sxpar(hd,'CRPIX2')-1.0


; SETUP POLAR GRID
vrad=rad
vang=ang
if n_elements(vrad) eq 3 then vrad=findgen((vrad[1]-vrad[0])/vrad[2]+1)*vrad[2]+vrad[0]
if keyword_set(radlog) then vrad=10.^vrad
if n_elements(vang) eq 3 then vang=findgen((vang[1]-vang[0])/vang[2]+1)*vang[2]+vang[0]
getrot,hd,rot,cdelt
ga=(vang+90.+rot)/360.*2.*!dpi   ; polar angle sampling vector, in rad
gr=vrad/3600./abs(cdelt[0])      ; radial sampling grid, in pixel

make_2d,ga,gr,gaa,grr
xo=x_pos+grr*cos(gaa)
yo=y_pos+grr*sin(gaa)

imout=interpolate(im,xo,yo,cubic=-0.5,missing=!values.f_nan)
hdout=hd
sxaddpar,hdout,'CTYPE1','angle'
sxaddpar,hdout,'CTYPE2','rad'
if keyword_set(radlog) then sxaddpar,hdout,'CTYPE2','lograd'
sxaddpar,hdout,'NAXIS1',n_elements(vang)
sxaddpar,hdout,'NAXIS2',n_elements(vrad)
sxaddpar,hdout,'CRPIX1',1
sxaddpar,hdout,'CRPIX2',1
sxaddpar,hdout,'CDELT1',ang[2]
sxaddpar,hdout,'CDELT2',rad[2]
sxaddpar,hdout,'CRVAL1',ang[0]
sxaddpar,hdout,'CRVAL2',rad[0]

sxaddpar,hdout,'DATAMIN',min(imout,/nan)
sxaddpar,hdout,'DATAMAX',max(imout,/nan)
sxaddpar,hdout,'CUNIT1','degree'
sxaddpar,hdout,'CUNIT2','arcsec'
if keyword_set(radlog) then sxaddpar,hdout,'CUNIT2','logarcsec'

END

PRO POLARGRID_TEST

im=readfits("ngc0628_8um.rgd.fits",hd)

ang=[-360,360,1]
rad=[0,2.5,0.01]
POLARGRID,im,hd,imout,hdout,ang,rad,/radlog
writefits,'test.fits',imout,hdout


END


