PRO IMS_CONVOL,input,output,kernel,flag=flag,silent=silent
;+
;   use convol,/normal to handle masked images
;-
if  ~keyword_set(silent) then print,'('+input+')','  X  ','('+kernel+')'

kim=readfits(kernel,khd,/silent)
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

nan=(iim ne iim)
sat=(iim eq 50000.0)

iim[where(fim ne 0,/null)]=!values.f_nan

if  kpeak ne 1 then begin
    cim=convol(iim,kim,/normal,/nan,missing=!values.f_nan)
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