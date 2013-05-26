PRO DEPROJ_IM, in, in_hd, out, out_hd, incl, posang
;+
; NAME:
;   DEPROJ_IM
;
; PURPOSE:
;   use GAL_FLAT to deproject to a face-on view with surface brightness and 
;     * correct brightness by mutiplying cos(inc) if units are in brightness (not Jy/BEAM)
;     * correct beam parameters using an ellipse deprojection
;
; INPUTS:
;   IN, IN_HD    input data set and FITS header
;   OUT, OUT_HD  input data set and FITS header
;   INCL         inclination of projected disk in degrees
;   POSANG       position angle of projected disk, N->E
;
; NOTE:
;   the script will use the values of 'CRVAL*' for the deprojection center.
;
; HISTORY:
;
;   20120310  TW  intorduced
;   20120405  RX  change beam informations and DO NOT scale image by
;                 cos(inc) when the pixel units are in Jy/beam 
;-

ra = SXPAR(in_hd, 'CRVAL1')
dec = SXPAR(in_hd, 'CRVAL2')
ADXY,in_hd,ra,dec,x_pos,y_pos

message,/info, 'Deprojecting using INC of '+strtrim(incl,2)+' and PA of '+strtrim(posang,2)
message,/info, 'Center position in pixels: '+strjoin([x_pos,y_pos],' ')

out=GAL_FLAT_NAN(in,posang,incl,[x_pos,y_pos],INTERP=1)
out_hd=in_hd

rd_hd, out_hd, s = h, c = c, /full
oldbmaj=h.bmaj  ; in arcsec
oldbmin=h.bmin  ; in arcsec
oldbpa=h.bpa   ; in degree (astro convention)


if oldbmaj*oldbmin ne 0.0 then begin
  deproj_beam,oldbmaj,oldbmin,oldbpa,posang,incl,bmaj,bmin,bpa
  SXADDPAR, out_hd, 'BMAJ', bmaj/3600.
  SXADDPAR, out_hd, 'BMIN', bmin/3600.
  SXADDPAR, out_hd, 'BPA',  bpa
  SXDELPAR, out_hd, 'BMMAX'
  SXDELPAR, out_hd, 'BMMIN'
  message,/info, "original      beam: "+string(oldbmaj)+','+string(oldbmin)+',   ('+string(oldbpa)+')'
  message,/info, "deprojected   beam: "+string(bmaj)+','+string(bmin)+',   ('+string(bpa)+')'
  
endif

if STRPOS(STRUPCASE(sxpar(out_hd, 'BUNIT')), 'BEAM') eq -1  then out=out*cos(incl/180.*!dpi)


SXADDPAR, out_hd, 'DATAMAX', max(out,/nan)
SXADDPAR, out_hd, 'DATAMIN', min(out,/nan)

END