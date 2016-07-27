FUNCTION IM_CIRCULARIZE,IM,XCEN,YCEN,$
    sampling=sampling,keepsamping=keepsamping

nxy=size(im,/d)
if  n_elements(sampling) eq 0 then sampling=1
im_new=rebin(im,nxy[0]*sampling,nxy[1]*sampling,/sample)
nxy_new=size(im_new,/d)
xcen_new=xcen*sampling+(1-(sampling mod 2))*0.5
ycen_new=ycen*sampling+(1-(sampling mod 2))*0.5



dist_ellipse,temp,nxy_new,xcen_new,ycen_new,1.0,0.
temp=round(temp)
im_new_fill=im_new*!values.f_nan

for i=0,max(temp) do begin
    tag0=where(temp eq i)
    if  tag0[0] eq -1 then continue
    ;fill=median(im_new[tag0],/even)
    fill=mean(im_new[tag0],/nan)
    im_new_fill[tag0]=fill
endfor

if  ~keyword_set(keepsamping) then begin
    im_new_fill=rebin(im_new_fill,nxy[0],nxy[1],/sample)
endif

return,im_new_fill

END


PRO TEST_IM_CIRCULARIZE

im=readfits('Subaru-IB427_psfzone01_psfex.fits',hd)
nxy=size(im,/d)
cxy=(nxy-1)/2

sampling=10.0
imout=im_circularize(im,cxy[0],cxy[1],samp=samp)
;hrebin,im,hd,newim,newhd,nxy[0]*sampling,nxy[1]*sampling,/sample
writefits,'im_new_s5.fits',imout,hd

sampling=1.0
imout=im_circularize(im,cxy[0],cxy[1],samp=samp)
;hrebin,im,hd,newim,newhd,nxy[0]*sampling,nxy[1]*sampling,/sample
writefits,'im_new_s.fits',imout,hd


END