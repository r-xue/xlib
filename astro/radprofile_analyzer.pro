FUNCTION RADPROFILE_ANALYZER,file,outname=outname,$
    skyrad=skyrad,nosub=nosub,$
    modrad=modrad,msrad=msrad,$
    psize=psize,skysub=skysub,$
    rbin=rbin,skysize=skysize,$
    center=center,extrad=extrad,$
    refxy=refxy,fitxy=fitxy,$
    silent=silent,sigscale=sigscale
;+
;   analyzing the center object radial profile in the FITS image
;   psize could be specified if no header is available.
;   
;   skyrad: sky region radius
;   nosub:  no sky cub
;   skysub: sky subtraction
;   
;   requirement for the provided image:
;       bad/mask pixels as mssing data (0/sat/badpix)
;   
;   object center could be:
;       image center (default)
;       specified center (refxy)
;       fitted center (fitcenter)
;   
;-

if  ~keyword_set(skyrad)    then skyrad=[5.,8.]
if  ~keyword_set(modrad)    then modrad=5.
if  ~keyword_set(skysize)   then skysize=20.0
if  ~keyword_set(sigscale)  then sigscale=10.0   

;   GET IMAGES SPECIFICATION

im=readfits(file,hd,/silent)
if  n_elements(psize) eq 0 then begin
    getrot,hd,rotang,cdelt
    psize=abs(cdelt[0]*60.*60.)
endif
if  n_elements(rbin) eq 0 then rbin=psize
sz=size(im)


;   FILL OBJECT CENTER PIXEL

xcen=(sz[1]-1)/2.
ycen=(sz[2]-1)/2.
if  n_elements(refxy) eq 2 then begin
    xcen=refxy[0]
    ycen=refxy[1]
endif
if  keyword_set(fitxy) then begin
    gcntrd,im,xcen,ycen,tx,ty,5.0/psize,/silent,maxgood=50000.0
    xcen=tx
    ycen=ty
endif
dist_ellipse,temp,sz[[1,2]],xcen,ycen,1.0,0.
temp=temp*psize
if  ~keyword_set(extrad)    then extrad=max(temp)

if  ~keyword_set(silent) then begin
    print,'image psize:',psize
    print,'used reference center: ',xcen,ycen
endif

;   FIND SKY PIXELS
;
skytag=where(temp gt skyrad[0] and temp le skyrad[1] and im eq im)
resistant_mean,im[skytag],3.0,skymod,skysig,num_rej
pixsig=skysig*sqrt((n_elements(skytag)-num_rej-1)*1.0)
;mmm,im[skytag],skymod,pixsig,skyskew

flag=(temp le skyrad[0] or im ne im)*1.0
rms_scale=rms_scale(im, sigscale/psize,flag=flag)
if  ~keyword_set(nosub) then begin
    im=im-skymod;median(im[skytag])
    print,'+remove sky',skymod
endif

;   MEASURING RADIAL PROFILE

if  ~keyword_set(silent) then begin
    print,replicate('-',40)
    print_struct,rms_scale
    print,string('rmin',format='(a8)'),$
      string('rmax',format='(a8)'),$
      string('rmedian',format='(a12)'),$
      string('rtotal',format='(a12)'),$
      string('rnpix',format='(a10)'),$
      string('sig1',format='(a10)'),$
      string('sig2',format='(a10)'),$
      string('sig0',format='(a10)'),$
      string('sig3',format='(a10)')
endif

ri=(findgen(extrad/rbin))*rbin
rp={center:ri,$                             ;   ring radius center
    ;------                                 ;   radial profile
    median:ri*!values.f_nan,$               ;   median value for each ring
    mean:ri*!values.f_nan,$                 ;   mean value for each ring
    sigma:ri*!values.f_nan,$                ;   stdev for pixels in each ring
    unc:ri*!values.f_nan,$                  ;   conservative uncertainties (large-scale background unc + statistical err)
    pertile10:ri*!values.f_nan,$            ;   cumulative flux 10p
    pertile25:ri*!values.f_nan,$            ;   cumulative flux 25p
    pertile75:ri*!values.f_nan,$            ;   cumulative flux 75p
    pertile90:ri*!values.f_nan,$            ;   cumulative flux 90p
    min:ri*!values.f_nan,$
    max:ri*!values.f_nan,$
    cflux:ri*!values.f_nan,$                ;   cumulative flux
    cflux_sig:ri*!values.f_nan,$            ;   cumulative flux error
    ri_np:ri*0.0,$                          ;   valid pixel in the ring
    ri_npt:ri*0.0,$                         ;   total pixel in the ring
    rc_np:ri*0.0,$                          ;   valid pixel in the circle
    rc_npt:ri*0.0,$                         ;   total pixel in the circle
    ;------                                 ;   image properties
    psigma:!values.f_nan,$                  ;   sigma value for the image
    fwhma:!values.f_nan,$                   ;   aperture defined fwhm
    bin:rbin,$                              ;   radius bin size
    psize:psize,$                           ;   pixel size
    skysig:rms_scale.rms_width,$            ;   large-scale sky uncernatines
    ;------                                 ;   model profile
    ims:im,$                                ;   sky subtracted images
    imr:temp,$                              ;   galactocentric distance
    im_median:im*!values.f_nan}             ;   model x
rp.cflux[0]=0.0
rp.cflux_sig[0]=0.0
rp.psigma=pixsig

for i=0,n_elements(ri)-1 do begin

    ;   MEASURE DIFF PROFILE
    
    tagring=where(temp le ri[i]+rbin/2.0 and temp ge ri[i]-rbin/2.0 and im eq im)
    if  tagring[0] ne -1 then begin
        yp=im[tagring]
        yp_pt=cgPercentiles(yp, Percentiles=[0.10,0.25, 0.5, 0.75,0.90])
        rp.median[i]=yp_pt[2]
        rp.mean[i]=mean(yp,/nan)
        rp.pertile10[i]=yp_pt[0]
        rp.pertile25[i]=yp_pt[1]
        rp.pertile75[i]=yp_pt[3]
        rp.pertile90[i]=yp_pt[4]
        rp.sigma[i]=medabsdev(yp)
        rp.ri_np[i]=n_elements(yp)
        ringspace=!dpi*((ri[i]+rbin/2.0)^2.0-(ri[i]-rbin/2.0>0.0)^2.0)
        ringnpix=ringspace/(psize)^2.0
        rp.ri_npt[i]=ringnpix
        rp.unc[i]=sqrt((rp.skysig)^2.0+(rp.psigma/sqrt(rp.ri_np[i]>1.0))^2.0)        
    endif

    tagcflux=where(temp lt ri[i] and im eq im)    
    if  tagcflux[0] ne -1 then begin
        rp.cflux[i]=total(im[tagcflux],/nan)
        rp.rc_np[i]=n_elements(tagcflux)
        circlespace=!dpi*(ri[i])^2.0
        circlepix=circlespace/(psize)^2.0
        rp.rc_npt[i]=circlepix
        rp.cflux_sig[i]=pixsig*(rp.rc_npt[i])^0.5+rp.rc_npt[i]*rp.skysig
    endif

    if  ~keyword_set(silent) then begin
        print,  string(ri[i]-rbin/2.0,format='(f8.2)'),$
                string(ri[i]+rbin/2.0,format='(f8.2)'),$
                string(rp.median[i],format='(f10.4)'),$
                string(rp.sigma[i],format='(f8.4)'),$
                string(rp.sigma[i]/sqrt(rp.ri_np[i]),format='(f8.4)'),$
                string(rp.skysig,format='(f8.4)'),$
                string(strtrim(round(rp.ri_np[i]),2)+'/'+strtrim(round(rp.ri_npt[i]),2),format='(a12)'),$
                string(rp.cflux[i],format='(f12.4)'),$
                string(strtrim(round(rp.rc_np[i]),2)+'/'+strtrim(round(rp.rc_npt[i]),2),format='(a12)')
    endif
    
endfor

imhalf=(im gt max(im[xcen-20:xcen+20,ycen-20:ycen+20])*0.5)
seg=label_region(imhalf)
tag=where(seg eq seg[xcen,ycen])
fwhm=(n_elements(tag)*psize^2.0/!dpi)^0.5*2.0
rp.fwhma=fwhm
if  ~keyword_set(silent) then begin
    print,'fwhma:',fwhm
endif
print,'fwhma:',fwhm
if  keyword_set(outname) then begin
    print,'radprofile_analyzer: save ',outname    
    save,rp,filename=outname
endif

return,rp

END


;
;if  ~keyword_set(silent) then print,replicate('-',40)
;
;ri_model=findgen(1000)*0.01
;u=ri_model^2.0/a[2]/a[3]/psize/psize
;rmean_model=a[1]/(u+1.0)^a[7]+a[0]
;
;fwhmm=-1
;fwhmd=-1
;
;;fwhmm=2.0*sqrt(a[2]*a[3])*sqrt(2.^(1/a[7])-1)*psize
;;print,'fwhm_m',fwhmm,'"'
;;fwhmd=2.0*interpol(ri,rmedian,0.5*max(rmedian,/nan))
;;print,'fwhm_d',fwhmd,'"'
;
;rms=skysig
;ringspace=!dpi*((ri+rbin/2.0)^2.0-(ri-rbin/2.0>0.0)^2.0)
;ringnpix=ringspace/(rbin)^2.0
;rsigma=rms/sqrt(ringnpix/3./3.)
;
;
;
;
;;   PRINT BASICS
;if  ~keyword_set(silent) then print,'1st cntrd: ',xcen,ycen
;if  ~keyword_set(silent) then print,'1st sky:',sky
;;   SKYSUB
;if  ~keyword_set(nosub) then begin
;    if  n_elements(skysub) ne 0 then begin
;        im=im-skysub
;    endif else begin
;        im=im-sky
;        skysub=sky
;;       sbg=readfits(name+'_sbg.fits',sbghd)
;;       print,'read background:',name+'_sbg.fits'
;;       im=im-sbg
;;       skysub=median(sbg)
;    endelse
;    if  ~keyword_set(silent) then print,'sky background subtracted'
;endif else begin
;    skysub=0.0
;    if  ~keyword_set(silent) then print,'no sky background subtracted'
;endelse
;   PROFILE MODELLING
;modradp=fix(modrad/psize)
;tim=im[fix(xcen)-modradp:fix(xcen)+modradp,fix(ycen)-modradp:fix(ycen)+modradp]
;weight=tim*0.0
;weight[*]=1.0
;weight[where(tim ne tim,/null)]=0.0
;tim[where(tim ne tim,/null)]=0.0
;parinfo={fixed:0}
;parinfo=replicate(parinfo,8)
;parinfo[0].fixed=1
;g2sol=mpfit2dpeak(tim,a,/moffat,weight=weight)
;es=a
;es[0]=0.0
;g2sol=mpfit2dpeak(tim,a,/moffat,weight=weight,ESTIMATE=es,parinfo=parinfo)
;xcen=a[4]+fix(xcen)-modradp
;ycen=a[5]+fix(ycen)-modradp
;if  ~keyword_set(silent) then print,'2nd cntrd: ',xcen,ycen
;if  ~keyword_set(silent) then print,'2nd sky:',a[0]
;
;xcen=round(xcen)
;ycen=round(ycen)
;
;if  keyword_set(center) then begin
;    xcen=xg*1.0
;    ycen=yg*1.0
;endif
;
;dist_ellipse,temp,sz[[1,2]],xcen,ycen,1.0,0.
;temp=temp*psize

