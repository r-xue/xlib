PRO PSFEX_ANALYZER,name,im,flag=flag,plot=plot,$
    magzero=magzero
;+
;   use PSFEX analyze the image PSF
;   requires: impro (J.M.)/astrolib(GSFC)
;   name:   prefix for the output files  
;   im:     image file name
;   
;-


;   HEADER
imk=readfits(im,imkhd)
getrot,imkhd,ang,cdelt
psize=abs(cdelt[0])*60.0*60.0

if  ~keyword_set(magzero) then begin
    magzero=sxpar(imkhd,'MAGZERO')
endif

if  ~keyword_set(plot) then begin

    ;   RUN SEXTRACTOR
    print,replicate('+',20)
    print,'FILE:    ',strtrim(im)
    print,'NAME:    ',strtrim(name)
    print,'MAGZERO: ',strtrim(magzero,2)
    print,'PSIZE:   ',strtrim(psize,2)
    print,replicate('+',20)

    sexconfig=INIT_SEX_CONFIG()
    sexconfig.pixel_scale=psize
    if  keyword_set(flag) then sexconfig.flag_image=flag
    sexconfig.DETECT_MINAREA=5.0
    sexconfig.seeing_fwhm=1.00
    sexconfig.PARAMETERS_NAME='/Users/Rui/GDrive/Worklib/projects/xlib/etc/xlib.sex.param_psfex'
    sexconfig.BACK_SIZE=round(64)    ; in pixels
    sexconfig.catalog_name='tmp.cat'
    sexconfig.CATALOG_TYPE='FITS_LDAC'
    sexconfig.DEBLEND_NTHRESH=64
    sexconfig.DEBLEND_MINCONT=0.0001
    sexconfig.mag_zeropoint=magzero
    sexconfig.DETECT_THRESH=1.25
    sexconfig.ANALYSIS_THRESH=1.25
    sexconfig.checkimage_type='SEGMENTATION'
    sexconfig.checkimage_name=name+'_seg.fits'
    im_sex,im,sexconfig

    spawn,'rm -rf '+name+'.cat'
    spawn,'rm -rf '+name+'_all.cat'
    cmd='ldacfilter -i tmp.cat -o '+name+'.cat '+$ 
        '-t LDAC_OBJECTS -c "((ELONGATION<1.12)AND(SNR_WIN>30));"'
    spawn,cmd
    cmd='ldacdelkey -i tmp.cat -o '+name+'_all.cat '+$
        '-k VIGNET -t LDAC_OBJECTS
    spawn,cmd
    spawn,'rm -rf tmp.cat'
    
    ;   RUN PSFEX
    psfexconfig=INIT_PSFEX_CONFIG()
    psfexconfig.psf_size='101,101'
    psfexconfig.PSF_SAMPLING=1.0
    psfexconfig.PSF_RECENTER='Y'
    psfexconfig.SAMPLE_MAXELLIP=0.1
    psfexconfig.SAMPLE_MINSN=30
    psfexconfig.SAMPLE_FWHMRANGE='2,8'
    im_psfex,name+'.cat',psfexconfig
    checklist=['proto','resi','samp','snap','chi']
    foreach ci,checklist do begin
        oldim=ci+'_'+name+'.fits'
        newim=name+'_'+ci+'.fits'
        base=FILE_BASENAME(name)
        oldim=repstr(name+'_'+ci,base+'_'+ci,ci+'_'+base)+'.fits'
        print,FILE_BASENAME(oldim),'->',newim
        spawn,'mv '+FILE_BASENAME(oldim)+' '+newim
    endforeach
    print,FILE_BASENAME(name+'.psf'),'->',name+'.psf'
    spawn,'mv '+FILE_BASENAME(name+'.psf')+' '+name+'.psf'

endif

;   EXTRACT PSF MODEL
psf=mrdfits(name+'.psf',1)
cube=psf.(0)
hd=mk_hd([0.,0.],[101,101],psize)

writefits,name+'_psfex.fits',cube[*,*,0],hd
tb=mrdfits(name+'.cat',2)
writefits,name+'_vignet.fits',tb.VIGNET


;   DO PLOTTING
tb=mrdfits(name+'_all.cat',1)
psize=sxpar(tb.field_header_card,'SEXPXSCL')
print,tb.field_header_card
tb=mrdfits(name+'_all.cat',2)
tag1=where(tb.flags le 0.0 and tb.SNR_WIN gt 15 and tb.elongation le 1.12)
tag2=where(tb.flags le 0.0 and tb.SNR_WIN gt 30 and tb.elongation le 1.12)
print,'Good Objs:',n_elements(tb.flags)
print,'Bad  Objs:',n_elements(tag2)

;   PLOT PSFEX SNAPSHOT
set_plot,'ps'
device,filename=name+'_psfex_check.eps',bits=8,$
    xsize=5.5,ysize=5.5,$
    /inches,/encapsulated,/color
!p.thick=2.0
!x.thick = 2.0
!y.thick = 2.0
!z.thick = 2.0
!p.charsize=1.0
!p.charthick=2.0
!x.gridstyle = 0
!y.gridstyle = 0
xyouts,'!6'

plot,tb.flux_radius*psize,tb.mag_auto,psym=3,xrange=[-0.25,2.5],$
    yrange=[28,12],xstyle=1,ystyle=1,$
    xtitle='FLUX_RADIUS ["]',ytitle='MAG_AUTO',/nodata

oplot,tb.flux_radius*psize,tb.mag_auto,psym=symcat(16),symsize=0.1,$
    color=cgcolor('slate gray')
oplot,tb[tag1].flux_radius*psize,tb[tag1].mag_auto,psym=symcat(16),symsize=0.1,$
    color=cgcolor('blue')
oplot,tb[tag2].flux_radius*psize,tb[tag2].mag_auto,psym=symcat(16),symsize=0.3,$
    color=cgcolor('red')

al_legend,name,/right,/bottom,box=0

device,/close
set_plot,'x'

END

PRO TEST_PSFEX_ANALYZER

psfex_analyzer,'../psfex/ia445_NDWFS1/ia445_NDWFS1',$
    '/Users/Rui/Workspace/highz/products/dey/Stacks/NDWFS1_LAE1_ia445_nosm.fits',$
    flag='/Users/Rui/Workspace/highz/products/dey/Stacks/NDWFS1_LAE1_ia445_nosm_flag.fits',$
    rms='/Users/Rui/Workspace/highz/products/dey/Stacks/NDWFS1_LAE1_ia445_nosm_rms.fits',$
    magzero=32.40

END