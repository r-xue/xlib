FUNCTION GET_ZSPEC,wave,z=z,beta=beta,ew=ew,normal=normal,igmtau_scale=igmtau_scale
;+
; NAME:
;   GET_ZSPEC
;   
; PURPOSE:
;   SIMULATE a High-z galaxy spectrum
; 
; INPUT:
;   model.z         galaxy redshift
;        .igm       I14 igm scaling factor
;        
;   cont
;   
; NOTE:
;   this is a draft version.. not fully implemented yet
;-

if  n_elements(ew) eq 0 then ew=0.0
if  n_elements(beta) eq 0 then beta=-2.0
if  n_elements(z) eq 0 then z=2.78

ew_obs=ew*(1.+z)

w_lya=1216.*(1+z)
tag=where((wave-w_lya) le +10.0+w_lya*(10.0)/3e5 and (wave-w_lya) gt w_lya*(10.0)/3e5)
w_lya=min(wave[tag])
tag_lya=where(w_lya eq wave)


w_1700=1700.*(1.+z)
w_1220=1220.*(1.+z)
flam=(wave/w_1700[0])^(beta[0])


;   calculate line flux base on EW and Cont-level at the redder side.
flux_lya=flam[tag_lya]*ew_obs

;   IGM_tau was only applied to continuum
if  n_elements(igmtau_scale) eq 0 then igmtau_scale=1.0
igmtau_scale=igmtau_scale>0.0
flam=flam*exp(-calc_igmtau(wave,z,model='I14')*igmtau_scale)


;   apply line into the spectrum
if  tag[0] ne -1 then begin
    flam[tag_lya]=flam[tag_lya]+flux_lya/(abs(wave[tag_lya-1]-wave[tag_lya+1])/2.0)
endif

flam=flam>1e-10
fnu=flam*wave^2.0/(3.0e18)


w_1700=1700.*(1.+z)
if  n_elements(normal) eq 1 then begin
    wave_n=normal*(1.+z)
    tmp=min(abs(wave-wave_n),tag_n)
    fnu=fnu/fnu[tag_n]
endif



return,fnu

END

PRO TEST_GET_ZSPEC


wave=findgen(8000)+2000
z=3.045
spec=get_zspec(wave,z=z,beta=-1.523,ew=13.76,normal=1700*(1+z),igmtau_scale=2.3)

dv=100 ; km/s
dlam=dv/3e5*1216.
dlam=dlam*(1+z)
lsf=psf_gaussian(npixel=round(dlam)*4.+1,fwhm=dlam,ndim=1,/normal)
spec_con=convol(spec,lsf)

plot,wave,spec_con,/ylog,xrange=[2000,10000],xstyle=1,yrange=[1e-3,10],ystyle=1





END