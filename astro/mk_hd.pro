FUNCTION MK_HD, crval,naxis,psize,$
         ctype=ctype,vtype=vtype
;+
; NAME:
;   MK_HD
;
; PURPOSE:
;   make a minimal fits header for setting up reference frame
;   or pixel rebinning
;
; INPUTS:
;   CRVAL   -- pixel center, 2or3-element vector 
;              ra/dec in degree
;              velo in km/s
;              freq in kHz
;   NAXIS   -- image size, 1,2,or,3-element vector
;   PSIZE   -- pixel size, scale or 2/3-element vector:
;              1st element - dx pixel size in arcsec
;              2nd element - channel width in km/s
;                          - channel width in kHz 
;              3nd element - dy pixel size in arcsec
;                            in case of non-square pixel 
;   ctype   -- default:         ['RA---TAN','DEC--TAN']
;                               ['RA---SIN','DEC--SIN']              
;   [vtype] -- default:         'VELO-LSR'
;                               'FREQ    '          
;
; OUTPUTS:
;   HD      -- fits header
; 
; HISTORY:
;
;   20130214  RX  introduced
;   20130322  RX  add an option to create headers for 3d cubes  
;-

if  n_elements(naxis) eq 1 then begin 
    ndim=fix([naxis,naxis])
endif else begin
    ndim=fix(naxis)
endelse
mkhdr,hd,4,ndim

if  n_elements(psize) eq 3 then dy=psize[2] else dy=psize[0]
make_astr,astr,delt=double([-psize[0], dy])/3600.,$
    crpix=fix(ndim[0:1]/2)+1,crval=crval[0:1],$
    ctype=ctype

putast,hd,astr,EQUINOX =2000,cd_type=0

if n_elements(ndim) eq 3 then begin
    if n_elements(vtype) eq 0 then vtype='VELO-LSR'
    SXADDPAR,hd,'CRPIX3',1
    SXADDPAR,hd,'CDELT3',psize[1]*1000.
    SXADDPAR,hd,'CRVAL3',crval[2]*1000.
    SXADDPAR,hd,'CTYPE3',vtype
endif

return,hd

END


PRO TEST_MK_HD

; 2D CASE

rebin=4

oldim=readfits("ngc4254.co.sm.mom0.fits",oldhd)
getrot,oldhd,rotang,cdelt
oldpsize=abs(cdelt[0])*60.*60.
oldnaxis=size(oldim,/d)

; make header with pixel size 4 times larger
gal='NGC4254'
querysimbad,gal,ra,dec
print,'NED coords Query'
print,gal,ra,dec
imhd_ref=mk_hd([ra,dec],oldnaxis/rebin,rebin*oldpsize)

regrid3d,oldim,oldhd,newim,newhd,imhd_ref,missing=!VALUES.F_NAN
writefits,'ngc4254.co.sm.mom0.rebin.fits',newim,newhd

; 3D CASE
rebin=[4,4,2]

oldim=readfits("ngc4254.co.cmmsk.fits",oldhd)
getrot,oldhd,rotang,cdelt

oldpsize=abs(cdelt[0])*60.*60.
oldnaxis=size(oldim,/d)
olddv=abs(sxpar(oldhd,'cdelt3'))/1000.
oldv=abs(sxpar(oldhd,'crval3'))/1000.

; make header with pixel size 4 times larger
gal='NGC4254'
querysimbad,gal,ra,dec
print,'NED coords Query'
print,gal,ra,dec
imhd_ref=mk_hd([ra,dec,oldv-30],oldnaxis/rebin+[0,0,fix(2*30/(olddv*rebin[2]))],$
              [rebin[0]*oldpsize,rebin[2]*olddv],ctype=['RA---SIN','DEC--SIN'])

regrid3d,oldim,oldhd,newim,newhd,imhd_ref,regridv=0
writefits,'ngc4254.co.cmmsk.rebin.fits',newim,newhd



END