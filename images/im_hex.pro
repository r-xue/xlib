PRO IM_HEX,im,hd,newim,newhd,$
    sigarr,pos=pos,$
    osamp=osamp,spacing=spacing
    
;+
; NAME:
;   IM_HEX
;
; PURPOSE:
;   re-assign pixel value in a hexagonal fashion
;   (replacing hex_grid.pro, written by A. Leroy)
;   useful to pick up independent pixels from an oversampling image...
;
; INPUTS:
;   osamp:      over sampling factor
;   spacing:    in arcsec (grid spacing parameter)
; KEYWORDS:
;
; OUTPUTS:
;
;
; HISTORY:
;
;   20170905    RX  loosely based on heximage.pro of Y.X. Cao
;   20170906    RX  add comments / the keyword <osamp>
;                   output header for 
;   
;-    
if  n_elements(osamp) eq 0.0 then osamp=3.0  
rd_hd, hd, s = h, c = c, /full

sxaddpar, hd, 'NAXIS1', h.naxis1 * osamp
sxaddpar, hd, 'NAXIS2', h.naxis2 * osamp
sxaddpar, hd, 'CRPIX1', h.crpix[0] * osamp
sxaddpar, hd, 'CRPIX2', h.crpix[1] * osamp
sxaddpar, hd, 'CDELT1', h.cdelt[0] / osamp
sxaddpar, hd, 'CDELT2', h.cdelt[1] / osamp

im = congrid(im,h.naxis1 * osamp, h.naxis2 * osamp, /center)
if keyword_set(errfile) then ime = congrid(ime,h.naxis1 * osamp, h.naxis2 * osamp, /center)

;;;;;;;;;; Generate hex grids ;;;;;;;;;;
rd_hd, hd, s = h, c = c, /full
ctr = h.crpix(0:1)
if  n_elements(spacing) eq 0 then begin 
    spacingpp = h.bmaj/abs(h.cdelt[0])/3600.0
endif else begin
    spacingpp = spacing/abs(h.cdelt[0])/3600.0
endelse

sample_grid,ctr,spacingpp,/hex,xout=xout,yout=yout
temp = where(xout le h.naxis1 and xout ge 0 and yout le h.naxis2 and yout ge 0)
xout = xout(temp)
yout = yout(temp)

ang = (findgen(6) * 60 + 30) / !RADEG
r = 0.5*spacingpp/cos(30./!RADEG)

hexnum = n_elements(xout)
xarr=make_array(hexnum,n_elements(ang))
yarr=make_array(hexnum,n_elements(ang))

for j=0, hexnum-1 do begin
    xarr[j,*] =xout[j]+r*cos(ang)
    yarr[j,*] =yout[j]+r*sin(ang)
endfor

xaxis=findgen(h.naxis1)
yaxis=findgen(h.naxis2)

make_2d,xaxis,yaxis,x2d,y2d
;;;;;;;;;; Calcualte avarage values in each grid ;;;;;;;;;;
newim = im*0
newhd = hd

if keyword_set(pos) then pos = make_array(2,hexnum)
sigarr = xout*0L

ndetect = 0L
for j=0, hexnum-1 do begin
    hex = Obj_New('IDLanROI',xarr(j,*),yarr(j,*))
    ingrid = where(hex->ContainsPoints(x2d,y2d) gt 0)
    dist = sqrt((x2d[ingrid]-xout[j])^2 - (y2d[ingrid]-yout[j])^2)
    center = where(dist eq min(dist))
    center = ingrid(center[0])
    sig = im(center)
    newim(ingrid) = sig

    if keyword_set(pos) then pos[*,j] = [c.ra(center),c.dec(center)]
    sigarr[j] = sig
endfor



END

PRO TEST_IM_HEX

im=readfits('HXMM01.band7.cm.fits',hd)
im_hex,im,hd,newim
writefits,'HXMM01.band7.cm_hex.fits',newim


END

