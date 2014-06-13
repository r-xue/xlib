FUNCTION CALC_CN, INT, LINE, HD=HD, $
  XCO=XCO, MSPPC2=MSPPC2, HELIUM=HELIUM

;+
; NAME:
;   CALC_CN
;
; PURPOSE:
;   calculate the column density according to the line brightness
;
; INPUTS:
;   INT         data (either 2d or 1D vector)
;   LINE        specify the observed line: e.g. CO1-0, HI21cm, CO2-1
;   [HD]        header for deriving jypb2k etc.. 
;               assuming INT in K*km/s if HD not presented 
;   [XCO]       change the default XCO factor: 2.0x10^20 cm^-2
;   /MSPPC2     change the output in units of M_sun/pc^2, default: cm^-2
;   /HELIUM     if the output inits are M_sun/pc^2, the helium mass is included
;   
; OUTPUTS:
;   DEN         column density (in cm^-2 or M_sun/pc^2)
;
;
; HISTORY:
;
;   20110306  RX  introduced
;   20130410  RX  add commnets and drop into xlib
;
;-

;kev=6.07*10.0^5/hibmaj/hinmin*int
;n_hi=kev*1.823*10^18
;den=n_hi*8.00635*10^-21

; INT->KEVIN
jypb2k=1.0
if  n_elements(hd) ne 0 then begin
  rd_hd, hd, s = s, c = c, /full
  if STRPOS(STRUPCASE(sxpar(hd, 'BUNIT')), 'JY/B') ne -1 then jypb2k=s.jypb2k
endif

den=int*jypb2k

; IF not in KM/S but in m/s then convert the value into km/s
if  n_elements(hd) ne 0 then begin
    if  STRPOS(STRUPCASE(sxpar(hd, 'BUNIT')), 'KM/S') eq -1 and $
        STRPOS(STRUPCASE(sxpar(hd, 'BUNIT')), 'M/S') ne -1 $
        then den=den/1000.0
endif

; KEVIN->CM^-2
if STRUPCASE(LINE) eq 'CO1-0' then begin
  if n_elements(xco) eq 0 then xco=2.0e20
  kkm2den=xco
  fac=2.0
endif
if STRUPCASE(LINE) eq 'CO2-1' then begin
  if n_elements(xco) eq 0 then xco=2.0e20/0.8
  kkm2den=xco
  fac=2.0
endif

if STRUPCASE(LINE) eq 'HI' then begin
  kkm2den=1.823e18
  fac=1.0
endif
if STRUPCASE(LINE) eq 'KKM/S' then begin
  kkm2den=1.0
  fac=1.0
endif

den=den*kkm2den

if keyword_set(MSPPC2) then begin
  den=8.00635e-21*den*fac
  if keyword_set(helium) then den=2.30/1.67*den
endif

return,den
End

PRO TEST_CAL_CN

im=readfits('/Users/ruixue/Workspace/sting/deproj1pc/n4151hi.sgm.mom0_smo23.fits',hd)

imout=calc_cn(100.0,hd,line='hi',/msppc2,/helium)
print,imout

END