FUNCTION HEADFITSX,filename
;+
;   NAME:
;       HEADFITSX
;   PURPOSE:
;       Get the uncompressed image header
;   Notes:
;       headfits.pro doesn't work well with ".fz" because the image header (ext=1)
;       in fpack compressed images have a difference convention.
;       http://fits.gsfc.nasa.gov/registry/tilecompression/tilecompression2.3.pdf
;-

if  strmatch(filename,'*.fz') then begin
    hd=headfits(filename,ext=1)
    keylist=['naxis1','naxis2','naxis','bitpix']
    foreach key,keylist do begin
        sxaddpar,hd,key,sxpar(hd,'z'+key)
    endforeach
endif else begin
    hd=headfits(filename,ext=0)
endelse

return,hd
END