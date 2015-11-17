FUNCTION RADPROFILE_GROW,IM,XCEN,YCEN,RBIN,RRANGE=RRANGE,FAST=FAST,addnoise=addnoise
;+
;   use the median of the pixel at a similar galactocentric distance to
;   replace masked pixels
;   note: this could be used to repair images if the source is known to be symetric.
;   
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
    for i=0,max(temp) do begin
        tag0=where(temp eq i)
        tag1=where(temp eq i and checknan ne checknan)
        ;if  n_elements(tag0) le (ceil(rbin)>2) then continue
        if  tag1[0] eq -1 then continue
        fill=median(im[tag0],/even)
        imfull[tag1]=fill
        if  n_elements(addnoise) ne 0 then imfull[tag1]=imfull[tag1]+addnoise*randomn(seed,n_elements(tag1))
;        mmm,im[tag0],tmpsky,tmpsig,tmpskew
;        imfull[tag1]=tmpsky+randomn(seed,n_elements(tag1))*tmpsig
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
tic
imnew=radprofile_grow(im,250,250,2.0,rrange=[0,100],/fast)
toc
cgimage,imnew,pos=[0.66,0.0,0.99,1.00],stretch=1,/noe

END