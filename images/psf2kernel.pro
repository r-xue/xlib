
PRO PSF2KERNEL,lores,hires,kname,halfsz=halfsz
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


; for halfsz=30.0

im1=readfits(lores)
im2=readfits(hires)
nxy=size(im1,/d)
if  n_elements(halfsz) ne 1 then halfsz=floor(min(nxy)/2.0)
nxy=round((nxy-1.)/2.)
print,'halfsz: ',halfsz


im1=im1[nxy[0]-halfsz:nxy[0]+halfsz,nxy[0]-halfsz:nxy[0]+halfsz]
im2=im2[nxy[0]-halfsz:nxy[0]+halfsz,nxy[0]-halfsz:nxy[0]+halfsz]

;deconv_tool, image_deconv, deconv_info, IMAGE_OBS=im1, PSF_OBS=im2
max_entropy,im1,im2/total(im2),image_deconv,multipliers, FT_PSF=psf_ft
for i=1,100 do begin
    Max_Entropy, im1, im2/total(im2), image_deconv, multipliers, FT_PSF=psf_ft
    ;Max_Likelihood, im1, im2/total(im2), image_deconv
    ;if  i eq 1 then deconv_tool, image_deconv, deconv_info, IMAGE_OBS=im1, PSF_OBS=im2,sig=0.0
    ;deconv_tool, image_deconv, deconv_info
endfor

print,'raw kernel sum:',total(image_deconv)
image_deconv=image_deconv/total(image_deconv)
;if  total(im1-im2,/nan) eq 0 then begin
;    image_deconv=image_deconv*0.0
;    image_deconv[halfsz,halfsz]=1.0
;endif

writefits,kname,image_deconv

;psfmatch pcf2_bstar_R_pcf2_extract_median.fits  pcf1_bstar_R_pcf1_extract_median.fits  pcf2_bstar_R_pcf2_extract_median.fits  mf.fits  convolution=psf

END





    ;if  strmatch(plist[i],'NDWFS*') then refim='../kernel/'+'Bw_NDWFS6_psfex_model.fits'
    ;if  strmatch(plist[i],'pcf*') then refim='../kernel/'+'I_pcf2_psfex_model.fits'
    ;PSF2KERNEL,refim,$
    ;    '../kernel/'+name+'_psfex_model.fits',$
    ;    '../kernel/'+name+'_kernel.fits'