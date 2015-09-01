FUNCTION RADPROFILE_ANALYZER,file,outname=outname,$
    skyrad=skyrad,nosub=nosub,$
    modrad=modrad,msrad=msrad,$
    psize=psize
;+
;   analyzing the center object radial profile in the FITS image
;   psize could be specified if no header is available.
;-

if  ~keyword_set(skyrad)    then skyrad=[5.,8.]
if  ~keyword_set(modrad)    then modrad=5.
if  ~keyword_set(extrad)    then extrad=10.   ;   extract the radius profile to <extrad>

;   GET IMAGES SPECIFICATION
im=readfits(file,hd)
if  n_elements(psize) eq 0 then begin
    getrot,hd,rotang,cdelt
    psize=abs(cdelt[0]*60.*60.)
endif

sz=size(im)

;   BLANKING (BOTH SAT AND MISSING DATA)
im[where(im eq 50000.0,/null)]=!values.f_nan
im[where(im eq 0.0,/null)]=!values.f_nan

;   FIND XCEN YCEN
xg=sz[1]/2.
yg=sz[2]/2.
gcntrd,im,xg,yg,xcen,ycen,5.0/psize,/silent,maxgood=50000.0
dist_ellipse,temp,sz[[1,2]],xcen,ycen,1.0,0.,/double
temp=temp*psize

;   FIND SKY PIXELS
skytag=where(temp gt skyrad[0] and temp le skyrad[1] and im ne 0 and im eq im)
print,'sky pixels:',strtrim(n_elements(skytag),2),'/',strtrim(n_elements(temp),2)
stat=im[skytag]
sky=median(stat)
rmsa=robust_sigma(stat,goodvec=goodvec)
rms0=robust_sigma(stat,goodvec=goodvec,/zero)
print,'sky median:',strtrim(sky,2)
print,'sky robrms:',strtrim(rmsa,2),'/',strtrim(rms0,2)
mmm,stat,sky,skysig,temp2
print,'sky mmmsky:',sky
print,'sky mmmrms:',skysig

;   PRINT BASICS
print,'1st cntrd: ',xcen,ycen
print,'1st sky:',sky

;   SKYSUB
if  ~keyword_set(nosub) then begin
    im=im-sky
    print,'sky background subtracted'
endif

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
dist_ellipse,temp,sz[[1,2]],xcen,ycen,1.0,0.
temp=temp*psize

;   MEASURING RADIAL PROFILE
ri=(findgen(extrad/psize))*psize
rmedian=[]
rquarlow=[]
rquarup=[]
rmean=[]

print,replicate('-',40)
for i=0,n_elements(ri)-1 do begin
    xp=ri[i]
    tagring=where(temp le ri[i]+psize/2.0 and temp ge ri[i]-psize/2.0 and im eq im)
    ;if  yp[0] eq -1 then continue
    yp=im[tagring]
    dy=cgPercentiles(yp, Percentiles=[0.25, 0.5, 0.75])
    rmedian=[rmedian,median(yp)]
    ;rquarlow=[rquarlow,dy[0]]
    ringspace=!dpi*((ri[i]+psize/2.0)^2.0-(ri[i]-psize/2.0>0.0)^2.0)
    ringnpix=ringspace/(psize)^2.0
    ringsig=sqrt((3.0*rms0/sqrt(ringnpix))^2.0+skysig^2.0)
    print,  string(ri[i]-psize/2.0,format='(f8.4)'),$
            string(ri[i]+psize/2.0,format='(f8.4)'),$
            string(ringnpix,format='(f8.4)'),$
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
ringspace=!dpi*((ri+psize/2.0)^2.0-(ri-psize/2.0>0.0)^2.0)
ringnpix=ringspace/(psize)^2.0
rsigma=3.0*rms/sqrt(ringnpix)


rp={center:ri,$
    bin:psize,$
    median:rmedian,$
    quarlow:rquarlow,$
    quarup:rquarup,$    
    mean:rmean,$
    sigma:rsigma,$
    psigma:rms,$
    fwhmm:fwhmm,$
    fwhmd:fwhmd,$
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

