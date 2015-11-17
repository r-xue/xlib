FUNCTION READMIR,fits,hd

cmd="fits in="+fits+" out=tempx.fits op=xyout"
spawn,cmd,outlog
im=readfits("tempx.fits",hd)
spawn,'rm -rf tempx.fits'
return,im

END