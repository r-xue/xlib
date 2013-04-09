PRO HIGHLIGHTS, wave,mask,invert=invert,yrange=yrange,color=color
;+
; NAME:
;   HIGHLIGHTS
;
; PURPOSE:
;   highlight unmasked/masked discrete wavelength ranges
;
; INPUTS:
;   WAVE    --  regular wavelength grid
;   MASK    --  mask grid (value=1 mask; value=0 unmasked)
;   yrange  --  hightlight height
;   
; KEYWORDS:
;   INVERT    --  hightlight unmasked regions
;   COLOR     --  hightlight color code
;
; HISTORY:
;
;   20120217  RX  initial version
;-


im=mask
if keyword_set(invert) then im=1.0-im
if n_elements(yrange) eq 0 then yrange=[-1000.,1000.]
if n_elements(color) eq 0 then color=200

reg=label_region([0,im,0])
reg=reg[1:-2]

dv=abs(wave[0]-wave[1])/2.0

for i=1,max(reg) do begin
  tag=where(i eq reg)
  xmin=min(wave[tag])-dv
  xmax=max(wave[tag])+dv
  polyfill,[xmin,xmax,xmax,xmin],$
    [yrange[0],yrange[0],yrange[1],yrange[1]],$
    noclip=0,color=color
endfor

END
