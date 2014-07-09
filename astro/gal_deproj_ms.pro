PRO GAL_DEPROJ_MS2,ref=ref,$
    select=select,gselect=gselect,$
    box=box,$
    ores=ores,mres=mres,out=out,MSPPC2=MSPPC2, HELIUM=HELIUM,$
    nodp=nodp,ra=ra,dec=dec

;+
; NAME:
;   GAL_DPROJ_MS
;
; PURPOSE:
;   make measurement from deprojected commom resolution dataset
;  (will fetch a set of fits data from the current working directory)
;  box in arcsec
;  
; INPUT:
;   nodp:   by default: the program will search for files like "*smoXX_dp.fits"
;           /nodp will let the program search for files with name "*smoXX.fits" 
;   box:    sample template size in arcsec
; OUT
;   mesaurement structure:
;   st.gal  galaxy name
;   st.....
; 
; Note:
;   GALEX images in CPS per pixel, CPS->Jy conversion could be found at
;   http://galex.stsci.edu/GR6/?page=faq
;   The original pixel is 1.5" size.
;   
; Regard to the metallicity from Moustakas et al. 2010
;   Log(O/H)+12     [KK04/PT05]:    center metallicity from mean(r/r25<0.1), or L-Z value, in table 9
;   Log(O/H)+12M    [KK04/PT05]:    characteristic metallicity from mean(0.1<r/r25<0.1), or L-Z value, in table 9
;   Log(O/H)+12C    [KK04/PT05]:    center metallicity for gradient model in table 8
;   Log(O/H)+12G    [KK04/PT05]:    slope for gradient model in table 8
;   When Log(O/H)+12G=0, Log(O/H)+12C=Log(O/H)+12M=Log(O/H)+12 will be a mean value across the entire area with Z measurements
;   In the letter paper, we used mean(KK04/PT05) and the gradient results (if available)
;   The previous L-Z figure used the characteristic metallicity for plotting
; 
; GAL_DEPROJ_MS,'SGP',box=1024,reftype=6,out='st_ms',/MSPPC2
; GAL_DEPROJ_MS,'TGP',box=1024,reftype=17,out='thing_ms',/MSPPC2
; GAL_DEPROJ_MS,'SGP',box=1024,reftype=6,out='st_ms',/MSPPC2
; GAL_DEPROJ_MS,'SGP',box=1024,reftype=4,out='st_ms'
; 
; GAL_DEPROJ_MS,'MGP',reftype=1,out='mcs_ms',/msppc2,/nodp
; GAL_DEPROJ_MS,'MGP',reftype=1,out='mcs_ms',/nodp
; 
; gal_deproj_ms2,ref='TGP',select=[17,18,19,20,27,28,29],box=1024,out='test.ms',/nodp
; gal_deproj_ms2,ref='SGP',select=[12,13,6,7]-2,box=1024,out='test.ms',/nodp
; gal_deproj_ms2,ref='MGP',select=[3,4,6,7]-2,box=4e4,out='test.ms',/nodp
; 
; gal_deproj_ms2,ref='TGP',select=[19,20],box=1024,out='tgp.ms',/nodp,ores=''
; gal_deproj_ms2,ref='SGP',select=[12,13]-2,box=1024,out='sgp.ms',/nodp,ores=''
; 
; gal_deproj_ms2,ref='TGP',select=[17,18,19,20],box=1024,out='tgp.ms',/nodp,ores='_smo*'
; gal_deproj_ms2,ref='SGP',select=[6,7,12,13,2,3,4,5]-2,box=1024,out='sgp.ms',/nodp,ores='_smo*'
;-



if n_elements(ores) eq 0 then ores='_smo*'
if n_elements(mres) eq 0 then mres='*'
if n_elements(out) eq 0 then out='all_ms'
if n_elements(select_ref) eq 0 then select_ref=0
dp='_dp'
if keyword_set(nodp) then dp=''

; SETUP
fitsloc='./'
;fn='*_smo*_dp.fits'
;fl=file_search(fitsloc+fn,count=ct)
xco=2.0e20


; LOAD ST STRUCTURE
gal_struct_build,ref,s,h,/silent
if n_elements(gselect) eq 0 then gselect=indgen(n_elements(s.(0)))

; LOOP THROUGH ALL GALAXIE
all_ms=[]
; note: each sampling point is a basic set of structure tags like below     
ms = { $
  galno:"", $
  inc:!values.d_nan,$
  d25:!values.d_nan,$           ; d25 value
  rad:!values.d_nan,$
  as2pc:!values.d_nan,$
  res:!values.d_nan,$
  xoffset:!values.d_nan,$       ; ra offset from center for the sampling point
  yoffset:!values.d_nan,$       ; dec offset from center  for the sampling point
  ohkk04:!values.d_nan,$        ; theoretical approach 
  ohpt05:!values.d_nan $        ; emperical approach
  }
; attach more tags
types=gal_deproj_fileinfo(ref)
if n_elements(select) eq 0 then select=indgen(n_elements(types))
subtypes=types[select]
foreach type, subtypes do begin
  print,type.tag
  ms=create_struct(ms,type.tag,!values.d_nan)
endforeach


foreach ind,gselect do begin
  
  gal=s.(where(h eq 'Galaxy'))[ind]
  galno = strtrim(gal,2)
  print, replicate('-',40)
  print, 'Working on galaxy number ',galno,' index',ind
  print, replicate('-',40)
  dist=s.(where(h eq 'Distance (Mpc)'))[ind]*10.^6
  as2pc=dist/206264.806
  inc=s.(where(h eq 'Adopted Inc (deg)'))[ind]
  
  if ref eq 'SGP' or ref eq 'TGP' or ref eq 'MGP' then begin
    ohref=s.(where(h eq 'Ref(Z)'))[ind]
    ohkk04=[s.(where(h eq 'Log(O/H)+12C KK04'))[ind],s.(where(h eq 'Log(O/H)+12G KK04'))[ind]]
    ohpt05=[s.(where(h eq 'Log(O/H)+12C PT05'))[ind],s.(where(h eq 'Log(O/H)+12G PT05'))[ind]]  
  endif
  
  d25=s.(where(h eq 'D_25 (")'))[ind]
  
  ; HEX SAMPLING
  temp=fitsloc+subtypes[select_ref].prefix+galno+subtypes[select_ref].posfix+ores+dp+'.fits'
  print,temp
  if file_test(temp) eq 0 then continue
  temp=(file_search(temp))[0]
  nh2=readfits(temp,nh2hd,/silent)
  sz=size(nh2,/d)
  getrot,nh2hd,angle,cdelt
  rd_hd,nh2hd,s=ss
  x_limit=[-sz[0]/2+1,sz[0]/2-1]*abs(cdelt[0])*3600.
  y_limit=[-sz[1]/2+1,sz[1]/2-1]*abs(cdelt[0])*3600.
  print,x_limit,y_limit
  
  ; by default, we will make measurements using a hex sampling grid
  if keyword_set(box) then begin
    x_limit=[x_limit[0]>(-fix(box/2)),x_limit[1]<fix(box/2)]
    y_limit=[y_limit[0]>(-fix(box/2)),y_limit[1]<fix(box/2)]
  endif
  sample_grid,[0.,0.],$
    0.5*ss.bmaj,$
    x_limit=x_limit,$
    y_limit=y_limit,$
    /hex,xout=xout,yout=yout
  pxout=round(-xout/3600./abs(cdelt[0])+sxpar(nh2hd,'CRPIX1')-1)
  pyout=round(yout/3600./abs(cdelt[0])+sxpar(nh2hd,'CRPIX2')-1)

  adxy,nh2hd,s.(where(h eq 'RA2000 (deg)'))[ind],s.(where(h eq 'DEC2000 (deg)'))[ind],maskx,masky
  dist_ellipse, ell, [sxpar(nh2hd,'naxis1'), sxpar(nh2hd,'naxis2')], $
      maskx, masky, $
      1./abs(cos(inc/90.*0.5*!pi)), s.(where(h eq 'Adopted PA (deg)'))[ind]
  ell=ell*abs(cdelt[0])*3600. ; in arcsec

  gal_ms=replicate(ms,n_elements(xout))
  gal_ms.xoffset=xout
  gal_ms.yoffset=yout
  gal_ms.rad=ell[pxout,pyout]
  
  if ref eq 'SGP' or ref eq 'TGP' or ref eq 'MGP' then begin
  gal_ms.ohkk04=ohkk04[0]+ohkk04[1]/(d25/2.0)*gal_ms.rad
  gal_ms.ohpt05=ohpt05[0]+ohpt05[1]/(d25/2.0)*gal_ms.rad
  endif
  
  gal_ms.galno=galno
  
  gal_ms.as2pc=as2pc
  gal_ms.res=0.5*ss.bmaj*as2pc
  gal_ms.d25=d25
  gal_ms.inc=inc

  
  foreach type, subtypes do begin
    fname=fitsloc+type.prefix+galno+type.posfix+ores+dp+'.fits'
    fnamemsk=fitsloc+type.prefix+galno+type.posfix+'_mskd'+ores+dp+'.fits'
    
    if file_test(fname) or file_test(fnamemsk) then begin
      if file_test(fnamemsk) then fname=fnamemsk
      print,"reading: ",fname
      im=readfits(fname,hd,/silent)
      tagindex=where(TAG_NAMES(ms) eq strupcase(type.tag))
      gal_ms.(tagindex)=im[pxout,pyout]
      print,"sample_points:", n_elements(pxout)
      ;print,type.tag,max(gal_ms.cont,/nan),max(im[pxout,pyout],/nan)
    endif
  endforeach
  
  all_ms=[all_ms,gal_ms]
  
  im[*]=0.0
  im[pxout,pyout]=1.0
  SXADDPAR, hd, 'DATAMAX', 0.0
  SXADDPAR, hd, 'DATAMIN', 1.0
  im[*]=0.0
  im[pxout,pyout]=gal_ms.rad
  SXADDPAR, hd, 'DATAMAX', min(gal_ms.hi,/nan)
  SXADDPAR, hd, 'DATAMIN', max(gal_ms.hi,/nan)
  temp=repstr(temp,'.fits','.sampling.fits')
  writefits,temp,im,hd
  

  im=ell/mean(gal_ms.d25/2.0)
  SXADDPAR, hd, 'DATAMAX', min(im,/nan)
  SXADDPAR, hd, 'DATAMIN', max(im,/nan)
  temp=repstr(temp,'.fits','.dist.fits')
  writefits,temp,im,hd
  
endforeach

save,filename=out+'.dat',all_ms
END


