PRO IMS_SEXFIND,name,$
    bg_size=bg_size,$
    thresh=thresh,edge=edge,$
    silent=silent
;+
;   run sextractor for picking up compact sources / all sources
;   sbg_size: turn on source detection using small background sizes
;   bg_size/sbg_size in pixels 
;   we run sextractor twice:
;       small thresh: for conservative mask
;       large thresh: for deblending
;   try to use name.fits; name_flag.fits; name_rms.fits
;   if bg_size is too small, the broad feature will be absorbed into the estimated background and not detected in segment map 
;   we fill the missing data with SATLEV values
;   
;   prep images required:
;       bad pixel / blank pixels: 50000.0
;       flag pixel: 0 / 1
;       
;-



if  ~keyword_set(bg_size) then bg_size=30.0
if  ~keyword_set(thresh) then thresh=2.0 


for i=0,n_elements(name)-1 do begin
    
    if  ~file_test(name[i]+'.fits') then continue
    
    imk=readfits(name[i]+'.fits',imkhd,/silent)
    getrot,imkhd,ang,cdelt
    psize=abs(cdelt[0])*60.0*60.0

    sex_para=['NUMBER',$
        'X_IMAGE',$
        'Y_IMAGE',$
        'X_WORLD',$
        'Y_WORLD',$
        'XWIN_IMAGE',$
        'YWIN_IMAGE',$
        'XPEAK_IMAGE',$
        'YPEAK_IMAGE',$
        'XWIN_WORLD',$
        'YWIN_WORLD',$
        'FLAGS',$
        'IMAFLAGS_ISO',$
        'CLASS_STAR',$
        'FLUX_RADIUS(3)',$
        'KRON_RADIUS',$
        'PETRO_RADIUS(2)',$
        'FWHM_WORLD',$
        'ISOAREA_WORLD',$
        'MAG_PETRO',$
        'MAG_ISO',$
        'MAG_ISOCOR',$
        'MAG_AUTO',$
        'MAG_BEST',$
        'MAG_APER(1)',$
        'MAGERR_PETRO',$
        'MAGERR_ISO',$
        'MAGERR_ISOCOR',$
        'MAGERR_AUTO',$
        'MAGERR_BEST',$
        'MAGERR_APER(1)',$
        'A_IMAGE',$
        'B_IMAGE',$
        'THETA_IMAGE',$
        'ERRA_IMAGE',$
        'ERRB_IMAGE',$
        'ERRTHETA_IMAGE',$
        'ELONGATION',$
        'ELLIPTICITY',$
        'CXX_IMAGE',$
        'CYY_IMAGE',$
        'CXY_IMAGE',$
        'ERRCXX_IMAGE',$
        'ERRCYY_IMAGE',$
        'ERRCXY_IMAGE',$
        'FLUX_ISO',$
        'FLUXERR_ISO',$
        'FLUX_ISOCOR',$
        'FLUXERR_ISOCOR',$
        'FLUX_APER(1)',$
        'FLUXERR_APER(1)',$
        'FLUX_APER(2)',$
        'FLUXERR_APER(2)',$
        'FLUX_APER(3)',$
        'FLUXERR_APER(3)',$
        'FLUX_APER(4)',$
        'FLUXERR_APER(4)',$
        'FLUX_APER(5)',$
        'FLUXERR_APER(5)',$
        'FLUX_APER(6)',$
        'FLUXERR_APER(6)',$
        'FLUX_APER(7)',$
        'FLUXERR_APER(7)',$
        'FLUX_APER(8)',$
        'FLUXERR_APER(8)',$
        'SNR_WIN',$
        'FLUX_AUTO',$
        'FLUXERR_AUTO',$
        'FLUX_BEST',$
        'FLUXERR_BEST',$
        'BACKGROUND']
    sex_para=transpose(sex_para)
    OpenW, lun, name[i]+'.sex.param', /Get_LUN, WIDTH=250
    PrintF, lun, sex_para
    Free_LUN, lun
    
    
    sexconfig=INIT_SEX_CONFIG()
    sexconfig.detect_thresh=thresh
    sexconfig.analysis_thresh=thresh
    ;   SE will only process externa flag image when
    ;   <IMAFLAGS_ISO> or <NIMAFLAGS ISO> are present in the catalog parameter file
    ;   check out WeightWatcher for creating flag_image
    ;   <IMAFLAGS_ISO> represents the flagging from images
    sexconfig.flag_image=''
    if  file_test(name[i]+'_flag.fits') then begin
        sexconfig.flag_image=name[i]+'_flag.fits'
    endif
    sexconfig.flag_type='OR'
    sexconfig.pixel_scale=psize
    sexconfig.DETECT_MINAREA=3.0
    sexconfig.seeing_fwhm=1.00
    sexconfig.CLEAN_PARAM=5.0 ; 2.0
    
    sexconfig.PARAMETERS_NAME=name[i]+'.sex.param'
    sexconfig.BACK_SIZE=round(bg_size/psize)    ; in pixels
    sexconfig.BACK_FILTERSIZE=5.0   ;   large value is better for small background mesh sizes or large artifacts
    sexconfig.BACK_FILTTHRESH=3.0
    sexconfig.catalog_name=name[i]+'.cat'
    sexconfig.CATALOG_TYPE='FITS_LDAC'
    sexconfig.FILTER_NAME=cgSourceDir()+'../etc/default.conv'
    sexconfig.STARNNW_NAME=cgSourceDir()+'../etc/default.nnw'
    ; sexconfig.FILTER_NAME='/Users/Rui/GDrive/Worklib/projects/xlib/etc/tophat_1.5_3x3.conv'
    ; sexconfig.FILTER_NAME='/Users/Rui/GDrive/Worklib/projects/xlib/etc/gauss_1.5_3x3.conv'
    ; large filter might help detecting faint / extened sources
    ; but not helpful for deblending
    ; we used a small filtering for help delending
    ;   filter on + mssing data patch in sci/flag/rms will cause some problems with sextractor:
    ;   some pixels near missing data regions will be marked as 0 even they have high readings.
    ;   because of the filtering.. (usually with a width=(filter/kernel-1)/2.0
    ; to overcome this problem, we replace bad pixels with
    ;   50000.0 in sci
    ;   0.0     in rms
    sexconfig.FILTER='Y'
    ;sexconfig.FILTER_NAME='/Users/Rui/GDrive/Worklib/projects/xlib/etc/gauss_4.0_7x7.conv'
    sexconfig.FILTER_NAME=cgSourceDir()+'../etc/default.conv'
    sexconfig.SATUR_LEVEL=50000.0
    
    im_raw=readfits(name[i]+'.fits',hd_raw)
    
    sexconfig.checkimage_type='SEGMENTATION,BACKGROUND,BACKGROUND_RMS'
    sexconfig.checkimage_name=name[i]+'_seg.fits'+','+name[i]+'_sbg.fits'+','+name[i]+'_sbgrms.fits'
    
    sexconfig.checkimage_type='SEGMENTATION,BACKGROUND'
    sexconfig.checkimage_name=name[i]+'_seg.fits'+','+name[i]+'_sbg.fits'
    
    sexconfig.DEBLEND_NTHRESH=64
    sexconfig.DEBLEND_MINCONT=0.00001    ; better use a small value for debelending
    
    tname=tag_names(sexconfig)
    sexconfig=CREATE_STRUCT(sexconfig,remove=where(strmatch(tname,'PSFDISPLAY_TYPE',/f)))
    sexconfig=CREATE_STRUCT(sexconfig,remove=where(strmatch(tname,'NTHREADS',/f)))
    if  file_test(name[i]+'_rms.fits') then begin
        sexconfig.WEIGHT_TYPE='MAP_RMS'
        sexconfig.WEIGHT_IMAGE=name[i]+'_rms.fits'
    endif
    if  file_test(name[i]+'_wht.fits') then begin
        sexconfig.WEIGHT_TYPE='MAP_WEIGHT'
        sexconfig.WEIGHT_IMAGE=name[i]+'_wht.fits'
    endif
    
    ;sexconfig.VERBOSE_TYPE='QUIET'
    
    daper=[2.0,3.0,4.0,5.0,6.0,7.0,8.0,9.0]
    dapar=daper/psize
    dapar=strtrim(string(dapar,format='(f6.1)'),2)
    dapar=strjoin(dapar,',')
    sexconfig.PHOT_APERTURES=dapar
    
    im_sex,name[i]+'.fits',sexconfig,silent=silent,configfile=name[i]+'.sex.config'
    print,replicate('-',40)
    
    if  keyword_set(edge) then begin
        sexconfig.detect_thresh=edge
        sexconfig.analysis_thresh=edge
        sexconfig.catalog_name=name[i]+'_edge.cat'
        sexconfig.checkimage_type='SEGMENTATION'    ;  BACKGROUND,BACKGROUND_RMS are the same as the thresh detection run
        sexconfig.checkimage_name=name[i]+'_seg_edge.fits'
        im_sex,name[i]+'.fits',sexconfig,silent=silent,configfile=name[i]+'_edge.sex.config'
        print,replicate('-',40)
    endif
    
    
endfor

END

