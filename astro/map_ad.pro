PRO MAP_AD,HD,aa,dd,x=x,y=y,$
    RADEC=RADEC,ARCMIN=ARCMIN,$
    _extra=extra,$
    edge=edge
;+
; NAME:
;   map_ad
;
; PURPOSE:
;   MAP pixel positions to the sky positions 
;
; INPUTS:
;   HD          data hd
;   RADEC       projection center of the mapping region
;   ARCMIN      units for dx-dy mapping
;   _EXTRA      any keywords for xyad.pro
;   x           use vector x rather than xx from IM
;   y           use vector y rather than yy from IM
; OUTPUTS:
;   AA          SKY AA
;   DD          SKY DD
;
;
; HISTORY:
;
;   20150420  RX  split from map_fits.pro
;-

if  n_elements(x) eq n_elements(y) and n_elements(x) gt 0 then begin
    xx=x
    yy=y
endif else begin
    nxy=[sxpar(hd,'naxis1'),sxpar(hd,'naxis2')]
    make_2d,findgen(nxy[0]),findgen(nxy[1]),xx,yy
endelse

if  keyword_set(edge) then begin
    xyad,hd,$
        [[[xx]],[[xx-0.5]],[[xx+0.5]],[[xx+0.5]],[[xx-0.5]]],$
        [[[yy]],[[yy-0.5]],[[yy-0.5]],[[yy+0.5]],[[yy+0.5]]],$
        aa,dd,$
        _extra=extra
endif else begin
    xyad,hd,xx,yy,aa,dd,_extra=extra    
endelse
if  n_elements(radec) eq 2 then begin
    if  keyword_set(arcmin) then u2d=60.0 else u2d=3600.
    aa=(aa-radec[0])*abs(cos(!const.DtoR*radec[1]))*u2d
    dd=(dd-radec[1])*u2d
endif

END

