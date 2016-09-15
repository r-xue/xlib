PRO PSF2KERNEL_moffat,hires,kname,moffat=moffat
;+
;   moffat  par1:   FWHM in arcsec
;           par2:   beta
;-
if  n_elements(moffat) ne 2 then moffat=[1.5,2.0]

im=readfits(hires,hd)
getrot,hd,rotang,cdelt
psize=abs(cdelt[0]*60.*60.)
nxy=size(im,/d)
cxy=round((nxy-1.)/2.)

dist_ellipse,temp,nxy,cxy[0],cxy[1],1.0,0.
temp=temp*psize
print,'psize:',psize

m_fwhm=moffat[0]
m_beta=moffat[1]
m_x=temp
a=m_fwhm/2.0/((0.5^(-1/m_beta)-1)^0.5)
u=m_x/a
m_y=(1.+u^2.0)^(-m_beta)


target=repstr(hires,'.fits','_target.fits')
writefits,target,m_y,hd

psf2kernel,target,hires,kname,halfsz=60

;print,hires
;print,kname
;im1=readfits(hires,hd)
;im2=readfits(kname)
;knxy=size(im2,/d)
;kcxy=round((knxy-1.)/2.)
;print,knxy,kcxy
;im3=convol_fft(im1>0.0,im2[kcxy[0]-40:kcxy[0]+40,kcxy[1]-40:kcxy[1]+40])
;
;check=repstr(hires,'.fits','_targetcheck.fits')
;writefits,check,im3,hd

END




    ;if  strmatch(plist[i],'NDWFS*') then refim='../kernel/'+'Bw_NDWFS6_psfex_model.fits'
    ;if  strmatch(plist[i],'pcf*') then refim='../kernel/'+'I_pcf2_psfex_model.fits'
    ;PSF2KERNEL,refim,$
    ;    '../kernel/'+name+'_psfex_model.fits',$
    ;    '../kernel/'+name+'_kernel.fits'