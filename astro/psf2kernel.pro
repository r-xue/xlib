
PRO PSF2KERNEL,lores,hires,kname
;+
;   derive the convolution kernel based on target and orginal PSFs.
;   lores:  low resolution PSF
;   hires:  high resolution PSF
;   kname:  output kernel file names
;-
;lores='pcf1_bstar_R_pcf1_extract_median.fits'
;hires='pcf2_bstar_R_pcf2_extract_median.fits'
;kname='R_pcf2_to_R_pcf2'
;   XHS_SATCK_EXTRACT_MODEL_KERNEL,'pcf1_bstar_R_pcf1_extract_median.fits'
im1=readfits(lores)
im2=readfits(hires)
nxy=size(im1,/d)
nxy=round((nxy-1.)/2.)

im1=im1[nxy[0]-30:nxy[0]+30,nxy[0]-30:nxy[0]+30]
im2=im2[nxy[0]-30:nxy[0]+30,nxy[0]-30:nxy[0]+30]

;deconv_tool, image_deconv, deconv_info, IMAGE_OBS=im1, PSF_OBS=im2
max_entropy,im1,im2/total(im2),image_deconv,multipliers, FT_PSF=psf_ft
for i=1,100 do begin
    Max_Entropy, im1, im2/total(im2), image_deconv, multipliers, FT_PSF=psf_ft
    ;Max_Likelihood, im1, im2/total(im2), image_deconv
    ;if  i eq 1 then deconv_tool, image_deconv, deconv_info, IMAGE_OBS=im1, PSF_OBS=im2,sig=0.0
    ;deconv_tool, image_deconv, deconv_info
endfor

image_deconv=image_deconv/total(image_deconv)
if  total(im1-im2,/nan) eq 0 then begin
    image_deconv=image_deconv*0.0
    image_deconv[30,30]=1.0
endif

writefits,kname,image_deconv

;psfmatch pcf2_bstar_R_pcf2_extract_median.fits  pcf1_bstar_R_pcf1_extract_median.fits  pcf2_bstar_R_pcf2_extract_median.fits  mf.fits  convolution=psf

END