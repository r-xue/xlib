PRO IRAC_MASK,gal,band,cat
;+
; USE SEXTRACTOR TO CREATE FORE/BACK-GROUND SOURCE MASK
; (preliminary)
; references: Kim et al. 2012; Sheth et al. 2010
; will fetch data from the current working dir
; 
; note: idlutils/misc/rsex is out-of-date
; 
; file rquired: gal+'.phot.'+band+'_wt.fits'
;               gal+'.phot.'+band+'.fits'
;-


path=ProgramRootDir() 

GAL_DEPROJ_META, cat,sting,header,/silent


inp=gal+'.phot.'+band+'.fits'
im=readfits(inp,hd)
getrot,hd,ang,cdelt
psize=abs(cdelt[0])*60.0*60.0

;fw=psize/1.7
;FIND, im,x,y,fw

sexconfig=INIT_SEX_CONFIG()
sexconfig.catalog_name=gal+'.phot.'+band+'.cat'
sexconfig.detect_thresh=3.0
sexconfig.analysis_thresh=3.0
sexconfig.pixel_scale=psize
sexconfig.seeing_fwhm=1.7
sexconfig.checkimage_type='SEGMENTATION'
sexconfig.checkimage_name=gal+'.phot.'+band+'.seg.fits'
sexconfig.PARAMETERS_NAME=path+'../data/default.sex.param'

sexconfig.WEIGHT_IMAGE=gal+'.phot.'+band+'_wt.fits'

im_sex,inp,sexconfig
cs=rsex(gal+'.phot.'+band+'.cat')
print,get_tags(cs)

dim=size(im,/d)
make_2d,indgen(dim[0]),indgen(dim[1]),xx,yy
querysimbad,gal,ra,dec,/ned
adxy,hd,ra,dec,x_pos,y_pos

ind  = (where(sting.(where(header eq 'Galaxy')) eq gal))[0]
gpa  = float(sting.(where(header eq 'Adopted PA (deg)'))[ind])
ginc = float(sting.(where(header eq 'Adopted Inc (deg)'))[ind])
gd25 = float(sting.(where(header eq 'D_25 (")'))[ind])
dist_ellipse,dist,dim,x_pos,y_pos,1./cos(ginc/180.*!dpi), gpa
dist=dist*psize

; DO NOT USE SEG IMG WITHIN 0.5xD25
seg=readfits(gal+'.phot.'+band+'.seg.fits',seghd)
tagoff=where(dist le 0.5*gd25)
off=seg[tagoff]
off=off[UNIQ(off, SORT(off))]
foreach o,off do begin
  seg[where(seg eq o,/null)]=0.0
endforeach

; APPLY CIRCULAR MASKS WITH THE SIZE PROPORTIONAL TO THE MAGNITUDE OF THE SOURCE
; NOT DONE YET...
psf=psf_Gaussian(NPIXEL=[1001,1001], FWHM=[1.7,1.7]/0.1, /DOUBLE)
psf=psf/max(psf)
for i=0,n_elements(cs)-1 do begin
  if dist[cs[i].x_image-1,cs[i].y_image-1] ge 0.5*gd25 or $
     dist[cs[i].x_image-1,cs[i].y_image-1] le 3.0 $
    then continue
  if cs[i].FLUX_RADIUS ge 30 then continue
  rms=0.01
  sig=1.7/psize/2.3548
  r2=alog10(cs[i].FLUX_ISOCOR/rms/2./!dpi/(sig^2.))*2.0*sig>2.0
  sz=r2
  tagoff=where((xx-cs[i].x_image+1)^2.+(yy-cs[i].y_image+1)^2 le (sz)^2.0)
  seg[tagoff]=max(seg)+1
endfor

;
seg=label_region(seg)
writefits,gal+'.'+band+'.final_mask.fits',seg,seghd
;write_ds9_regionfile,cs.x_world,cs.y_world,filename='test.reg',color='cyan'

END



PRO TEST_IRAC_MASK

irac_mask,'ngc7331','1','nearby'

END