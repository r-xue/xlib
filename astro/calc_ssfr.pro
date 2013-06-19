FUNCTION CALC_SSFR, INT, HD, PROJ=PROJ, FUV=FUV, M24=M24

;+
; NAME:
;   CALC_CN
;
; PURPOSE:
;   calculate the column density according to the line brightness
;
; INPUTS:
;   INT         data (either 2d image or 1D vector)
;   HD          header for deriving flux conversion factor
;   PROJ        the data source of the input image: SINGS, LVL, GOLDMINE...,more 
;   FUV         FUV flux (not implemented)
;   M24         24micron flux (not implemented)
;   
; OUTPUTS:
;   SIG_SFR     SFR surface density in Msol/yr/kpc^2
;
;
; HISTORY:
;
;   20130619    RX  introduced
;
;-

if not keyword_set(proj) then proj='SINGS' 

; CW & FWHM values from 
; http://irsa.ipac.caltech.edu/data/SPITZER/SINGS/doc/sings_fifth_delivery_v2.pdf
if STRPOS(STRUPCASE(sxpar(hd, 'FILTER')), 'KP1468') ne -1 then begin
  cw=6567.
  fwhm=84.
endif
if STRPOS(STRUPCASE(sxpar(hd, 'FILTER')), 'KP1563') ne -1 then begin
  cw=6573.
  fwhm=67.
endif
if STRPOS(STRUPCASE(sxpar(hd, 'FILTER')), 'KP1390') ne -1 then begin
  cw=6587.
  fwhm=72.
endif
if STRPOS(STRUPCASE(sxpar(hd, 'FILTER')), 'KP1564') ne -1 then begin
  cw=6618.
  fwhm=74.
endif
if STRPOS(STRUPCASE(sxpar(hd, 'FILTER')), 'CT6568') ne -1 then begin
  cw=6568.
  fwhm=19.
endif
if STRPOS(STRUPCASE(sxpar(hd, 'FILTER')), 'CT6586') ne -1 then begin
  cw=6583.
  fwhm=20.
endif
if STRPOS(STRUPCASE(sxpar(hd, 'FILTER')), 'CT6602') ne -1 then begin
  cw=6596.
  fwhm=18.
endif
if STRPOS(STRUPCASE(sxpar(hd, 'FILTER')), 'CT6618') ne -1 then begin
  cw=6610.
  fwhm=18.
endif

; SINGS:     
; http://irsa.ipac.caltech.edu/data/SPITZER/SINGS/doc/sings_fifth_delivery_v2.pdf (p36)
if STRUPCASE(proj) eq 'SINGS' then begin
  photflam=sxpar(hd, 'PHOTFLAM')
  cps2flux=3.0e-5*photflam*fwhm/(cw^2.0)
endif

; LVL:       
; http://irsa.ipac.caltech.edu/data/SPITZER/LVL/LVL_DR5_v5.pdf (p23)
if STRUPCASE(proj) eq 'LVL' then $
  cps2flux=sxpar(hd, 'RESPONSE')/sxpar(hd, 'TRANSMIS')/sxpar(hd,'EXPTIME')

; GOLDMINE: 
; http://goldmine.mib.infn.it
if STRUPCASE(proj) eq 'GOLDMINE' then $
  cps2flux=10.^(sxpar(hd,'P_ZP'))/(sxpar(hd,'P_EXPTIM'))

getrot,hd,angle,cdelt
psize=abs(cdelt[0])*60.0*60
cps2int=cps2flux/(psize^2.0)

int_ha=int*cps2int ; in  erg s^-1 cm^-2 arcsec^-2
; SFR [Msol/yr] = 5.37e-42 * L{Halpha} [erg/s]   (2011ApJ...737...67M)
sig_sfr=2.73e13*int_ha ; in Msol/yr/kpc^2

return,sig_sfr

END

PRO TEST_CALC_SFR


testfile=['/Volumes/Scratch/data_repo/spitzer/sings/ngc3521/Ancillary/ngc3521_HA_SUB_dr4.fits',$
  '/Volumes/Scratch/data_repo/spitzer/sha-sting/n2976/lvl/Halpha/NGC2976_ha_sub.fits',$
  '/Users/Rui/Downloads/cg159102_netk.fits']
projs=['SINGS','LVL','GOLDMINE']

for i=0,2 do begin
  im=readfits(testfile[i],hd)
  out=calc_ssfr(im,hd,proj=projs[i])
  writefits,'test'+strtrim(i,2)+'.fits',out,hd
endfor

END