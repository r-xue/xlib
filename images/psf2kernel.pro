
PRO PSF2KERNEL,lores,hires,kname,halfsz=halfsz,verify=verify,verbose=verbose
;+
;   derive the convolution kernel based on target and orginal PSFs.
;   lores:  low resolution PSF
;   hires:  high resolution PSF
;   kname:  output kernel file names
;-

; for halfsz=30.0

im1=readfits(lores,/silent)
im2=readfits(hires,/silent)

nxy=size(im1,/d)
if  n_elements(halfsz) ne 1 then halfsz=floor(min(nxy)/2.0)
nxy=round((nxy-1.)/2.)
if  keyword_set(verbose) then print,'halfsz: ',halfsz
if  keyword_set(verbose) then print,'hresum: ',total(im2)

subim1=im1[nxy[0]-halfsz:nxy[0]+halfsz,nxy[0]-halfsz:nxy[0]+halfsz]
subim2=im2[nxy[0]-halfsz:nxy[0]+halfsz,nxy[0]-halfsz:nxy[0]+halfsz]

max_entropy,subim1,subim2/total(subim2),image_deconv,multipliers, FT_PSF=psf_ft
;deconv_tool, image_deconv, deconv_info, IMAGE_OBS=im1, PSF_OBS=im2
for i=1,100 do begin
    Max_Entropy, subim1, subim2/total(subim2), image_deconv, multipliers, FT_PSF=psf_ft
    ;Max_Likelihood, im1, im2/total(im2), image_deconv
    ;if  i eq 1 then deconv_tool, image_deconv, deconv_info, IMAGE_OBS=im1, PSF_OBS=im2,sig=0.0
    ;deconv_tool, image_deconv, deconv_info
endfor
raw_sum=total(image_deconv)
if  raw_sum ne raw_sum or raw_sum eq 0 or total(subim1-subim2,/nan) eq 0 then begin
    image_deconv[*]=0.0
    image_deconv[nxy[0],nxy[1]]=1.0
endif else begin
    image_deconv=image_deconv/total(image_deconv)
endelse

writefits,kname,image_deconv

if  keyword_set(verify) then begin
    tmp=repstr(kname,'.fits','_verify.fits')
    writefits,tmp,convol_fft(im2,image_deconv)
endif

END
