PRO PLOTHIST1D,x,xbin,$
  xmin=xmin,xmax=xmax,$
  det=det,$
  xlog=xlog,$
  clip=clip,$
  rot=rot,$
  nhist=nhist,$
  maxhist=maxhist,$
  _extra=_extra,$
  nofill=nofill,$
  noerr=noerr

;+
; need documentation
;-
if not keyword_set(xmin) then xmin=min(x,/nan)
if not keyword_set(xmax) then xmax=min(x,/nan)

if keyword_set(xlog) then begin
  tag=where(x eq x and x gt 0,/null)
  hist_x=alog10(x[tag])
  hist_xmin=alog10(xmin)
  hist_xmax=alog10(xmax)
endif else begin
  tag=where(x eq x,/null)
  hist_x=x[tag]
  hist_xmin=xmin
  hist_xmax=xmax
endelse
if n_elements(det) ne 0 then det=det[tag]

hist=histogram(hist_x,$
            min=hist_xmin,max=hist_xmax,$
            binsize=xbin,/nan)
hist_err=[[hist^0.5],[hist^0.5]]

if n_elements(det) ne 0 then begin
  hist_x_det=hist_x[where(det eq 1.0)]
  hist_det=histogram(hist_x_det,$
    min=hist_xmin,max=hist_xmax,$
    binsize=xbin,/nan)
    hist_err=binomial_err(hist_det,hist,cf_level=0.99)
    hist=hist_det/(hist>1.0)
endif
print,min(hist),max(hist)
if n_elements(maxhist) eq 0 then maxhist=max(hist)
if keyword_set(nhist) then begin
  hist=float(hist)/maxhist
endif

dim=size(hist,/d)
xc=hist_xmin+(indgen(dim[0]+1))*xbin
xc=[xc,xc]
xc=xc(sort(xc))
yc=[]
for i=0,dim[0]-1 do begin
  yc=[yc,hist[i],hist[i]]
end
yc=[0,yc,0]

xp=hist_xmin+(indgen(dim[0])+0.5)*xbin
yp=hist
ye=hist_err
xe=hist_err*0.0

if keyword_set(xlog) then begin
  xc=10.^xc
  xp=10.^xp
endif


if keyword_set(rot) then begin
  tmp=yc
  yc=xc
  xc=tmp
  tmp=yp
  yp=xp
  xp=tmp
  tmp=ye
  ye=xe
  xe=tmp
endif


; default extra: color=cgcolor('black'),orien=-45,/line_fill

if not keyword_set(nofill) then polyfill,xc,yc,noclip=0,_extra=_extra

oplot,xc,yc,linestyle=0,_extra=_extra
if keyword_set(det) and not keyword_set(noerr) then begin
oploterror,xp,yp,xe[*,0],ye[*,0],/lobar,psym=3,/nohat
oploterror,xp,yp,xe[*,1],ye[*,1],/hibar,psym=3,/nohat
endif

END

