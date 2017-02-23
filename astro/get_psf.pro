FUNCTION GET_PSF,fun,$
    fwhm=fwhm,beta=beta,$
    NORMALIZE=NORMALIZE,outname=outname,$
    halfsz=halfsz,psize=psize
;+
; NAME:
;       GET_PSF
;       
; PURPOSE:
;       Create a parameterized PSF model
; 
; KEYWORDS:
;       FWHM        GAUSSIAN/MOFFAT FWHM in physical units
;       BETA        MOFFAT BETA
;       NORMALIZE   normalize the PSF model total(PSF)=1.0
;       OUTNAME     
;       HALFSZ      in physical units (default:100)
;       PSIZE       in physical units (default:1)
;       
; NOTE: (to be implemented)
;       use im_circularize.pro to do PSF azimuthal averaging
;       use hextract.pro to get x^2 dimension
;       
; HISTORY:
; 
;       20161229    RX introduced
;-

if  n_elements(halfsz) eq 0 then halfsz=100
if  n_elements(psize) eq 0 then psize=1.0

ndim=2*round(halfsz/psize)+1.0
ndim=[ndim,ndim]

if  strmatch(fun,'*gauss*',/f) then begin
    psf=psf_gaussian(npixel=ndim,fwhm=fwhm/psize,ndim=2,NORMALIZE=NORMALIZE)
endif

if  strmatch(fun,'*moff*',/f) then begin
    dist_ellipse,psfdist,ndim,round(halfsz/psize),round(halfsz/psize),1.,1.
    psfdist=psfdist*psize
    alpha=fwhm/2.0/((0.5^(-1.0/beta)-1)^0.5)
    u=psfdist/alpha
    psf=(1.+u^2.)^(-beta)
endif

if  keyword_set(normalize) then psf=psf/total(psf)

if  n_elements(outname) ne 0 then begin
    writefits,outname+'.fits',psf
endif

return,psf

END