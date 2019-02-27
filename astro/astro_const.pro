FUNCTION ASTRO_CONST

; Collections
;http://www.harrisgeospatial.com/docs/Constant_System_Variable.html
;http://hea-www.harvard.edu/PINTofALE/pro/util/inicon.pr
;https://code.google.com/p/red-idl-cosmology/source/browse/trunk/astroc.pro?r=2
;A. Leroy constant.bat

ac={$
; PHYSICAL CONSTANTS
c:2.99792458d10,$       ; speed of light CGS (cm s-1)
h:6.6260755d-27,$       ; Planck's constant CGS (erg s)
G:6.67259d-8,$          ; Grav const CGS (cm3 g-1 s-2)
kb:1.380658d-16,$       ; Boltzmann's const CGS erg/K ; Boltzman constant
a:7.56591d-15,$         ; Radiation constant CGS (a=4sigma/c) in erg cm^-3 k^-4
sb:5.67051d-5,$         ; sigma (stefan-boltzmann const) CGS in erg cm^-2 k^-4 s^-1
qe:4.803206d-10,$      ; Charge of electron CGS in esu
ev:1.60217733d-12,$    ; Electron volt CGS erg
me:9.1093897d-28,$     ; electron mass CGS
mp:1.6726231d-24,$     ; proton mass CGS
mn:1.674929d-24,$       ; neutron mass CGS
mh:1.673534d-24,$       ; hydrogen mass CGS
amu:1.6605402d-24,$    ; atomic mass unit CGS
na:6.0221367d23,$      ; Avagadro's Number
sigmaT:6.6524616e-25,$     ; cm^2 ; Thomson cross section=8pi/3*re^2
alpha:7.297e-3,$          ; fine structure constant
rd:2.18e-11,$             ; Rydberg Constant in erg.
; ASTRONOMICAL CONSTANTS
msun:1.98900d+33,$        ; solar mass CGS
lsun:3.826e+33,$         ; solar luminosity erg/s
rsun:6.9599e+10,$        ; cm
tsun:5780.,$              ; Solar Temperature in K
mer:5.97400d+27,$       ; earth mass CGS
mm : 7.35000d+25,$        ; moon mass CGS
au : 1.496d13,$           ; astronomical unit CGS
pc : 3.085678d18,$          ; parsec CGS
yr : 3.155815d7,$         ; sidereal year CGS
ly: 9.463e17,$            ; light year in cm
rs : 6.9599d10,$          ; sun's radius CGS
rer : 6.378d8,$           ; earth's radius CGS
medd : 3.60271d+34,$      ; Eddington mass CGS
jy : 1.d-23,$             ; Jansky CGS in erg s^-1 cm^-2 Hz^-1
sterdeg : 3283,$          ; Degrees squared in a steradian
cm2perkkms_hi : 1.823d18,$  ; HI intensity -> column
ksun : 3.28,$             ; Absolute K magnitude of our sun (Binney & Merrifield)
restfreq_hi : 1420405751.786,$; HI 21cm transition in Hz
pc2au:206264.806,$
gfuv_cps2ujy:108.,$     ; galex converting cps to ujy
gnuv_cps2ujy:33.65,$    ; galex converting cps to ujy
; GENERAL CONSTANST
pi:3.14159265358979,$    ; better pi
omega:3.05d-4$           ; steradians per square degree
} 
return, ac

END

PRO TEST_ASTRO_CONST

ac=astro_const()
print,ac.c

END
