PRO PSFEX_ANALYZER,name,$
    im,flag_image=flag_image,$
    magzero=magzero,SATUR_LEVEL=SATUR_LEVEL,$
    WEIGHT_IMAGE=WEIGHT_IMAGE,WEIGHT_TYPE=WEIGHT_TYPE,$
    BACK_SIZE=BACK_SIZE,THRESH=THRESH,$
    ELONGATION=elongation,SNR_WIN=SNR_WIN,FWHMRANGE=FWHMRANGE,BADPIXEL_FRAC=BADPIXEL_FRAC,$
    HOMOPSF_PARAMS=HOMOPSF_PARAMS,$
    PSFSIZE=PSFSIZE,VIGSIZE=VIGSIZE,$
    usetheli=usetheli,$
    skip=skip,verbose=verbose
;+
; NAME:
;   psfex_analyzer
; 
; PURPOSE:
;   perform <psfex> analysis on a single-pointing image
;   psfex:  https://github.com/astromatic/psfex
;   
; REQUIREMENTS:
;   impro (J.M.)/astrolib(GSFC)
;   theli (https://www.astro.uni-bonn.de/theli/gui/) : only when usetheli=1
; 
; INPUTS:
;   name:       prefix for the output files  
;   im:         image file name (...)
;   flag:       flag image (...)
;   rms:        not implemented yet
;   magzero:    specify magzero value if the header value is wrong
;   /plot:      just plot psfex_check using psfex results from last run
;
;   fwhmrange   fwhmrange for psfex input objects
;   elongation  max elong for psfex input objects (default elong=1.25 or elli=0.25
;   snr_win     min snr for psfex input objects
;   back_size   in arcsec
;   skip        *se*;*ft*;*pe"
;   WEIGHT_TYPE/TYPE are usually not used because a image with well described PSF should have a stable rms anyway.
;   
; OUTPUTS:  if name='prefix'
;
;   prefix.cat
;   prefix_all.cat
;   prefix_sex.cat
;
;   
;   prefix_seg.fits         sextractor seg image
;   prefix_samp.fits        Input vignettes in their original position, resolution and flux scaling
;   prefix_proto.fits       Versions of input vignettes, recentred, rescaled and resampled to PSF resolution
;   prefix_chi.fits         (square-root of) chi2 maps for all input vignettes
;   prefix_resi.fits        Input vignettes with best-fitting local PSF models subtracted
;   prefix_moffat.fits      Grid of Moffat models (eq_moffat) fitted to PSF model snapshots at each position/context.
;   prefix_moffatsub.fits   Grid of PSF model snapshots reconstructed at each position/context with best-fitting Moffat models subtracted
;   prefix_symsub.fits      Grid of PSF model snapshots reconstructed at each position/context with symmetrised image subtracted
;   prefix_snap.fits        Grid of PSF model snapshots reconstructed at each position/contex
;   
;   prefix_vignet.fits      vignette from input cat (sextractor)
;   
;   prefix.psf
;   prefx_psfex.fits
;   prefix_homo.fits
;   
;   prefix_psfex_checkphot.eps
;   prefix_psfex_checkplot.pdf
;   
; NOTE:
;   
;   compatible with psfex 3.18.0 from http://www.astromatic.net/wsvn/public/
;   elon=A/B    (def. from the sextratcor manual) 
;   elli=1-B/A  (def. from the sextratcor manual)
;   
;   It's a good practice to adjust <SNR_WIN> and examine *checkphot.eps interactively.
;   A small <SNR_WIN> will send too many noisy objects into PSFEX and sometimes lead to negative
;   sidelobs in the PSFEX models.
;   The best <SNR_WIN> may vary depending on the image properties (like noise characteristics, native vs. convolved images)
;   
;   sextractor parameters:
;   .flux_radius:   the radius of the circle centered on the barycenter that encloses about half of the total flux
;                   "Most users use twice the FLUX_RADIUS value to measure the FWHM. However this is 
;                    only strictly correct for Gaussian profiles. Experience shows that on traditional 
;                    seeing-limited images 2xFLUX_RADIUS is about 1.05-1.1 times the FWHM. The difference 
;                    can be much worse on profiles where a larger fraction of the flux lies in the wings."
;   
;   psf man:    http://psfex.readthedocs.io
;   sex -dd / psfex -dd for the up-to-date config parameters
;   
; HISTORY:
;
;   20150401    RX      introduced
;   20151125    RX      add more comments
;   20160610    RX      combine checkplot to PDF
;   20160725    RX      more comments
;                   
;       
;-

if  keyword_set(elongation) then elong=elongation else elong=1.25
if  keyword_set(snr_win) then snr=snr_win else snr=20
if  ~keyword_set(fwhmrange) then fwhmrange='2,10'
if  ~keyword_set(SATUR_LEVEL) then SATUR_LEVEL=50000.0
if  ~keyword_set(psfsize) then psfsize=101
if  ~keyword_set(vigsize) then vigsize=121
if  ~keyword_set(skip) then skip=''
if  ~keyword_set(WEIGHT_IMAGE) then weight_image='weight.fits'  ;   rms.fits
if  ~keyword_set(WEIGHT_TYPE) then weight_type='NONE'           ;   'MAP_RMS'
if  ~keyword_set(BACK_SIZE) then back_size=30.0 ; in arcsec
if  ~keyword_set(THRESH) then THRESH=2.00
if  ~keyword_set(BADPIXEL_FRAC) then BADPIXEL_FRAC=0.20

;   HEADER

imk=readfits(im,imkhd)
getrot,imkhd,ang,cdelt
psize=abs(cdelt[0])*60.0*60.0
if  ~keyword_set(magzero) then begin
    magzero=sxpar(imkhd,'MAGZERO')
endif
;   Moffat FWHM (in pixels) and Beta parameters
if  ~keyword_set(HOMOPSF_PARAMS) then begin
    HOMOBASIS_TYPE='NONE'
    HOMOPSF_PARAMS='2.0,3.0' ;strtrim(1.75/psize,2)+',3.0'
endif else begin
    HOMOBASIS_TYPE='GAUSS-LAGUERRE'
endelse

;   SETUP OUTOUT DIR

file_mkdir,file_dirname(name)

;   RUN SEXTRACTOR

if  ~strmatch(skip,'*se*',/f) then begin
    
    print,replicate('+',20)
    
    print,''
    print,'FILE:    ',strtrim(im)
    print,'NAME:    ',strtrim(name)
    print,'MAGZERO: ',string(magzero,format='(f15.3)')
    print,'PSIZE:   ',string(psize,format='(f15.3)')+'"'
    print,''
    
    print,replicate('+',20)
    vigsize_str=strtrim(round(vigsize),2)
    sex_para=$
        ['VIGNET('+vigsize_str+','+vigsize_str+')',$
        'ALPHAWIN_J2000',$
        'DELTAWIN_J2000',$
        'XWIN_IMAGE',$
        'YWIN_IMAGE',$
        'X_IMAGE',$
        'Y_IMAGE',$
        'X_WORLD',$
        'Y_WORLD',$
        'FLUX_APER(1)',$
        'FLUXERR_APER(1)',$
        'FLUX_MAX',$
        'FLUX_AUTO',$
        'FLUXERR_AUTO',$
        'FLUX_RADIUS',$
        'MAG_APER(1)',$
        'MAGERR_APER(1)',$
        'FLUX_RADIUS',$
        'ELONGATION',$
        'FLAGS',$
        'FLAGS_WEIGHT',$
        'IMAFLAGS_ISO',$
        'SNR_WIN',$
        'MAG_AUTO',$
        'MAGERR_AUTO',$
        'BACKGROUND',$
        'NUMBER',$
        'CLASS_STAR',$
        '#Astrometry error',$
        'ERRAWIN_IMAGE',$
        'ERRBWIN_IMAGE',$
        'ERRTHETAWIN_IMAGE',$
        'ERRAWIN_WORLD',$
        'ERRBWIN_WORLD',$
        'ERRTHETAWIN_J2000',$
        'MAG_ISO',$
        'MAGERR_ISO']
    sex_para=transpose(sex_para)
    OpenW, lun, name+'.sex.param', /Get_LUN, WIDTH=250
    PrintF, lun, sex_para
    Free_LUN, lun
    
    
    sexconfig=INIT_SEX_CONFIG()
    sexconfig.pixel_scale=psize
    ;   SE will only process externa flag image when 
    ;   <IMAFLAGS_ISO> or <NIMAFLAGS ISO> are present in the catalog parameter file
    ;   check out WeightWatcher for creating flag_image
    ;   <IMAFLAGS_ISO> represents the flagging from images
    sexconfig.flag_image=''
    if  keyword_set(flag_image) then sexconfig.flag_image=flag_image
    sexconfig.DETECT_MINAREA=5.0
    sexconfig.seeing_fwhm=1.20
    sexconfig.PARAMETERS_NAME=name+'.sex.param'
    sexconfig.FILTER_NAME=cgSourceDir()+'../etc/default.conv'
    sexconfig.STARNNW_NAME=cgSourceDir()+'../etc/default.nnw'
    sexconfig.BACK_SIZE=round(back_size/psize)    ; in pixels
    sexconfig.catalog_name=name+'_sex.cat'
    sexconfig.CATALOG_TYPE='FITS_LDAC'
    sexconfig.DEBLEND_NTHRESH=32
    sexconfig.DEBLEND_MINCONT=0.001     ;   smaller values will create larger number of segmentations
    sexconfig.mag_zeropoint=magzero
    sexconfig.DETECT_THRESH=THRESH
    sexconfig.ANALYSIS_THRESH=THRESH
    sexconfig.checkimage_type='SEGMENTATION'
    sexconfig.checkimage_name=name+'_seg.fits'
    sexconfig.SATUR_LEVEL=SATUR_LEVEL
    sexconfig.WEIGHT_IMAGE=WEIGHT_IMAGE
    sexconfig.WEIGHT_TYPE=WEIGHT_TYPE
    sexconfig.MEMORY_PIXSTACK=300000;*2
    sexconfig.MEMORY_OBJSTACK=3000;*2
    sexconfig.MEMORY_BUFSIZE=1024;*2
    
    tname=tag_names(sexconfig)
    sexconfig=CREATE_STRUCT(sexconfig,remove=where(strmatch(tname,'PSFDISPLAY_TYPE',/f)))
    ;sexconfig=CREATE_STRUCT(sexconfig,remove=where(strmatch(tname,'NTHREADS',/f)))
    sexconfig.PHOT_APERTURES=strtrim(round(4.0/psize),2)
    sexconfig.NTHREADS=1
    spawn,'rm -rf '+name+'_sex.cat'
    print,''
    
    im_sex,im,sexconfig,configfile=name+'.sex.config'
    
    print,''
    print,'output catalogs:'
    print,'-->',name+'_sex.cat'
    

    
endif

if  ~strmatch(skip,'*ft*',/f) then begin
    
    print,''
    print,replicate('+',20)
    print,''

    spawn,'rm -rf '+name+'.cat'
    spawn,'rm -rf '+name+'_all.cat'

    ;   EXTRACT CAT FOR USEFULL OBJECTS WITH VIGNET

    print,'create >>>>>>> vig.cat'
    ;tic
    if  keyword_set(usetheli) then begin
        ;LADCFILTER is ~2-3x faster for large catalogs
        cmd='ldacfilter -i '+name+'_sex.cat -o '+name+'.cat '+$
            '-t LDAC_OBJECTS -c "(((ELONGATION<'+strtrim(elong,2)+')AND(SNR_WIN>'+strtrim(snr,2)+'))AND(IMAFLAGS_ISO=0))AND(FLAGS<2);" '
        print,''
        spawn,cmd
    endif else begin
        ftab_ext,name+'_sex.cat','IMAFLAGS_ISO,ELONGATION,SNR_WIN,FLAGS',SEL_IMAFLAGS_ISO,SEL_ELONGATION,SEL_SNR_WIN,SEL_FLAGS,ext=2
        badpix=where(~(SEL_elongation lt elong and SEL_snr_win gt snr and SEL_imaflags_iso eq 0 and SEL_flags lt 2))
        ftab_delrow,name+'_sex.cat',badpix,new=name+'.cat',ext=2
    endelse
    ;toc    
    print,''

    print,'create >>>>>>> all.cat'
    ;tic
    ;   EXTRACT CAT FOR ALL OBJECTS WITHOUT VIGNET
    if  keyword_set(usetheli) then begin
        ;LADCFILTER is way faster for large catalogs
        cmd='ldacdelkey -i '+name+'_sex.cat -o '+name+'_all.cat '+'-k VIGNET -t LDAC_OBJECTS'
        spawn,cmd
    endif else begin
        sel_tab=readfits(name+'_sex.cat',sel_hd,exten_no=2,/silent)
        tbdelcol,sel_hd,sel_tab,'VIGNET'
        spawn,'cp -rf '+name+'_sex.cat'+' '+name+'_all.cat'
        modfits,name+'_all.cat',sel_tab,sel_hd,exten_no=2
    endelse
    print,''

    ;spawn,'rm -rf '+name+'_sex.cat'

    print,replicate('+',20)
    print,''
    print,'output catalogs:'
    tmp=headfits(name+'_all.cat',ext=2,/silent)
    print,name+'_all.cat'
    print,'>>>nobj='+strtrim(sxpar(tmp,'NAXIS2'),2)
    tmp=headfits(name+'.cat',ext=2,/silent)
    print,name+'.cat'
    print,'>>>nobj='+strtrim(sxpar(tmp,'NAXIS2'),2)
    print,''
    print,replicate('+',20)
    
endif


;   RUN PSFEX

checkplot_type='SELECTION_FWHM,FWHM,ELLIPTICITY,COUNTS,COUNT_FRACTION,CHI2,MOFFAT_RESIDUALS,ASYMMETRY'
checkplot_name='selfwhm,fwhm,ellipticity,counts,countfrac,chi2,moffatres,asymmetry'

CHECKIMAGE_TYPE='CHI,PROTOTYPES,SAMPLES,RESIDUALS,SNAPSHOTS,MOFFAT,-MOFFAT,-SYMMETRICAL'
CHECKIMAGE_NAME='chi.fits,proto.fits,samp.fits,resi.fits,snap.fits,moffat.fits,moffatsub.fits,symsub.fits'

if  ~strmatch(skip,'*pe*',/f) then begin
    
    psfsize_str=strtrim(round(psfsize),2)
    psfexconfig=INIT_PSFEX_CONFIG()
    psfexconfig.psf_size=psfsize_str+','+psfsize_str
    psfexconfig.PSF_SAMPLING=1.0
    psfexconfig.PSF_RECENTER='Y'
    psfexconfig.SAMPLE_MAXELLIP=1.-1./elong
    psfexconfig.SAMPLE_MINSN=snr
    psfexconfig.SAMPLE_FWHMRANGE=fwhmrange
    psfexconfig.SAMPLE_VARIABILITY=0.2
    
    psfexconfig.BASIS_TYPE='PIXEL_AUTO' ; 'GAUSS-LAGUERRE';'NONE','PIXEL','PIXEL_AUTO' 
    psfexconfig.PSFVAR_DEGREES=2
    psfexconfig.PSFVAR_NSNAP=9
    psfexconfig.NEWBASIS_TYPE='NONE' ; NONE, PCA_INDEPENDENT or PCA_COMMON
    psfexconfig.NEWBASIS_NUMBER=8
    
    psfexconfig.HOMOBASIS_TYPE=HOMOBASIS_TYPE
    psfexconfig.HOMOPSF_PARAMS=HOMOPSF_PARAMS
    psfexconfig.HOMOBASIS_NUMBER=10     ;  larger basis vectors for non-Gaussian profile?
    psfexconfig.HOMOKERNEL_SUFFIX='_homo.fits'
    
    
    
    psfexconfig.CHECKPLOT_DEV='PSC'
    psfexconfig.CHECKPLOT_TYPE=checkplot_type
    psfexconfig.CHECKPLOT_NAME=checkplot_name
    psfexconfig.CHECKIMAGE_TYPE=checkimage_type
    psfexconfig.CHECKIMAGE_NAME=checkimage_name
    psfexconfig.CHECKIMAGE_CUBE='Y'
    
    if  BADPIXEL_FRAC gt 0 and BADPIXEL_FRAC lt 1 then begin
        psfexconfig.BADPIXEL_FILTER='Y'
        psfexconfig.BADPIXEL_NMAX=round(BADPIXEL_FRAC*vigsize*vigsize)
    endif
    
    psfexconfig=CREATE_STRUCT(psfexconfig,'OUTCAT_TYPE','FITS_LDAC')
    psfexconfig=CREATE_STRUCT(psfexconfig,'OUTCAT_NAME',name+'_psfex.cat')
    
    im_psfex,name+'.cat',psfexconfig,configfile=name+'.psfex.config'
    
    ;   BETTER NAME
    
    print,replicate('+',20)
    print,''
    checklist=[]
    checklist=[checklist,strsplit(psfexconfig.CHECKPLOT_NAME,',',/ext)]
    checklist=[checklist,strsplit(repstr(psfexconfig.CHECKIMAGE_NAME,'.fits',''),',',/ext)]
    checkplot=[]
    print,'rename list :',checklist
    print,'rename files:'
    foreach ci,checklist do begin
        flist=file_search(ci+'*.*')
        foreach fold,flist do begin
            fnew=repstr(file_basename(fold),ci+'_'+file_basename(name),name+'_'+ci)
            print,fold,'->',fnew
            spawn,'mv '+fold+' '+fnew
            if  strmatch(fnew,'*.ps') then checkplot=[checkplot,fnew]
        endforeach
    endforeach
    print,''
    print,file_basename(name+'.psf'),'->',name+'.psf'
    spawn,'mv '+file_basename(name+'.psf')+' '+name+'.psf'
    print,file_basename(name+'_homo.fits'),'->',name+'_homo.fits'
    spawn,'mv '+file_basename(name+'_homo.fits')+' '+name+'_homo.fits'
    print,''
    print,replicate('+',20)
    
    ;   COMBINE PS FILE
    print,name+'_psfex_checkplot'
    print,repstr(checkplot,'.ps','')
    pineps,name+'_psfex_checkplot',repstr(checkplot,'.ps',''),/ps,/landscape,/clean
    
    ;   EXTRACT PSF MODEL
    
    psf=mrdfits(name+'.psf',1,psfhd)
    print,replicate('+',20)
    print,'-->',name+'.psf'
    print,psfhd
    print,replicate('+',20)
    cube=psf.(0)
    hd=mk_hd([0.,0.],[psfsize,psfsize],psize)

    writefits,name+'_psfex.fits',cube[*,*,0],hd
    im=cube[*,*,0]
    nxy=size(im,/d)
    cxy=(nxy-1)/2
    imout=im_circularize(im,cxy[0],cxy[1],samp=10.0)
    writefits,name+'_psfex1d.fits',imout,hd
    
    tb=mrdfits(name+'.cat',2)
    writefits,name+'_vignet.fits',tb.VIGNET

    tb=mrdfits(name+'_psfex.cat',2)
    if  keyword_set(verbose) then print_struct,tb
    
endif

;   DO PLOTTING

if  ~strmatch(skip,'*pl*',/f) then begin
    
    
    tb=mrdfits(name+'_all.cat',1)
    psize=sxpar(tb.field_header_card,'SEXPXSCL')
    ;print,tb.field_header_card
    
    tb=mrdfits(name+'_all.cat',2)
    
    ;   INPUT CAT FOR PSFEX
    taginput=where(tb.SNR_WIN gt snr and tb.elongation le elong and tb.IMAFLAGS_ISO eq 0 and tb.flags lt 2)    
    ;tagflag1=where(tb.SNR_WIN gt 10.0 and tb.elongation le elong and tb.IMAFLAGS_ISO eq 0 and tb.flags lt 2)
    
    ;   IMAFLAGS_ISO:   the flag image in sextractor run

    temp = {ds9reg, $
        shape:'circle', $         ;- shape of the region
        x:0., $             ;- center x position
        y:0., $             ;- center y position
        radius:10., $        ;- radius (if circle). Assumed to be arcsec
        angle:0., $         ;- angle, if relevant. Degrees.
        text:'', $          ;- text label
        color:'red', $         ;- region color
        width:10., $         ;- width (if relevant)
        height:10., $        ;- height (if relevant)
        font:'', $          ;- font for label
        select:1B, $        ;- is selected?
        fixed:0B, $         ;- is fixed?
        edit:1B, $          ;- is editable?
        move:1B, $          ;- is moveable?
        rotate:0B, $        ;- can be rotated?
        delete:1B}          ;- can be deleted?
        
    st=replicate(temp,n_elements(taginput))
    st.color='blue'
    st.x=tb[taginput].x_world
    st.y=tb[taginput].y_world
    st1=st
    st2=st
    st2.radius=1.0
    st=[st1,st2]
    write_ds9reg,name+'_psfex.reg',st,'FK5'
    write_csv,name+'_psfex.csv',double(tb[taginput].x_world),double(tb[taginput].y_world)
    
    ;   PLOT PSFEX SNAPSHOT
    set_plot,'ps'
    device,filename=name+'_psfex_checkphot.eps',bits=8,$
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
    ;oplot,tb[tagflag1].flux_radius*psize,tb[tagflag1].mag_auto,psym=symcat(16),symsize=0.15,$
    ;    color=cgcolor('blue')
    oplot,tb[taginput].flux_radius*psize,tb[taginput].mag_auto,psym=symcat(16),symsize=0.3,$
        color=cgcolor('red')
    
    al_legend,name,/left,box=0,/top,charsize=0.7
    
    psf=mrdfits(name+'.psf',1,psfhd,/silent)
    print,replicate('+',20)
    str=[]
    str=[str,'N.Objs (Input,red):'+string(n_elements(taginput),format='(i8)')]
    str=[str,'N.Objs (Loaded):   '+string(sxpar(psfhd,'LOADED'),format='(i8)')]
    str=[str,'N.Objs (Accepted): '+string(sxpar(psfhd,'ACCEPTED'),format='(i8)')]
    for i=0,n_elements(str)-1 do begin
        print,str[i]
    endfor
    print,replicate('+',20)
    
    
    ftab_ext,name+'.cat','FLUX_RADIUS,MAG_AUTO',FLUX_RADIUS,MAG_AUTO,ext=2
    ftab_ext,name+'_psfex.cat','FLAGS_PSF',FLAGS_PSF,ext=2
    tag=where(FLAGS_PSF eq 0)
    oplot,FLUX_RADIUS[tag]*psize,MAG_AUTO[tag],psym=cgsymcat(6),color=cgcolor('green'),symsize=0.3
    
    al_legend,str,/right,box=0,/bot,charsize=0.7

    device,/close
    set_plot,'x'
    
    set_plot,'ps'
    device,filename=name+'_psfex_checkmap.eps',bits=8,$
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
    
    ftab_ext,name+'_psfex.cat','X_IMAGE,Y_IMAGE',X_IMAGE,Y_IMAGE,ext=2
    
    plot,x_image,y_image,$
        xtitle='x_image',ytitle='y_image',$
        psym=symcat(16),symsize=0.3
    oplot,x_image[tag],y_image[tag],psym=cgsymcat(6),color=cgcolor('green'),symsize=0.3
    
    device,/close
    set_plot,'x' 

endif


if  ~strmatch(skip,'*rmcat*',/f) then begin
    if  file_test(name+'_sex.cat') then spawn,'rm -rf '+name+'_sex.cat'
    if  file_test(name+'.cat') then spawn,'rm -rf '+name+'.cat'
endif
if  ~strmatch(skip,'*rmdiag*',/f) then begin
    if  file_test(name+'_vignet.fits') then spawn,'rm -rf '+name+'_vignet.fits'
    if  file_test(name+'_seg.fits') then spawn,'rm -rf '+name+'_seg.fits'
    if  file_test(name+'_resi.fits') then spawn,'rm -rf '+name+'_resi.fits'
    if  file_test(name+'_samp.fits') then spawn,'rm -rf '+name+'_samp.fits'
    if  file_test(name+'_chi.fits') then spawn,'rm -rf '+name+'_chi.fits'
endif

END

PRO TEST_PSFEX_ANALYZER

;psfex_analyzer,'../psfex/ia445_NDWFS1/ia445_NDWFS1',$
;    '/Users/Rui/Workspace/highz/products/dey/Stacks/NDWFS1_LAE1_ia445_nosm.fits',$
;    flag='/Users/Rui/Workspace/highz/products/dey/Stacks/NDWFS1_LAE1_ia445_nosm_flag.fits',$
;    rms='/Users/Rui/Workspace/highz/products/dey/Stacks/NDWFS1_LAE1_ia445_nosm_rms.fits',$
;    magzero=32.40

psfex_analyzer,'test_psfex',$
    'NDWFS1_LAE1_ia445_nosm.fits',$
    magzero=32.40

END

PRO TEST_PSFEX_KS

psfex_analyzer,'psfex_test4ks/H_psfex',$
    '/Users/keshi/optical/pcf1/H_matched_pcf1_sci_all.fits',$
    magzero=24.12,skip='',snr=15,elong=1./(1.-0.3)

END

PRO TEST_SCAMP

scampconfig=init_scamp_config()
scampconfig.astref_catalog='SDSS-R9'
scampconfig.MAGZERO_KEY='NONE'
scampconfig.EXPOTIME_KEY='NONE'
scampconfig.MAGZERO_OUT=0.0
;scampconfig.PHOTINSTRU_KEY='NONE'
im_scamp,'test_psfex_all.cat',scampconfig, configfile='test_psfex.scamp.config'

END
