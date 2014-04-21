PRO ADXY_CAR,hd,a,d,x,y

; x/y begin with zero = first pixel    
x=(a-sxpar(hd,'CRVAL1'))/sxpar(hd,'CDELT1')-1.+sxpar(hd,'CRPIX1')
y=(d-sxpar(hd,'CRVAL2'))/sxpar(hd,'CDELT2')-1.+sxpar(hd,'CRPIX2')
    
END