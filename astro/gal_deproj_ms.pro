PRO GAL_DEPROJ_MS,ref,reftype=reftype,box=box,$
  ores=ores,mres=mres,out=out,MSPPC2=MSPPC2, HELIUM=HELIUM

;+
; NAME:
;   ST_MEASURE
;
; PURPOSE:
;   make measurement from deprojected commom resolution dataset
;  (will fetch a set of fits data from the current working directory)
;  box in arcsec
;
; OUT
;   mesaurement structure:
;   st.gal  galaxy name
;   st.....
; 
; Note:
;   GALEX images in CPS per pixel, CPS->Jy conversion could be found at
;   http://galex.stsci.edu/GR6/?page=faq
;   The original pixel is 1.5" size.
; GAL_DEPROJ_MS,'SGP',box=1024,reftype=6,out='st_ms',/MSPPC2
; GAL_DEPROJ_MS,'TGP',box=1024,reftype=17,out='thing_ms',/MSPPC2
; GAL_DEPROJ_MS,'SGP',box=1024,reftype=6,out='st_ms',/MSPPC2
;-

if n_elements(box) eq 0 then box=1024
if n_elements(ores) eq 0 then ores='*'
if n_elements(mres) eq 0 then mres='*'
if n_elements(out) eq 0 then out='all_ms'
if n_elements(reftype) eq 0 then reftype=0
; SETUP
fitsloc='./'
;fn='*_smo*_dp.fits'
;fl=file_search(fitsloc+fn,count=ct)
xco=2.0e20

ncps2mjypsr=33.65*1d-12/(1.5*1.5/(3283.*3600.*3600.))
fcps2mjypsr=108.*1d-12/(1.5*1.5/(3283.*3600.*3600.))

; LOAD ST STRUCTURE
gal_struct_build,ref,s,h,/silent

; LOOP THROUGH ALL GALAXIE

all_ms=[]

; note: each sampling point is a structure like below
ms = { $
  galno:"", $
  inc:!values.d_nan,$
  nh2:!values.d_nan,$           ; nh2 measurement
  nh2wt:!values.d_nan,$         ; mass-weighted
  nh2e:!values.d_nan,$
  nh2hsen:!values.d_nan,$
  nh2hsenwt:!values.d_nan,$
  nh2hsene:!values.d_nan,$
  nh2lsen:!values.d_nan,$
  nh2lsenwt:!values.d_nan,$ 
  nh2lsene:!values.d_nan,$
  xco:!values.d_nan,$           ; xco used
  nh1:!values.d_nan,$           ; nh1 measurement
  nh1wt:!values.d_nan,$
  nh1e:!values.d_nan,$
  cont:!values.d_nan,$
  conte:!values.d_nan,$
  nh1hsen:!values.d_nan,$
  nh1hsenwt:!values.d_nan,$
  nh1hsene:!values.d_nan,$
  nh1lsen:!values.d_nan,$
  nh1lsenwt:!values.d_nan,$
  nh1lsene:!values.d_nan,$
  xisrf:!values.d_nan,$
  pacs70:!values.d_nan,$
  pacs160:!values.d_nan,$
  contmsk:!values.d_nan,$       ;<--- not implemented, for continuum masking
  nuv:!values.d_nan,$           ; nuv flux
  fuv:!values.d_nan,$           ; fuv flux
  nuvwt:!values.d_nan,$           ; nuv flux
  fuvwt:!values.d_nan,$           ; fuv flux
  irac1:!values.d_nan,$         ; irac1 flux
  irac1e:!values.d_nan,$        ; irac1 flux error (crude)
  irac4:!values.d_nan,$         ; irac4 flux
  irac4e:!values.d_nan,$        ; irac4 flux error (crude)
  d25:!values.d_nan,$           ; d25 value
  as2pc:!values.d_nan,$
  res:!values.d_nan,$
  xoffset:!values.d_nan,$       ; ra offset from center for the sampling point
  yoffset:!values.d_nan,$       ; dec offset from center  for the sampling point
  zm:!values.d_nan,$            ; zm value
  zm_de:!values.d_nan,$         ; zm error bar (lower)
  zm_ue:!values.d_nan,$         ; zm error bar (upper)
  oh:!values.d_nan,$            ; log(o/h)+12
  ohlocal:!values.d_nan,$         ; log(o/h)+12 (local: considering the gradient)
  zm_local:!values.d_nan,$      ;<--- not implemented, for ZM value of each point
  nh2_predict:!values.d_nan, $   ;<--- not implemented, for predicted nh2 values
  sig_sfr:!values.d_nan $          ; sig_sfr from halpha
  }
types=gal_deproj_fileinfo(ref)


for ind=0,n_elements(s.(0))-1 do begin
  
  gal=s.(where(h eq 'Galaxy'))[ind]
  ;galno  = strmid(gal, 3, 4)
  ;if ref eq 'CGP' then galno  = strmid(gal, 4, 4)
  ;if ref eq 'TGP' then 
  galno = gal
  print, replicate('-',40)
  print, 'Working on galaxy number ',galno,' index',ind
  print, replicate('-',40)
  dist=s.(where(h eq 'Distance (Mpc)'))[ind]*10.^6
  as2pc=dist/206264.806
  inc=s.(where(h eq 'Adopted Inc (deg)'))[ind]
  
  if ref eq 'SGP' or ref eq 'TGP' then begin
  oh=[s.(where(h eq 'Log(O/H)+12'))[ind],$
    s.(where(h eq 'Log(O/H)+12'))[ind]-s.(where(h eq 'Log(O/H)+12 Error'))[ind],$
    s.(where(h eq 'Log(O/H)+12'))[ind]+s.(where(h eq 'Log(O/H)+12 Error'))[ind]]
;  oh=[s.(where(h eq 'Log(O/H)+12 KK04'))[ind],$
;    s.(where(h eq 'Log(O/H)+12 KK04'))[ind]-s.(where(h eq 'Log(O/H)+12 Error'))[ind],$
;    s.(where(h eq 'Log(O/H)+12 KK04'))[ind]+s.(where(h eq 'Log(O/H)+12 Error'))[ind]]
  ohref=s.(where(h eq 'Ref(Z)'))[ind]
  zm=oh2z(oh[0])
  zm_de=oh2z(oh[1])
  zm_ue=oh2z(oh[2])
  ohc=(s.(where(h eq 'Log(O/H)+12C KK04'))[ind]+s.(where(h eq 'Log(O/H)+12C PT05'))[ind])/2.0
  ohg=(s.(where(h eq 'Log(O/H)+12G KK04'))[ind]+s.(where(h eq 'Log(O/H)+12G PT05'))[ind])/2.0
  
;  ohc=(s.(where(h eq 'Log(O/H)+12C KK04'))[ind]+s.(where(h eq 'Log(O/H)+12C KK04'))[ind])/2.0
;  ohg=(s.(where(h eq 'Log(O/H)+12G KK04'))[ind]+s.(where(h eq 'Log(O/H)+12G KK04'))[ind])/2.0
;  
;  if ohref eq 'M2010' then begin
;  ohc=oh_conv(ohc,'kk04-d02')
;  oh=oh_conv(oh,'kk04-d02')
;  endif
  
  endif
  
  d25=s.(where(h eq 'D_25 (")'))[ind]
  
  ; HEX SAMPLING
  temp=fitsloc+galno+types[reftype].posfix+'_smo'+ores+'_dp.fits'

  if file_test(temp) eq 0 then continue
  nh2=readfits(temp,nh2hd,/silent)
  sz=size(nh2,/d)
  getrot,nh2hd,angle,cdelt
  x_limit=[-sz[0]/2+1,sz[0]/2-1]*abs(cdelt[0])*3600.
  y_limit=[-sz[1]/2+1,sz[1]/2-1]*abs(cdelt[0])*3600.
  
  x_limit=[x_limit[0]>(-fix(box/2)),x_limit[1]<fix(box/2)]
  y_limit=[y_limit[0]>(-fix(box/2)),y_limit[1]<fix(box/2)]
  sample_grid,[0.,0.],$
    sxpar(nh2hd,'BMAJ')*0.5*3600,$
    x_limit=x_limit,$
    y_limit=y_limit,$
    /hex,xout=xout,yout=yout
  pxout=round(-xout/3600./abs(cdelt[0])+sxpar(nh2hd,'CRPIX1')-1)
  pyout=round(yout/3600./abs(cdelt[0])+sxpar(nh2hd,'CRPIX2')-1)
  
  
  gal_ms=replicate(ms,n_elements(xout))
  gal_ms.xoffset=xout
  gal_ms.yoffset=yout
  gal_ms.xco=xco
  gal_ms.contmsk=0.0
  
  if ref eq 'SGP' or ref eq 'TGP' then begin
  gal_ms.zm=zm
  gal_ms.zm_ue=zm_ue
  gal_ms.zm_de=zm_de
  gal_ms.oh=oh[0]
  gal_ms.ohlocal=ohc+ohg/(d25/2.0)*sqrt(xout^2.0+yout^2.0)
  ohlocaltag=where(gal_ms.ohlocal eq 0.0)
  if ohlocaltag[0] ne -1 then gal_ms[ohlocaltag].ohlocal=gal_ms[ohlocaltag].oh
  endif
  
  gal_ms.galno=galno
  
  gal_ms.as2pc=as2pc
  gal_ms.res=sxpar(nh2hd,'BMAJ')*3600.*as2pc
  gal_ms.d25=d25
  gal_ms.inc=inc
  
  foreach type, types do begin
    fname=fitsloc+galno+type.posfix+'_smo'+ores+'_dp.fits'
    fnamemsk=fitsloc+galno+type.posfix+'_mskd_smo'+ores+'_dp.fits'

    if file_test(fname) or file_test(fnamemsk) then begin
      if file_test(fnamemsk) then fname=fnamemsk
      im=readfits(fname,hd,/silent)
      print,fname
      if type.tag eq 'hi' then gal_ms.nh1=(calc_cn(im,'hi',hd=hd,MSPPC2=MSPPC2, HELIUM=HELIUM))[pxout,pyout]
      if type.tag eq 'hie' then gal_ms.nh1e=(calc_cn(im,'hi',hd=hd,MSPPC2=MSPPC2, HELIUM=HELIUM))[pxout,pyout]
      if type.tag eq 'cont' then gal_ms.cont=(calc_cn(im,'jypb2k',hd=hd))[pxout,pyout]
      if type.tag eq 'conte' then gal_ms.conte=(calc_cn(im,'jypb2k',hd=hd))[pxout,pyout] 
      if type.tag eq 'hi_lsen' then gal_ms.nh1lsen=(calc_cn(im,'hi',hd=hd,MSPPC2=MSPPC2, HELIUM=HELIUM))[pxout,pyout]
      if type.tag eq 'hie_lsen' then gal_ms.nh1lsene=(calc_cn(im,'hi',hd=hd,MSPPC2=MSPPC2, HELIUM=HELIUM))[pxout,pyout]
      if type.tag eq 'hi_hsen' then gal_ms.nh1hsen=(calc_cn(im,'hi',hd=hd,MSPPC2=MSPPC2, HELIUM=HELIUM))[pxout,pyout]
      if type.tag eq 'hie_hsen' then gal_ms.nh1hsene=(calc_cn(im,'hi',hd=hd,MSPPC2=MSPPC2, HELIUM=HELIUM))[pxout,pyout]
      if type.tag eq 'co' then gal_ms.nh2=(calc_cn(im,'co1-0',hd=hd,xco=xco,MSPPC2=MSPPC2, HELIUM=HELIUM))[pxout,pyout]
      if type.tag eq 'coe' then gal_ms.nh2e=(calc_cn(im,'co1-0',hd=hd,xco=xco,MSPPC2=MSPPC2, HELIUM=HELIUM))[pxout,pyout]
      if type.tag eq 'co21' then gal_ms.nh2=(calc_cn(im,'co2-1',hd=hd,xco=xco/0.8,MSPPC2=MSPPC2, HELIUM=HELIUM))[pxout,pyout]
      if type.tag eq 'co21e' then gal_ms.nh2e=(calc_cn(im,'co2-1',hd=hd,xco=xco/0.8,MSPPC2=MSPPC2, HELIUM=HELIUM))[pxout,pyout]
      if type.tag eq 'co_lsen' then gal_ms.nh2lsen=(calc_cn(im,'co1-0',hd=hd,xco=xco,MSPPC2=MSPPC2, HELIUM=HELIUM))[pxout,pyout]
      if type.tag eq 'coe_lsen' then gal_ms.nh2lsene=(calc_cn(im,'co1-0',hd=hd,xco=xco,MSPPC2=MSPPC2, HELIUM=HELIUM))[pxout,pyout]
      if type.tag eq 'co_hsen' then gal_ms.nh2hsen=(calc_cn(im,'co1-0',hd=hd,xco=xco,MSPPC2=MSPPC2, HELIUM=HELIUM))[pxout,pyout]
      if type.tag eq 'coe_hsen' then gal_ms.nh2hsene=(calc_cn(im,'co1-0',hd=hd,xco=xco,MSPPC2=MSPPC2, HELIUM=HELIUM))[pxout,pyout]
      if type.tag eq 'halpha' then gal_ms.sig_sfr=(calc_ssfr(im,hd,proj='GOLDMINE'))[pxout,pyout]
      if type.tag eq 'irac1' then gal_ms.irac1=im[pxout,pyout]
      if type.tag eq 'irac1e' then gal_ms.irac1e=im[pxout,pyout]
      if type.tag eq 'irac4' then gal_ms.irac4=im[pxout,pyout]
      if type.tag eq 'irac4e' then gal_ms.irac4e=im[pxout,pyout]
      if type.tag eq 'nuv' then gal_ms.nuv=im[pxout,pyout]*ncps2mjypsr
      if type.tag eq 'nuv-wt' then gal_ms.nuvwt=im[pxout,pyout]*ncps2mjypsr
      if type.tag eq 'fuv' then gal_ms.fuv=im[pxout,pyout]*fcps2mjypsr
      if type.tag eq 'fuv-wt' then gal_ms.fuvwt=im[pxout,pyout]*fcps2mjypsr
      print,"sample_points:", n_elements(pxout),mean(gal_ms.oh)
      ;print,type.tag,max(gal_ms.cont,/nan),max(im[pxout,pyout],/nan)
    endif
  endforeach
  
  foreach type, types do begin
    fname=fitsloc+galno+type.posfix+'_iwt_smo'+ores+'_dp.fits'
    if file_test(fname) then begin
      im=readfits(fname,hd,/silent)
      if type.tag eq 'hi' then gal_ms.nh1wt=(calc_cn(im,'hi',hd=hd,MSPPC2=MSPPC2, HELIUM=HELIUM))[pxout,pyout]
      if type.tag eq 'co' then gal_ms.nh2wt=(calc_cn(im,'co1-0',hd=hd,xco=xco,MSPPC2=MSPPC2, HELIUM=HELIUM))[pxout,pyout]
      if type.tag eq 'hi_lsen' then gal_ms.nh1lsenwt=(calc_cn(im,'hi',hd=hd,MSPPC2=MSPPC2, HELIUM=HELIUM))[pxout,pyout]
      if type.tag eq 'co_lsen' then gal_ms.nh2lsenwt=(calc_cn(im,'co1-0',hd=hd,xco=xco,MSPPC2=MSPPC2, HELIUM=HELIUM))[pxout,pyout]
      if type.tag eq 'hi_hsen' then gal_ms.nh1hsenwt=(calc_cn(im,'hi',hd=hd,MSPPC2=MSPPC2, HELIUM=HELIUM))[pxout,pyout]
      if type.tag eq 'co_hsen' then gal_ms.nh2hsenwt=(calc_cn(im,'co1-0',hd=hd,xco=xco,MSPPC2=MSPPC2, HELIUM=HELIUM))[pxout,pyout]
      print,"sample_points:", n_elements(pxout)
    endif
  endforeach
  
  foreach type, ['xisrf'] do begin
    fname=fitsloc+galno+'*'+type+'_smo'+mres+'_dp.fits'
    if file_test(fname) then begin
      im=readfits(fname,hd,/silent)
      if type eq 'xisrf' then gal_ms.xisrf=im[pxout,pyout]
    endif
  endforeach

  
  all_ms=[all_ms,gal_ms]
  ;print,n_elements(where(all_ms.irac4e eq all_ms.irac4e))
endfor

save,filename=out+'.dat',all_ms
END

