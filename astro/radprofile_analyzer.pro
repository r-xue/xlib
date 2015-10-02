FUNCTION RADPROFILE_ANALYZER,file,outname=outname,$
    skyrad=skyrad,nosub=nosub,$
    modrad=modrad,msrad=msrad,$
    psize=psize,skysub=skysub,$
    rbin=rbin,skysize=skysize,$
    center=center,extrad=extrad
;+
;   analyzing the center object radial profile in the FITS image
;   psize could be specified if no header is available.
;   
;   skyrad: sky region radius
;   nosub:  no sky cub
;   skysub: sky subtraction
;   
;-

if  ~keyword_set(skyrad)    then skyrad=[5.,8.]
if  ~keyword_set(modrad)    then modrad=5.
if  ~keyword_set(extrad)    then extrad=20.   ;   extract the radius profile to <extrad>
if  ~keyword_set(skysize)   then skysize=20.0

;   GET IMAGES SPECIFICATION
im=readfits(file,hd)
if  n_elements(psize) eq 0 then begin
    getrot,hd,rotang,cdelt
    psize=abs(cdelt[0]*60.*60.)
endif

if  n_elements(rbin) eq 0 then rbin=psize

sz=size(im)

;   BLANKING (BOTH SAT AND MISSING DATA)
im[where(im eq 50000.0,/null)]=!values.f_nan
;im[where(im eq 0.0,/null)]=!values.f_nan

;   FIND XCEN YCEN
xg=(sz[1]-1)/2.
yg=(sz[2]-1)/2.
gcntrd,im,xg,yg,xcen,ycen,5.0/psize,/silent,maxgood=50000.0
dist_ellipse,temp,sz[[1,2]],xcen,ycen,1.0,0.,/double
temp=temp*psize

;   FIND SKY PIXELS
skytag=where(temp gt skyrad[0] and temp le skyrad[1] and im ne 0 and im eq im)
print,'sky pixels:',strtrim(n_elements(skytag),2),'/',strtrim(n_elements(temp),2)
stat=im[skytag]
msky=median(stat)
rmsa=robust_sigma(stat,goodvec=goodvec)
rms0=robust_sigma(stat,goodvec=goodvec,/zero)
print,'sky median:',strtrim(msky,2)
print,'sky robrms:',strtrim(rmsa,2),'/',strtrim(rms0,2)
mmm,stat,sky,skysig,temp2
print,'sky mmmsky:',sky
print,'sky mmmrms:',skysig

;   PRINT BASICS
print,'1st cntrd: ',xcen,ycen
print,'1st sky:',sky

;+++
name=repstr(file,'.fits','')
sexconfig=INIT_SEX_CONFIG()
sexconfig.detect_thresh=1.00
sexconfig.analysis_thresh=1.00
sexconfig.pixel_scale=psize
sexconfig.DETECT_MINAREA=(5.0+4.0)*9.0
sexconfig.seeing_fwhm=1.25
sexconfig.CLEAN_PARAM=1.0 ; 2.0
sexconfig.PARAMETERS_NAME='/Users/Rui/GDrive/Worklib/projects/xlib/etc/xlib.sex.param'
sexconfig.BACK_SIZE=round(skysize/psize)    ; in pixels
sexconfig.BACK_FILTERSIZE=5.0
sexconfig.catalog_name=name+'.cat'
sexconfig.FILTER_NAME='/Users/Rui/GDrive/Worklib/projects/xlib/etc/gauss_3.0_5x5.conv'
sexconfig.CATALOG_TYPE='FITS_LDAC'
sexconfig.checkimage_type='SEGMENTATION,BACKGROUND'
sexconfig.checkimage_name=name+'_seg.fits'+','+name+'_sbg.fits'
sexconfig.DEBLEND_NTHRESH=64
sexconfig.DEBLEND_MINCONT=0.0001    ; better use a small value for debelending
sexconfig.PSFDISPLAY_TYPE=''
im_sex,name+'.fits',sexconfig
;++++


;   SKYSUB
if  ~keyword_set(nosub) then begin
    if  n_elements(skysub) ne 0 then begin
      im=im-skysub
    endif else begin
      
      im=im-sky
      skysub=sky
      
;      sbg=readfits(name+'_sbg.fits',sbghd)
;      print,'read background:',name+'_sbg.fits'
;      im=im-sbg
;      skysub=median(sbg)
    endelse
    print,'sky background subtracted'
endif else begin
    skysub=0.0
    print,'no sky background subtracted'
endelse

;   PROFILE MODELLING
modradp=fix(modrad/psize)
tim=im[fix(xcen)-modradp:fix(xcen)+modradp,fix(ycen)-modradp:fix(ycen)+modradp]
weight=tim*0.0
weight[*]=1.0
weight[where(tim ne tim,/null)]=0.0
tim[where(tim ne tim,/null)]=0.0
parinfo={fixed:0}
parinfo=replicate(parinfo,8)
parinfo[0].fixed=1
g2sol=mpfit2dpeak(tim,a,/moffat,weight=weight)
es=a 
es[0]=0.0
g2sol=mpfit2dpeak(tim,a,/moffat,weight=weight,ESTIMATE=es,parinfo=parinfo)
xcen=a[4]+fix(xcen)-modradp
ycen=a[5]+fix(ycen)-modradp
print,'2nd cntrd: ',xcen,ycen
print,'2nd sky:',a[0]

xcen=round(xcen)
ycen=round(ycen)

if  keyword_set(center) then begin
    xcen=xg*1.0
    ycen=yg*1.0
endif

dist_ellipse,temp,sz[[1,2]],xcen,ycen,1.0,0.
temp=temp*psize

;   MEASURING RADIAL PROFILE
ri=(findgen(extrad/rbin))*rbin
rmedian=[]
rquarlow=[]
rquarup=[]
rmean=[]
rrms=[]
rcflux=[]
rcflux_sig=[]

print,replicate('-',40)
print,string('rmin',format='(a8)'),$
  string('rmax',format='(a8)'),$
  string('rmedian',format='(a12)'),$
  string('rtotal',format='(a12)'),$
  string('rnpix',format='(a10)'),$
  string('sig1',format='(a10)'),$
  string('sig2',format='(a10)'),$
  string('sig0',format='(a10)'),$
  string('sig3',format='(a10)')
for i=0,n_elements(ri)-1 do begin
    xp=ri[i]
    tagring=where(temp le ri[i]+rbin/2.0 and temp ge ri[i]-rbin/2.0 and im eq im)
    tagcflux=where(temp le ri[i] and im eq im)
    ;if  tagring[0] eq -1 then continue
    yp=im[tagring]
    dy=cgPercentiles(yp, Percentiles=[0.25, 0.5, 0.75])
    rmedian=[rmedian,median(yp)]
    rrms=[rrms,medabsdev(yp)]
    
    rcflux=[rcflux,total(im[tagcflux])]
    rcflux_sig=[rcflux_sig,skysig*(n_elements(tagcflux)*(1.50/psize))^0.5]
    
    ;rquarlow=[rquarlow,dy[0]]
    ringspace=!dpi*((ri[i]+rbin/2.0)^2.0-(ri[i]-rbin/2.0>0.0)^2.0)
    ringnpix=ringspace/(psize)^2.0
    ringsig=sqrt((3.0*rms0/sqrt(ringnpix))^2.0+skysig^2.0)
    print,  string(ri[i]-rbin/2.0,format='(f8.2)'),$
            string(ri[i]+rbin/2.0,format='(f8.2)'),$
            string(median(yp),format='(f15.4)'),$
            string(total(im[tagcflux]),format='(f15.4)'),$
            string(ringnpix,format='(f10.1)'),$
            string(rms0/sqrt(ringnpix),format='(e10.2)'),$
            string(ringsig,format='(e10.2)'),$
            string(rms0,format='(e10.2)'),$
            string(skysig,format='(e10.2)')
    
    rquarlow=[rquarlow,dy[0]]         
    rquarup=[rquarup,dy[2]]
                
    rsiglow=[rquarlow,median(yp)-ringsig]
    rsigup=[rquarup,median(yp)+ringsig]
    
    rmean=[rmean,mean(yp)]
endfor
print,replicate('-',40)

ri_model=findgen(1000)*0.01
u=ri_model^2.0/a[2]/a[3]/psize/psize
rmean_model=a[1]/(u+1.0)^a[7]+a[0]

fwhmm=2.0*sqrt(a[2]*a[3])*sqrt(2.^(1/a[7])-1)*psize
print,'fwhm_m',fwhmm,'"'
fwhmd=2.0*interpol(ri,rmedian,0.5*max(rmedian,/nan))
print,'fwhm_d',fwhmd,'"'

rms=rms0
ringspace=!dpi*((ri+rbin/2.0)^2.0-(ri-rbin/2.0>0.0)^2.0)
ringnpix=ringspace/(rbin)^2.0
rsigma=3.0*rms/sqrt(ringnpix)


rp={center:ri,$
    bin:rbin,$
    psize:psize,$
    median:rmedian,$
    cflux:rcflux,$
    cflux_sig:rcflux_sig,$
    quarlow:rquarlow,$
    quarup:rquarup,$    
    mean:rmean,$
    sigma:rsigma,$
    rms:rrms,$
    psigma:rms,$
    fwhmm:fwhmm,$
    fwhmd:fwhmd,$
    sky:sky,$
    skysub:skysub,$
    imr:temp,$
    ims:im,$
    center_model:ri_model,$
    mean_model:rmean_model}

if  keyword_set(outname) then begin
    print,replicate('-',40)
    print,'save ',outname    
    save,rp,filename=outname
    print,replicate('-',40)
endif

return,rp

END

