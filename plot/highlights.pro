PRO HIGHLIGHTS, wave,mask,invert=invert,yrange=yrange,color=color,seg=seg
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
;   seg     --  segment tag for wave
;   
; KEYWORDS:
;   INVERT    --  hightlight unmasked regions
;   COLOR     --  hightlight color code
;
; HISTORY:
;
;   20120217  RX  introduced
;-


im=mask
if keyword_set(invert) then im=1.0-im
if n_elements(yrange) eq 0 then yrange=[-1000.,1000.]
if n_elements(color) eq 0 then color=200
if n_elements(seg) eq 0 then seg=wave*0.0

seg_tag=seg[UNIQ(seg, SORT(seg))]
for j=0,n_elements(seg_tag)-1 do begin
  wv=wave[where(seg eq seg_tag[j])]
  mk=im[where(seg eq seg_tag[j])]
  reg=label_region([0,mk,0])
  reg=reg[1:-2]
  dv=abs(wv[0]-wv[1])/2.0
  for i=1,max(reg) do begin
    tag=where(i eq reg)
    xmin=min(wv[tag])-dv
    xmax=max(wv[tag])+dv
    polyfill,[xmin,xmax,xmax,xmin],$
      [yrange[0],yrange[0],yrange[1],yrange[1]],$
      noclip=0,color=color
  endfor
endfor

END
