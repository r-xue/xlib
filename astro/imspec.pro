PRO IMSPEC,im,hd,ra,dec,velo,spec,psize=psize,ave=ave,$
  silent=silent
;+
; NAME:
;   IMSPEC
;
; PURPOSE:
;   extract a spectrum from a cube at given posistions
;
; INPUTS:
;   IM    data
;   HD    header
;   RA    in degrees
;   DEC   in degrees
;   psize pixel size you would like to regrid or aperture size for averaging
;         in arcsec
; 
; KEYWORDS:
;   ave   use aperture averging rather than regridding 
;
; OUTPUTS:
;   VELO  in the cube frame
;   SPEC  always in Kevin
;
; HISTORY:
;
;   20120305  RX  initial version
;   20130315  RX  add an option for aperture averging
;
;-

rd_hd, hd, s=s
velo=s.v

if n_elements(psize) eq 0 then psize=sqrt(s.bmaj*s.bmin)*2./3.
if psize eq 0.0 then psize=1.0
if not keyword_set(silent) then print,"psize:",psize

if not keyword_set(ave) then begin 
  
  mkhdr,imhd_ref,4,[11,11]
  imhd_ref=mk_hd([ra,dec],[11,11],psize/3600.)
  regrid3d,im,hd,im_sub,hd_sub,imhd_ref
  spec=(im_sub[5,5,*])[*]

endif else begin

  adxy,hd,ra,dec,x,y
  nxyz=size(im,/d)
  dist_ellipse, ell, nxyz[0:1], x, y,1.0,0.0
  getrot,hd,rotang,cdelt
  ell=ell*abs(cdelt[0])*60.0*60 ;
  spec=velo*0.0
  spec[*]=!VALUES.F_NAN
  tagin=where(ell le psize)
  if tagin[0] ne -1 then begin
    for j=0,nxyz[2]-1 do begin
      spec[j]=mean(im[tagin+j*nxyz[0]*nxyz[1]],/nan)
    endfor
  endif

endelse

jypb2k=1.0
if STRPOS(STRUPCASE(sxpar(hd, 'BUNIT')), 'JY/B') ne -1 then jypb2k=s.jypb2k
spec=spec*jypb2k

END

PRO test_imspec

dataid='b01003'
fusemc='/Users/Rui/Workspace/magclouds/fuse_mc/fits/'+dataid+'/h_'+dataid+'_nvo.fits'
spec=readfits(fusemc,spechd)
ra=sxpar(spechd,'RA_TARG')
dec=sxpar(spechd,'DEC_TARG')

datarepo="/Volumes/Scratch/data_repo/"
hi3d=datarepo+'21cm/atca/lmc.hi.cm.fits'
hi3d=readfits(hi3d,hi3dhd)
imspec,hi3d,hi3dhd,ra,dec,velo_ave,spec_ave,psize=120,/ave
imspec,hi3d,hi3dhd,ra,dec,velo,spec,psize=120
plot, velo,spec,psym=10
oplot,velo_ave,spec_ave,psym=10,color=cgcolor('red')

END
