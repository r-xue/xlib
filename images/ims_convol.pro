PRO IMS_CONVOL,input,output,kernel,flag=flag,silent=silent,im_halfsz=im_halfsz,kn_halfsz=kn_halfsz
;+
;
;   use convol,/normal to handle masked images
;   assume kernel is symmteric around the center pixel
;   
;-
if  ~keyword_set(silent) then print,'('+input+')','  X  ','('+kernel+')'

kim=readfits(kernel,khd,/silent)

nxy=size(kim,/d)
if  n_elements(kn_halfsz) ne 1 then kn_halfsz=min(round((nxy-1.)/2.))
nxy=round((nxy-1.)/2.)
kim=kim[nxy[0]-kn_halfsz:nxy[0]+kn_halfsz,nxy[0]-kn_halfsz:nxy[0]+kn_halfsz]


kpeak=max(kim,/nan)
kim=rotate(kim,2)
kim=kim>0.0
kim=kim/total(kim)


iim=readfits(input,ihd,/silent)
if  keyword_set(flag) then begin
    fim=readfits(flag,fhd,/silent)
endif else begin
    fim=iim
    fim[*]=0.0
endelse

nxy=size(iim,/d)
if  n_elements(im_halfsz) ne 1 then im_halfsz=min(round((nxy-1.)/2.))-1
nxy=round((nxy-1.)/2.)
hextract,iim,ihd,new_iim,new_ihd,nxy[0]-im_halfsz,nxy[0]+im_halfsz,nxy[1]-im_halfsz,nxy[1]+im_halfsz
hextract,fim,ihd,new_fim,new_fhd,nxy[0]-im_halfsz,nxy[0]+im_halfsz,nxy[1]-im_halfsz,nxy[1]+im_halfsz

iim=new_iim
ihd=new_ihd
fim=new_fim
fhd=new_fhd

nan=(iim ne iim)
sat=(iim eq 50000.0)

iim[where(fim ne 0,/null)]=!values.f_nan

if  kpeak ne 1 then begin
    tag=where(iim ne iim)
    if  tag[0] eq -1 then begin
        cim=convol_fft(iim,kim)
    endif else begin
        cim=convol(iim,kim,/normal,/nan,missing=!values.f_nan)
    endelse
endif else begin
    ;   delta functions
    cim=iim
endelse

;iim[where(nan,/null)]=!values.f_nan
;iim[where(sat,/null)]=!values.f_nan

sxaddpar,ihd, 'DATAMAX', max(cim,/nan),before='HISTORY'
sxaddpar,ihd, 'DATAMIN', min(cim,/nan),before='HISTORY'

cim[where(((fim ne 0) or iim ne iim),/null)]=!values.f_nan
if  kpeak ne 1 then begin
    cim[where(cim eq 0.0,/null)]=!values.f_nan
endif

writefits,output,cim,ihd

END