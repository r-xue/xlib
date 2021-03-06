PRO REGRID3D,   oldim,oldhd,$
                newim,newhd,refhd,$
                regridv=regridv,$
                interp=interp,degree=degree,$
                missing=missing,verbose=verbose
;+
; NAME:
;   regrid3d
;
; PURPOSE:
;   regrid a 3D cube using hastrom_nan.pro
; 
; INPUTS:
;   oldim,oldhd,refhd
;   [regridv]:  0   no frame difference was considered 
;               1   LSRK(old) -> BARY(new,ref) (default if /regridv)
;               2   BARY(old) -> LSRK(new,ref)
;   [missing=!VALUEE.F_NAN]
;               
; OUTPUTS:
;   newim,newhd
; 
; NOTES:
;   if refhd=oldhd, no 2D regridding will happen. 
;   For example, 
;       IDL>regrid3d,oldim,oldhd,newim,newhd,oldhd,regridv=1
;   will only regrid the velocity frame from LSRK->BARY, and the astrometry is
;   not touched 
;     
; HISTORY:
;
;   20130214 RX introduced
;   20130227 RX add the option for the velocity regridding (including velocity frame change) 
;   
;-


; REGRID IN 2D oldim,oldhd->newim,newhd
dim=(size(oldim))[0]
if n_elements(missing) eq 0 then missing=!VALUES.F_NAN

if  strjoin(refhd,'') eq strjoin(oldhd,'') then begin
    newim=oldim
    newhd=oldhd
endif else begin
    if dim gt 2 then begin
      nchan=n_elements(oldim[0,0,*])
      tmp=oldhd
      sxaddpar,tmp,'NAXIS3',1
      newim=[]
      for i=0,nchan-1 do begin
          hastrom_nan,oldim[*,*,i],tmp,newim0,newhd0,refhd,missing=missing,interp=interp,degree=degre
          newim=[[[newim]],[[newim0]]]
      endfor
      sxaddpar,newhd0,'NAXIS3',nchan
      newhd=newhd0
    endif else begin
      hastrom_nan,oldim,oldhd,newim,newhd,refhd,missing=missing,interp=interp,degree=degre
    endelse
endelse

; REGRID IN VELOCITY
if n_elements(regridv) ne 0 then begin
  
  rd_hd, newhd, s=newh, c=newc, /full
  rd_hd, refhd, s=refh, c=refc, /full
  if    keyword_set(verbose) then print,"input cube velo info:  ", newh.ctype[2],newh.specsys,newh.velref,(newh.cdelt[2]/1.e3)
  oldv=newh.v*1000.
  oldcv=abs(newh.cdelt[2]/1.e3)
  if    keyword_set(verbose) then print,"ref   cube velo info:  ", refh.ctype[2],refh.specsys,refh.velref,(refh.cdelt[2]/1.e3)
  refv=refh.v*1000.
  refcv=abs(refh.cdelt[2]/1.e3)

  
  ; macthing 3rd axis
  nxy=size(newim,/d)
  new2im=fltarr(nxy[0],nxy[1],sxpar(refhd,'naxis3'))
  
  ; BARY->LSRK
  euler,refc.ra,refc.dec,l,b,1
  ;http://www.atnf.csiro.au/people/Tobias.Westmeier/tools_hihelpers.php#restframes
  dframe=9.*cos(l/180.*!dpi)*cos(b/180.*!dpi) + 12.*sin(l/180.*!dpi)*cos(b/180.*!dpi) + 7.*sin(b/180.*!dpi)
  if    keyword_set(verbose) then print, "V(LSRD)-V(HEL) [km/s]:  ", mean(dframe),min(dframe),max(dframe)
  helio2lsr,0.0,dframe,ra=refc.ra,dec=refc.dec,/kin
  if    keyword_set(verbose) then print, "V(LSRK)-V(HEL) [km/s]:  ", mean(dframe),min(dframe),max(dframe)
  if    keyword_set(verbose) then print, "frame change?"
  if    keyword_set(verbose) then begin
    if regridv eq 0 then print, "no frame difference"
    if regridv eq 1 then print, "LSRK->BARY"
    if regridv eq 2 then print, "BARY->LSRK"
  endif
  
  for i=0,nxy[0]-1 do begin
    for j=0,nxy[1]-1 do begin
      if regridv eq 0 then dfra=0.0
      if regridv eq 1 then dfra=-dframe[i,j]*1000.
      if regridv eq 2 then dfra=dframe[i,j]*1000.
      spex=newim[i,j,*]
      new2im[i,j,*]=interpol(spex,oldv+dfra,refv)
      tagnan=where(refv gt max(oldv+dfra+0.5*oldcv) or refv lt min(oldv+dfra-0.5*oldcv))
      if tagnan[0] ne -1 then new2im[i,j,[tagnan]]=missing
    endfor
  endfor
  
  newim=new2im
  
  cpkey=['SPECSYS','CTYPE3','CRVAL3','CDELT3','CRPIX3','CUNIT3','VELREF','NAXIS3']
  for i=0,n_elements(cpkey)-1 do begin
    tmp=sxpar(refhd,cpkey[i],count=ct)
    if ct ne 0 then SXADDPAR,newhd,cpkey[i],sxpar(refhd,cpkey[i]) else SXDELPAR,newhd,cpkey[i]
  endfor
  if regridv eq 1 then sxaddpar,newhd,'CTYPE3','VELO-HEL'
  if regridv eq 2 then sxaddpar,newhd,'CTYPE3','VELO-LSR'

endif


sxaddpar, newhd, 'DATAMAX', max(newim,/nan)
sxaddpar, newhd, 'DATAMIN', min(newim,/nan)


END