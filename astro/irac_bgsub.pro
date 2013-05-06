PRO IRAC_BGSUB
;+
; perform a crude background subtraction and create err-map for IRAC1 & IRAC4
; (will fetch dataset from the current working directory)
;-
fl=file_search("*phot.?.fits")

foreach file,fl do begin
  
  galno=strmid(file,3,4)
  
  im=readfits(file,hd,/silent)
  mk="NGC"+galno+'*.final_mask.fits'
  
  if file_test(mk) then mk=readfits(mk,mkhd,/silent) else mk=im*0.0
  
  print,'-->',galno
  
  tag=where(im eq im and mk eq 0.0)
  mmm,im[tag],skymod, sigma
  print,skymod,sigma,sxpar(hd,'BACK_SUB'),sxpar(hd,'BACKGRND')
  
  if strpos(file,'.phot.1') ne -1 or strpos(file,'.phot.2') ne -1 then im=im-skymod
  if strpos(file,'.phot.4') ne -1 then if sxpar(hd,'BACK_SUB') eq 0 then im=im-skymod

  out1=str_replace(file,'phot','phot_bgsub')
  writefits,out1,im,hd
  
  out2=str_replace(out1,'.fits','e.fits')
  im[*,*]=robust_sigma(im)
  writefits,out2,im,hd
  
endforeach


END