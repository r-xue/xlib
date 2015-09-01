FUNCTION CALC_MASS, INT, LINE, DIS, HELIUM=HELIUM,XCO=XCO

;+
; NAME:
;   CALC_MASS
;
; PURPOSE:
;   calculate gas mass from CO or HI
;
; INPUTS:
;   INT         data (either 2d or 1D vector)
;   LINE        specify the observed line: e.g. CO1-0, HI21cm, CO2-1
;   DIS         galaxy distance in Mpc
;   [XCO]       change the default XCO factor: 2.0x10^20 cm^-2
;   /HELIUM     if the output inits are M_sun/pc^2, the helium mass is included
;   
; OUTPUTS:
;   gas         gas mass in Msun
;
;
; HISTORY:
;
;   20150208  RX  introduced
;
;-


; Jy km s^-1 -> Msun
if STRUPCASE(LINE) eq 'CO1-0' then begin
    if n_elements(xco) eq 0 then xco=2.0e20
    gas=1.1e4*dis^2.0*int*(xco/2.8e20)
endif
if STRUPCASE(LINE) eq 'HI' then begin
    gas=2.36e5*dis^2.0*int
endif

if keyword_set(helium) then gas=2.30/1.67*gas

return,gas

End

PRO TEST_CALC_MASS

; NGC3486
print,calc_mass(57.,'CO1-0',15.6)

END
