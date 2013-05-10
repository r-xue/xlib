PRO DEPROJ_ALL, fwhm=fwhm, kpc=kpc, $
    hi_res=hi_res,uv_res=uv_res,$
    select=select,ref=ref,$
    unmsk=unmsk, sz_temp=sz_temp,wtsm=wtsm,$
    gselect=gselect
;+
; NAME:
;   deproj_all
;
; PURPOSE:
;   * smooth multi-band images to desired deprojected physical/spatial resolutions
;   * deproject images to face-on view with surface brightness corrected by mutiplying cos(inc)
;
; INPUTS:
;   FWHM       desired FWHM circular beam (in arcsec) after deprojection
;              Note: turn off convolution by setting fwhm=0
;   /KPC       FWHM is given in kpc rather than arcsec
;   /UNMSK     do NOT use the mask image of IRAC1
;   SZ_TEMP    template size in pixel default: 1024    
;   select     choose only some types of data for processing
;              e.g. select=[0,1] -- only process IRAC1 & IRAC4 
;              (see the structure info in st_struct_fileinfo.pro)
;   /hi_res    fwhm will be choosen automatically according to native resolutions of HI data
;   /wtsm      derive the intneisity-weighted intensity at lower resolutions
;   /ref       use the reference galaxy table (M51 etc..)
;   
; OUTPUTS:
;   note:      only galaxies with file names like "*smo*.fits" were processed succesfully for 
;              smoothing/deproejcting
;
; EXAMPLES:
;   * extracting a dataset with 1kpc resolution
;     deproj_all,fwhm=1.0,/kpc 
;   * extracting a dataset with a round deprojected HI beam
;     deproj_all,/hi_res, select=[2,3,4,5]
;   * extracting a dataset for plotting Katrina's figures:
;     deproj_all,fwhm=0.0,/kpc, select=[1,3,4],sz_temp=179,/unmsk 
;   * extracting a dataset for plotting a sample figure
;     deproj_all,fwhm=0.0,/kpc, select=indgen(13),sz_temp=750,/unmsk, ref='CGP'
;     M51 dataset
;     deproj_all,fwhm=15.0, select=indgen(19),sz_temp=750,/unmsk, ref='CGP',gselect=6
;
;   * extracting a highest-resolution dataset for i8-co-uv correlations:
;     deproj_all,/uv_res,select=[0,1,2,3,4,5,8,9,10,11]
;     deproj_all,/uv_res,/ref,select=[0,1,2,3,8,9,10,11]
;   * extracting a highest-resolution dataset for i8-gas-uv correlations:
;     deproj_all,/hi_res,select=[0,1,2,3,4,5,6,7,8,9,10,11]
;
;   * extract a 1kpc resolution dataset for comparing the area-/mass-weighted surface
;     density
;     deproj_all,fwhm=1.0,/kpc, select=[2,4], /wtsm
;   * extract a 1kpc resolution dataset for comparing the area-/mass-weighted surface
;     density. Hoowever, we add 1.5sigma emission at non-detection region for testing
;     deproj_all,fwhm=1.0,/kpc, select=[2,3,4,5,10,11,12,13,14,15,16,17], /wtsm
;
; HISTORY:
;
;   20120217  RX  introduced
;   20120220  RX  fix an issue dealing with an image with rotated pixels
;                 call smooth3d.pro for smoothing    
;   20130310  TW  do a loop over available images
;   20130410  RX  fix an issue related to images using "Jy/beam" as units
;                 use st_struct_build.pro to load galaxy parameters
;   20130412  RX  rename it to st_deproj_all.pro, clean the code
;                 add GALEX data and IRAC4 processing
;   20130423  RX  add GALEX-wt images
;                 GALEX image units: CPS per pixel
;   20140503  RX  rename it to deproj_all.pro and make it a general-purpose procedure
;                 fix an issue when processing image in extensions
;                 fix an issue when processing data from Herschel/PACS 
;-

;+
;NOTE:
;   IRAC appx PSF: http://irsa.ipac.caltech.edu/data/SPITZER/docs/irac/iracinstrumenthandbook/5/
;   GALEX appx PSF: http://www.galex.caltech.edu/wiki/Public:Documentation/Chapter_2
;
;-
; DEFAULT OPTIONS
!except=1
if n_elements(fwhm) eq 0 then fwhm=0
if n_elements(sz_temp) eq 0 then sz_temp=1024

; READ THE PARAMETERS FILE
gal_struct_build,ref,s,h
if n_elements(gselect) eq 0 then gselect=indgen(n_elements(s.(0)))


; LOAD PATH/FILENAME INFO

if n_elements(select) eq 0 then select=indgen(n_elements(types))
types=deproj_fileinfo(ref)
subtypes=types[select]


foreach ind,gselect do begin
  
    gal=s.(where(h eq 'Galaxy'))[ind]
    galno  = strmid(gal, 3, 4)
    if ref eq 'CGP' then galno = strmid(gal, 4, 4)
    print, replicate('-',40)
    print, 'Working on galaxy number ',galno,' index',ind
    gpa  = float(s.(where(h eq 'Adopted PA (deg)'))[ind])
    ginc = float(s.(where(h eq 'Adopted Inc (deg)'))[ind])
    dist = float(s.(where(h eq 'Distance (Mpc)'))[ind]*10.^6)
    ra   = float(s.(where(h eq 'RA2000 (deg)'))[ind])
    dec  = float(s.(where(h eq 'DEC2000 (deg)'))[ind])
    as2pc=dist/206264.806
    print, "gpa,ginc,dist,ra,dec"
    print, gpa,ginc,dist,ra,dec
    print, replicate('-',40)
    
    ; DETERMINE DESIRED RESOLUTION
    if keyword_set(hi_res) then begin
      fwhm=0
      m=where(types.tag eq 'hi')
      imgfl =types[m].path+types[m].prefix+galno+types[m].posfix+'.fits'
      if file_test(imgfl) then begin
        imgfl = READFITS(imgfl,imgfl_hd,/silent)
        rd_hd, imgfl_hd, s = shi, c = chi, /full
        DEPROJ_BEAM, shi.bmaj, shi.bmin, shi.bpa, gpa, ginc, test_bmaj,test_bmin,test_bpa
        fwhm=test_bmin>test_bmaj+0.2
        kpc=0
        print, "-->  choosing HI deprojected resolution: "+string(fwhm)
      endif
    endif
    if keyword_set(uv_res) then begin
      fwhm=0
      m=where(types.tag eq 'nuv')
      DEPROJ_BEAM, types[m].psf, types[m].psf, 0.0, gpa, ginc, test_bmaj,test_bmin,test_bpa
      fwhm=test_bmin>test_bmaj+0.2
      kpc=0
      print, "-->  choosing UV deprojected resolution: "+string(fwhm)
    endif
    
    if keyword_set(kpc) then res_as = fwhm*1000./as2pc else res_as = fwhm
    strres = strtrim(string(fix(res_as)),1)
    print,'Smoothing to a resolution of '+string(res_as)+' arcsec'

    ; SET UP TEMPLATE FOR REGRIDDING: default: 1024 x 1024, 1"
    refhd = MK_HD([ra,dec],[sz_temp,sz_temp],1)
           
    foreach type,subtypes do begin
      
      imgfl =type.path+type.prefix+galno+type.posfix+'.fits'
      print,imgfl
      if file_test(imgfl) then begin
        print,'process->'+imgfl
        mom0 = READFITS(imgfl,mom0_hd)
        if n_elements(mom0) eq 1 then mom0 = READFITS(imgfl,mom0_hd,ext=1)
        if (size(mom0))[0] gt 2 then begin
          mom0=mom0[*,*,0]
          SXADDPAR,mom0_hd,'NAXIS3',1
        endif
        mkfl = type.path+type.prefix+galno+type.mask+'.fits'
        if file_test(mkfl) eq 1 and not keyword_set(unmsk) then begin
           mk = READFITS(mkfl,mk_hd,/silent)
           mom0[where(mk ne 0,/null)]=!VALUES.F_NAN
        endif
        errm=0
        
        
        if STRPOS(type.posfix, '.emom0') ne -1 then errm=1
        if STRPOS(type.posfix, '.4e') ne -1 then errm=1
        if STRPOS(type.posfix, '.1e') ne -1 then errm=1
        REGRID3D, mom0,mom0_hd,mom0rg,mom0rg_hd,refhd
        

        ; AREA-WEIGHTED INTENSITY AT LOWER RESOLUTION
        UNDEFINE,scale
        SMOOTH3D,mom0rg,mom0rg_hd,mom0s,mom0s_hd,$
             [res_as,res_as*cos(ginc/180.*!dpi),gpa],$
             ifail=ifail,err=errm,psf_org=type.psf,scale=scale
        DEPROJ_IM, mom0s, mom0s_hd, mom0dp, mom0dp_hd, ginc, gpa
        if  file_test(mkfl) eq 1 and not keyword_set(unmsk) then flag='_mskd' else flag=''
        if  ifail eq 0 then flag=flag+'_smo'+strres else flag=''
        WRITEFITS,'n'+galno+type.posfix+flag+'.fits',mom0s, mom0s_hd
        WRITEFITS,'n'+galno+type.posfix+flag+'_dp.fits',mom0dp, mom0dp_hd
        
        ; INTENSITY-WEIGHTED INTENSITY AT LOWER RESOLUTION
        if  ifail eq 0 and keyword_set(wtsm) then begin
          smooth3d,mom0rg*mom0rg,mom0rg_hd,mom0wts,mom0wts_hd,$
             [res_as,res_as*cos(ginc/180.*!dpi),gpa],$
             ifail=ifail,err=errm,psf_org=type.psf
          print,"scale back by",scale
          mom0wts=mom0wts/(mom0s/scale)
          DEPROJ_IM, mom0wts, mom0wts_hd, mom0wtdp, mom0wtdp_hd, ginc, gpa
          WRITEFITS,'n'+galno+type.posfix+'_iwt'+flag+'.fits',mom0wts, mom0wts_hd
          WRITEFITS,'n'+galno+type.posfix+'_iwt'+flag+'_dp.fits',mom0wtdp, mom0wtdp_hd
        endif
        
        
      endif
    endforeach

endforeach

END