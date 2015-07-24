FUNCTION RADPROFILE_GROW,IM,XCEN,YCEN,RBIN,RRANGE=RRANGE,FAST=FAST
;+
;   use the median of the pixel at a similar radius distance to
;   replace masked pixels (required
;-

sz=size(im)
dist_ellipse,temp,sz[[1,2]],xcen,ycen,1.0,0.,/double

imfull=im
if  n_elements(rrange) eq 2 then begin
    tag=where(im ne im and temp le max(rrange) and temp ge min(rrange))
endif
if  n_elements(rrange) eq 0 then begin
    tag=where(im ne im)
endif
if  n_elements(rrange) eq 1 then begin
    tag=where(im ne im and temp le rrange)
endif

if  tag[0] ne -1 and ~keyword_set(fast) then begin
    checknan=im-im
    for i=0,n_elements(tag)-1 do begin
        ds=temp[tag[i]]
        tag0=where(abs(temp-ds)+checknan le rbin)
        if  n_elements(tag0) le (ceil(rbin)>2) then continue
        fill=median(im[tag0])
        ;RESISTANT_Mean,im[tag0],3,fill,fill_sigma
        
        imfull[tag[i]]=fill
    endfor
endif

if  tag[0] ne -1 and keyword_set(fast) then begin
    checknan=im-im
    temp=round(temp/rbin)
    for i=0,n_elements(tag)-1 do begin
        tag0=where(temp eq temp[tag[i]])
        if  n_elements(tag0) le (ceil(rbin)>2) then continue
        fill=median(im[tag0])
        ;RESISTANT_Mean,im[tag0],3,fill,fill_sigma
        imfull[tag[i]]=fill
    endfor
endif

return,imfull

END

PRO TEST_RADPROFILE_GROW

im=psf_gaussian(NPIXEL=501, FWHM=[100,100])

if  ~WindowAvailable(0) then window,0,xsize=900,ysize=300
cgloadct,3,/rev
cgimage,im,pos=[0.0,0.0,0.33,1.00],stretch=1,/noe

im[100:230,100:230]=!values.f_nan
cgimage,im,pos=[0.33,0.0,0.66,1.00],stretch=1,/noe

imnew=radprofile_grow(im,250,250,5.0,rrange=[0,100])
cgimage,imnew,pos=[0.66,0.0,0.99,1.00],stretch=1,/noe

END