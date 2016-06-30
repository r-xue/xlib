FUNCTION CALC_C2F,cps,$
    effwave=effwave,$
    vega2ab=vega2ab,$
    zpt=zpt,$
    psize=psize,bw=bw

;+
; NAME:
;   CALC_C2F
;
; PURPOSE:
;   convert image counts/s to physics flux units
;
; INPUTS:
;
;   cps
;   band
;   vega2ab AB=Vega+vega2ab
;   zpt
;   psize   

;   BAND will overwrite vega2ab/zpt/psize
;
; OUTOUTS:
;   flux 
;
; KEYWORDS:
;
; NOTES:
;   also check out mag2flux()
;   
; EXAMPLE:

;
; HISTORY:
;   20150712    R.Xue   add comments
;   
; NOTE:
;   The equation here is the same as mag2flux.pro
;   snr=(2.5*alog10(exp(1.0)))/magerr
;-

if  n_elements(vega2ab) eq 0 then vega2ab=0.0
if  n_elements(zpt) eq 0 then zpt=21.0

mab=-2.5*alog10(cps)+zpt+vega2ab

fl=10.^(-(mab+48.6)*2./5.)                      ; in erg s^-1 cm^-2 hz^-1

if  n_elements(effwave) ne 0 then begin
    fl=fl*1e23                                  ; in Jy
    fl=fl/3.34e4/(effwave)^2.0                  ; in erg cm^-2 s^-1 A^-1
endif

;print,'+'
;print,mag2flux(mab,abwave=effwave)
;print,fl
;print,'-'

if  n_elements(bw) ne 0 then $
    fl=fl*bw                            ; in erg cm^-2 s^-1

if  n_elements(psize) ne 0 then $
    fl=fl/psize^2.0                     ; in erg cm^-2 s^-1 arcsec^-2

return,fl

END

PRO TEST_CALC_C2F

print, CALC_C2F(10.0,zpt=30.359,psize=0.258,effwave=6531.54)
print, CALC_C2F(10.0,zpt=30.359,psize=0.258,effwave=4110.78)
print, CALC_C2F(10.0,zpt=30.359,psize=0.258,effwave=3000.00)

END
