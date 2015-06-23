FUNCTION SIG2RMS, fwhm=fwhm,psf=psf,nonormalize=nonormalize
;+
; NAME:
;   SIG2RMS
;
; PURPOSE:
;   calculate the conversion factor: 
;     FROM, the noise level (1sigma) of an image with independent Gaussian noise
;     TO, the expected RMS value of the smoothed image
;   useful to derive the "decorrelated" noise level in an image
;   
; INPUTS:
;
;   FWHM    in units of pixel size
;   [PSF]   a psf image having the same pixel size of the data image  
;
; OUTPUTS:
;   
;   fac
;
; HISTORY:
;
;   20130405  RX  introduced
;-

if  n_elements(psf) eq 0 $ 
  then ipsf=psf_gaussian(npixel=5*fwhm+1,fwhm=fwhm,/NORMALIZE,/DOUBLE,ndimen=2) $
  else $
  if not keyword_set(nonormalize) then ipsf=psf/total(psf,/nan) else ipsf=psf
fac=sqrt(total(ipsf*ipsf,/nan))

return,fac

END

PRO TEST_SIG2RMS

  ; simulate smoothing effects
  fwhm1=[10.,10.]
  psf1=psf_gaussian(npixel=5*fwhm1+1,fwhm=fwhm1,/NORMALIZE,/DOUBLE,ndimen=2)
  fwhm2=[20.,20.]
  psf2=psf_gaussian(npixel=5*fwhm2+1,fwhm=fwhm2,/NORMALIZE,/DOUBLE,ndimen=2)
  fwhm3=sqrt(fwhm1^2+fwhm2^2)
  psf3=psf_gaussian(npixel=5*fwhm3+1,fwhm=fwhm3,/NORMALIZE,/DOUBLE,ndimen=2)

  im=fltarr(1000,1000)
  nim=im+randomn(seed,1000,1000)
  print,size(nim)
  
  c1nim=convol_fft(nim,psf1)
  c2nim=convol_fft(c1nim,psf2)
  c3nim=convol_fft(nim,psf3)
  
  window,0,xsize=1200,ysize=300
  cgimage,nim,position=[0.0,0.0,0.25,1.0],/noe      ;true
  cgimage,c1nim,position=[0.25,0.0,0.5,1.0],/noe    ;orginal
  cgimage,c2nim,position=[0.5,0.0,0.75,1.0],/noe    ;observed
  cgimage,c3nim,position=[0.75,0.0,1.0,1.0],/noe    ;smoothed
  
  print,stddev(c3nim),stddev(c2nim)
  print,'mean,simulated,predicted:'
  print,"orginal IM:  ",mean(c1nim),stddev(c1nim),stddev(nim)*sig2rms(psf=psf1)
  print,"smoothed IM [wrong!]: ",mean(c2nim),stddev(c2nim),stddev(c1nim)*sig2rms(psf=psf2)
  print,"smoothed IM [wrong!]: ",mean(c2nim),stddev(c2nim),stddev(c1nim)/sig2rms(psf=psf1)*sig2rms(psf=psf2)
  print,"smoothed IM [right!]: ",mean(c2nim),stddev(c2nim),stddev(c1nim)/sig2rms(psf=psf1)*sig2rms(psf=psf3)

END

