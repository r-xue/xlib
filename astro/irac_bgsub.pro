PRO IRAC_BGSUB,files
;+
; perform a crude background subtraction and create err-map for IRAC1 & IRAC4
; (will fetch dataset from the current working directory)
; files="*.phot.?.fits"
;-
fl=file_search(files)

foreach file,fl do begin
  
  galno=(strsplit(file,'.',/ext))[0]
  ib=(strsplit(file,'.',/ext))[2]
  
  im=readfits(file,hd,/silent)
  wt=readfits(galno+'.phot.'+ib+'_wt.fits',hdwt,/silent)
  
  tag=where(im ne im or wt ne wt or wt eq 0, /null)
  im[tag]=!values.f_nan
  wt[tag]=!values.f_nan
  
  mk=galno+'.'+ib+'.final_mask.fits'
  
  
  if file_test(mk) then mk=readfits(mk,mkhd,/silent) else mk=im*0.0
  
  print,replicate('-',20)
  print,'-->',galno
  print,replicate('-',20)
  
  tag=where(im eq im and mk eq 0.0 and wt eq wt)
  mmm,im[tag]*sqrt(wt[tag]),skymod, sigma
  skymod=skymod/median(sqrt(wt[tag]))
  wt[where(im ne im,/null)]=!values.f_nan
  sigma=sigma/sqrt(wt)+im-im
  print,"** im info: ",skymod,median(sigma),robust_sigma(im[tag],/zero)
  print,"** hd info: ",sxpar(hd,'BACK_SUB'),sxpar(hd,'BACKGRND')
  
  if strpos(file,'.phot.1') ne -1 or strpos(file,'.phot.2') ne -1 then im=im-skymod
  if strpos(file,'.phot.4') ne -1 then if sxpar(hd,'BACK_SUB') eq 0 then im=im-skymod

  out1=str_replace(file,'phot','phot_bgsub')
  mhd=hd
  sxaddpar, mhd, 'DATAMAX', max(im,/nan),before='HISTORY'
  sxaddpar, mhd, 'DATAMIN', min(im,/nan),before='HISTORY'
  writefits,out1,im,mhd
;  
  out2=str_replace(out1,'.fits','e.fits')
  im=sigma
  ;im[*,*]=robust_sigma(im,/zero)
  mhd=hd
  sxaddpar, mhd, 'DATAMAX', max(im,/nan),before='HISTORY'
  sxaddpar, mhd, 'DATAMIN', min(im,/nan),before='HISTORY'
  writefits,out2,im,mhd
  
endforeach


END