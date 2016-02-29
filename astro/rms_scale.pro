FUNCTION RMS_SCALE,im,width,flag=flag
;+
;   check image uncernties at specific spartial scale
;-
if  ~keyword_set(flag) then flag=im*0.0

im_sky=im
im_sky[where(flag ne 0.0,/null)]=!values.f_nan
im_smo=smooth(im_sky,width,/nan,/edge_mirror)
;im_smo=filter_image(im_sky,smooth=width,/all_pix)

im_smo[where(flag ne 0.0,/null)]=!values.f_nan
;writefits,'test1.fits',im_sky
;writefits,'test2.fits',im_smo
nxy=size(im,/d)
nxy=floor(nxy/width)
im_smo_sample=congrid(im_smo,nxy[0],nxy[1])
rms_scale={ width:width,$
            rms_width:STDDEV(im_smo_sample,/nan),$
;            rms0_width:robust_sigma(im_smo,/zero),$
            mean_width:mean(im_smo,/nan),$
            median_width:median(im_smo),$
            rms_im:STDDEV(im_sky,/nan),$
            rms_mean:stddev(im_sky,/nan)/sqrt(total(im_sky eq im_sky)*1.0),$
            mean_im:mean(im_sky,/nan),$
            median_im:median(im_sky)}
return,rms_scale

END

PRO TEST_RMS_SCALE

im=readfits('lab_lae_all/lab_lae_all_uvc_gro_median.fits',hd)
sz=size(im)
getrot,hd,rotang,cdelt
psize=abs(cdelt[0]*60.*60.)
xcen=(sz[1]-1)/2.
ycen=(sz[2]-1)/2.
dist_ellipse,temp,sz[[1,2]],xcen,ycen,1.0,0.
temp=temp*psize

print,"width,rms_width,mean_width,"
flag=(temp le 10.0)*1.0
flag=(im ne im)*1.0
rms_s=rms_scale(im,4./psize,flag=flag)
PRINT_STRUCT,rms_s
im=im*0.0+randomn(seed,sz[1],sz[2])
rms_s=rms_scale(im,10./psize,flag=flag)
PRINT_STRUCT,rms_s
;im_sky=im
;im_sky[skyrad]=!values.f_nan
;im_smo[skyrad]=!values.f_nan
;writefits,'test.fits',im_smo
;
;skyrad=where(temp gt 10.0 and temp le 20.0)


END 

