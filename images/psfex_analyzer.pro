PRO PSFEX_ANALYZER,name,$
    im,flag_image=flag_image,$
    magzero=magzero,SATUR_LEVEL=SATUR_LEVEL,$
    WEIGHT_IMAGE=WEIGHT_IMAGE,WEIGHT_TYPE=WEIGHT_TYPE,$
    ELONGATION=elongation,SNR_WIN=SNR_WIN,FWHMRANGE=FWHMRANGE,$
    HOMOPSF_PARAMS=HOMOPSF_PARAMS,$
    PSFSIZE=PSFSIZE,$
    skip=skip
;+
; NAME:
;   psfex_analyzer
; 
; PURPOSE:
;   perform <psfex> analysis on a single-pointing image
;   
; REQUIREMENTS:
;   impro (J.M.)/astrolib(GSFC)
;   theli (https://www.astro.uni-bonn.de/theli/gui/)
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
;   elongation  max elong for psfex input objects (default 1.11 or A/B=1/0.9
;   snr_win     min snr for psfex input objects
;   
; OUTPUTS:  if name='test_psfex'
;   test_psfex_seg.fits < check the sextractor cookbook
;   test_psfex.cat
;   test_psfex_all.cat
;   test_psfex_snap.fits < check the psfex cookbook
;   test_psfex_samp.fits < check the psfex cookbook
;   test_psfex_resi.fits < check the psfex cookbook
;   test_psfex_psfex.fits < psf images
;   test_psfex_proto.fits < check the psfex cookbook
;   test_psfex_chi.fits < check the psfex cookbook
;   test_psfex.psf < check the psfex cookbook
;   test_psfex_vignet.fits < check the psfex cookbook
;   test_psfex_psfex_check.eps
;   
; NOTE:
;   compatible with psfex 3.18.0 from http://www.astromatic.net/wsvn/public/
;   elon=A/B    (def. from the sextratcor manual) 
;   elli=1-B/A  (def. from the sextratcor manual)
;   
;   
; HISTORY:
;
;   20150401  RX    introduced
;   20151125  RX    add more comments
;   20160610  RX    combine checkplot to PDF
;                   
;       
;-

if  keyword_set(elongation) then elong=elongation else elong=1.1111
if  keyword_set(snr_win) then snr=snr_win else snr=20
if  ~keyword_set(fwhmrange) then fwhmrange='2,10'
if  ~keyword_set(SATUR_LEVEL) then SATUR_LEVEL=50000.0
if  ~keyword_set(HOMOPSF_PARAMS) then HOMOPSF_PARAMS='5.0,3.0'
if  ~keyword_set(psfsize) then psfsize=161
if  ~keyword_set(skip) then skip=''
if  ~keyword_set(WEIGHT_IMAGE) then weight_image='weight.fits'
if  ~keyword_set(WEIGHT_TYPE) then weight_type='NONE'


;   HEADER

imk=readfits(im,imkhd)
getrot,imkhd,ang,cdelt
psize=abs(cdelt[0])*60.0*60.0
if  ~keyword_set(magzero) then begin
    magzero=sxpar(imkhd,'MAGZERO')
endif

;   SETUP OUTOUT DIR

file_mkdir,file_dirname(name)

;   RUN SEXTRACTOR

if  ~strmatch(skip,'*se*',/f) then begin
    
    print,replicate('+',20)
    print,'FILE:    ',strtrim(im)
    print,'NAME:    ',strtrim(name)
    print,'MAGZERO: ',string(magzero,format='(f0.3)')
    print,'PSIZE:   ',string(psize,format='(f0.3)')+'"'
    print,replicate('+',20)

    sexconfig=INIT_SEX_CONFIG()
    sexconfig.pixel_scale=psize
    
    ;   SE will only process externa flag image when 
    ;   <IMAFLAGS ISO> or <NIMAFLAGS ISO> are present in the catalog parameter file
    ;   check out WeightWatcher for creating flag_image
    sexconfig.flag_image=''
    if  keyword_set(flag_image) then sexconfig.flag_image=flag_image
    
    sexconfig.DETECT_MINAREA=5.0
    sexconfig.seeing_fwhm=1.00
    sexconfig.PARAMETERS_NAME=cgSourceDir()+'../etc/xlib.sex.param_psfex'
    sexconfig.FILTER_NAME=cgSourceDir()+'../etc/default.conv'
    sexconfig.STARNNW_NAME=cgSourceDir()+'../etc/default.nnw'
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
    sexconfig.SATUR_LEVEL=SATUR_LEVEL
    sexconfig.WEIGHT_IMAGE=WEIGHT_IMAGE
    sexconfig.WEIGHT_TYPE=WEIGHT_TYPE
    tname=tag_names(sexconfig)
    sexconfig=CREATE_STRUCT(sexconfig,remove=where(strmatch(tname,'PSFDISPLAY_TYPE',/f)))
    sexconfig=CREATE_STRUCT(sexconfig,remove=where(strmatch(tname,'NTHREADS',/f)))
    sexconfig.PHOT_APERTURES='5,10,20,40'
    sexconfig.PHOT_APERTURES='4,8,12,16'
    im_sex,im,sexconfig,configfile=name+'.sex.config'

    spawn,'rm -rf '+name+'.cat'
    spawn,'rm -rf '+name+'_all.cat'
    
    ;   EXTRACT CAT FOR USEFULL OBJECTS WITH VIGNET
    cmd='ldacfilter -i tmp.cat -o '+name+'.cat '+$ 
        '-t LDAC_OBJECTS -c "(((ELONGATION<'+strtrim(elong,2)+')AND(SNR_WIN>'+strtrim(snr,2)+'))AND(IMAFLAGS_ISO=0));"'
    spawn,cmd
    ;   EXTRACT CAT FOR ALL OBJECTS WITHOUT VIGNET
    cmd='ldacdelkey -i tmp.cat -o '+name+'_all.cat '+$
        '-k VIGNET -t LDAC_OBJECTS
    spawn,cmd
    spawn,'rm -rf tmp.cat'
    print,replicate('+',20)
    print,''
    print,'output catalogs:'
    tmp=headfits(name+'_all.cat',ext=2,/silent)
    print,name+'_all.cat',' n='+strtrim(sxpar(tmp,'NAXIS2'),2)
    tmp=headfits(name+'.cat',ext=2,/silent)
    print,name+'.cat',' n='+strtrim(sxpar(tmp,'NAXIS2'),2)
    print,''
    print,replicate('+',20)
    
endif

;   RUN PSFEX

checkplot_type='FWHM,ELLIPTICITY,COUNTS,COUNT_FRACTION,CHI2,MOFFAT_RESIDUALS,ASYMMETRY'
checkplot_name='fwhm,ellipticity,counts,countfrac,chi2,moffatres,asymmetry'

CHECKIMAGE_TYPE='CHI,PROTOTYPES,SAMPLES,RESIDUALS,SNAPSHOTS,MOFFAT,-MOFFAT,-SYMMETRICAL'
CHECKIMAGE_NAME='chi.fits,proto.fits,samp.fits,resi.fits,snap.fits,moffat.fits,moffatsub.fits,symsub.fits'

if  ~strmatch(skip,'*pe*',/f) then begin
    
    psfsize_str=strtrim(psfsize,2)
    psfexconfig=INIT_PSFEX_CONFIG()
    psfexconfig.psf_size=psfsize_str+','+psfsize_str
    psfexconfig.PSF_SAMPLING=1.0
    psfexconfig.PSF_RECENTER='Y'
    psfexconfig.SAMPLE_MAXELLIP=1.-1./elong
    psfexconfig.SAMPLE_MINSN=snr
    psfexconfig.SAMPLE_FWHMRANGE=fwhmrange
    psfexconfig.SAMPLE_VARIABILITY=0.2
    psfexconfig.HOMOBASIS_TYPE='GAUSS-LAGUERRE'
    psfexconfig.HOMOPSF_PARAMS=HOMOPSF_PARAMS
    psfexconfig.HOMOKERNEL_SUFFIX='_homo.fits'
    psfexconfig.CHECKPLOT_DEV='PSC'
    psfexconfig.CHECKPLOT_TYPE=checkplot_type
    psfexconfig.CHECKPLOT_NAME=checkplot_name
    psfexconfig.CHECKIMAGE_TYPE=checkimage_type
    psfexconfig.CHECKIMAGE_NAME=checkimage_name
    psfexconfig.CHECKIMAGE_CUBE='Y'
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
    tb=mrdfits(name+'.cat',2)
    writefits,name+'_vignet.fits',tb.VIGNET

endif

;   DO PLOTTING

if  ~strmatch(skip,'*pl*',/f) then begin
    
    
    tb=mrdfits(name+'_all.cat',1)
    psize=sxpar(tb.field_header_card,'SEXPXSCL')
    ;print,tb.field_header_card
    
    tb=mrdfits(name+'_all.cat',2)
    taginput=where(tb.SNR_WIN gt snr and tb.elongation le elong and tb.IMAFLAGS_ISO eq 0)
    print,tag_names(tb)
    
    tagflag1 =where(tb.flags le 0.0 and tb.SNR_WIN gt snr and tb.elongation le elong and tb.IMAFLAGS_ISO eq 0)
    tagflag2 =where(tb.flags le 0.0 and tb.SNR_WIN gt snr/2.0 and tb.elongation le elong and tb.IMAFLAGS_ISO eq 0)
    tagflag3 =where(tb.flags le 0.0 and tb.SNR_WIN gt 7.0 and tb.elongation le elong and tb.IMAFLAGS_ISO eq 0)
    print,replicate('+',20)
;    print,'Good Objs:           ',n_elements(tb.flags)
;    print,'Bad  Objs:              ',n_elements(tag2)
    print,'N.Objs (>SNR;<ELONG;IMAflag=0):                  ',n_elements(taginput)
    print,'N.Objs (>SNR;<ELONG;IMAflag=0;CATflag=0):        ',n_elements(tagflag1)
    
    psf=mrdfits(name+'.psf',1,psfhd,/silent)
    print,'N.Objs (Loaded):                                 ',sxpar(psfhd,'LOADED')
    print,'N.Objs (ACCEPTED):                               ',sxpar(psfhd,'ACCEPTED')
    print,replicate('+',20)
    
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
        
    st=replicate(temp,n_elements(tagflag1))
    st.color='blue'
    st.x=tb[tagflag1].x_world
    st.y=tb[tagflag1].y_world
    st1=st
    st2=st
    st2.radius=1.0
    st=[st1,st2]
    write_ds9reg,name+'_psfex.reg',st,'FK5'
    write_csv,name+'_psfex.csv',double(tb[tagflag1].x_world),double(tb[tagflag1].y_world)
    
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
    oplot,tb[tagflag3].flux_radius*psize,tb[tagflag3].mag_auto,psym=symcat(16),symsize=0.1,$
        color=cgcolor('blue')
    oplot,tb[tagflag2].flux_radius*psize,tb[tagflag2].mag_auto,psym=symcat(16),symsize=0.1,$
        color=cgcolor('green')
    oplot,tb[tagflag1].flux_radius*psize,tb[tagflag1].mag_auto,psym=symcat(16),symsize=0.3,$
        color=cgcolor('red')
    
    al_legend,name,/left,box=0,/top,charsize=0.7
    
    device,/close
    set_plot,'x'

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
