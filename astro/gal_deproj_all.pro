PRO GAl_DEPROJ_ALL, fwhm=fwhm, kpc=kpc, $
    hi_res=hi_res,uv_res=uv_res,pacs3_res=pacs3_res,common_res=common_res,$
    select=select,ref=ref,$
    unmsk=unmsk, sz_temp=sz_temp,wtsm=wtsm,relax=relax,$
    gselect=gselect, nodp=nodp, ps_temp=ps_temp, im_temp=im_temp,radec_temp=radec_temp
;+
; NAME:
;   gal_deproj_all
;
; PURPOSE:
;   * smooth multi-band images to desired deprojected physical/spatial resolutions
;   * deproject images to face-on view with surface brightness corrected by mutiplying cos(inc)
;
; INPUTS:
;   FWHM        desired FWHM circular beam (in arcsec) after deprojection
;               Note: turn off convolution by setting fwhm=0
;   /KPC        FWHM is given in kpc rather than arcsec
;   /UNMSK      do NOT use the mask image of IRAC1
;   SZ_TEMP     template size in pixel default: 1024
;   PS_TEMP     pixesize for the common frame
;               it could be a catalog header (e.g. 'HI sz_temp (")').
;               then sz_temp value will be read from the matching column.
;   im_temp     choose a map type for the frame template. this will override ps_temp & sz_temp
;   radec_temp  specify template center
;   select      choose only some types of data for processing
;               e.g. select=[0,1] -- only process IRAC1 & IRAC4 
;               (see the structure info in st_struct_fileinfo.pro)
;   /hi_res     fwhm will be choosen automatically according to native resolutions of HI data
;   /common_res fwhm will be choosen automatically according to the best common deprojected resolutions
;               offered by the selected multi-band dataset  
;   /wtsm       derive the intneisity-weighted intensity at lower resolutions
;   ref         use the reference galaxy table: 'CGP' or 'SGP'
;   relax       the relaxing parameter for choosing common resolution (in arcsec)
;   /nodp       no deprojection is carried out by override inc=0.0
;   
;   
; OUTPUTS:
;   note:      only galaxies with file names like "*smo*.fits" were processed succesfully for 
;              smoothing/deproejcting
;
; EXAMPLES:
; 
;   * SDI vs. MSC test:
;     extract a dataset with common resolution on the same frame
;       gal_deproj_all,gselect=[14],im_temp=1,ref='MSC',/nodp,/common
;       
;   * MCs:
;     extract a dataset of M24/CO/I8/I8resid/HI with common resolution on the same frame 
;       gal_deproj_all,select=[1,4,22],gselect=[0],im_temp=1,ref='MGP',/nodp,/common
;       gal_deproj_all,select=[31,32,29,30,33,2,5,6,7,8,9,10,34],gselect=[0],im_temp=31,ref='MGP',/nodp (in magmap)
;       gal_deproj_all,select=[31,32,29,30,33,2,5,6,7,8,9,10,34],gselect=[0],im_temp=31,ref='MGP',/nodp (in magmap-grid)
;     extract a dataset with native resolution + 60" pixel size on the same frame (in allmap-nat)
;       gal_deproj_all,ps_temp=60.0,gselect=[0],sz_temp=fix([8.0,7.8]*60.*60./60.),ref='MGP',/nodp
;       gal_deproj_all,ps_temp=60.0,gselect=[1],sz_temp=fix([6.0,4.5]*60.*60./60.),ref='MGP',/nodp
;     extract a dataset with native resolution + 15" pixel size on the same frame (in allmap-nat-sp)
;       gal_deproj_all,ps_temp=15.0,gselect=[0],sz_temp=fix([8.0,7.8]*60.*60./15.),ref='MGP',/nodp
;       gal_deproj_all,ps_temp=15.0,gselect=[1],sz_temp=fix([6.0,4.5]*60.*60./15.),ref='MGP',/nodp
;       
;     extract a gasmap dataset with HI resolution and on the same frame (in gasmap-hires)
;       gal_deproj_all,select=[1,2,4,5],ps_temp=30.0,gselect=[0],sz_temp=fix([8.0,7.8]*60.*60./30.),ref='MGP',/nodp,/common_res
;       gal_deproj_all,select=[1,2,4,5],ps_temp=15.0,gselect=[1],sz_temp=fix([6.0,4.5]*60.*60./15.),ref='MGP',/nodp,/common_res
;     extract a gapmap dataset with NANTEN resolution and on the same frame (in gasmap-nantenres)
;       gal_deproj_all,select=[0,1,2,3,4,5],ps_temp=30.0,gselect=[0],sz_temp=fix([8.0,7.8]*60.*60./30.),ref='MGP',/nodp,/common_res
;       gal_deproj_all,select=[0,1,2,3,4,5],ps_temp=15.0,gselect=[1],sz_temp=fix([6.0,4.5]*60.*60./15.),ref='MGP',/nodp,/common_res
;
;   * FOV extracting:
;     CO FOV: 
;       gal_deproj_all,fwhm=0.0,/kpc, select=[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,21,22],sz_temp=179,/unmsk,ref='SGP'
;     HI FOV: 
;       gal_deproj_all,fwhm=0.0,/kpc, select=[0,1,2,3,9,10,11,12],sz_temp='HI sz_temp (")',/unmsk,ref='SGP'
;   * extracting a dataset with 1kpc resolution
;     gal_deproj_all,fwhm=1.0,/kpc 
;   * extracting a dataset with a round deprojected HI beam from the STING sample
;     gal_deproj_all,/hi_res, select=[0,1,4,5,6,7,8,9],ref='SGP',gselect=[0,1,2,3,4,5,6,9,11,12,14,15,16,17,18,19,20,21,22]
;     For some galaxy, the beam size of 1.5GHz continuum is larger than the beam size from the spectral cube.
;     We need to set a larger relax parameter:
;     gal_deproj_all,/hi_res, select=[4,5,6,7,8,9],ref='SGP',gselect=7,relax=2.5
;     gal_deproj_all,/hi_res, select=[4,5,6,7,8,9],ref='SGP',gselect=8,relax=1.5
;     gal_deproj_all,/hi_res, select=[4,5,6,7,8,9],ref='SGP',gselect=10,relax=1.5
;     gal_deproj_all,/hi_res, select=[4,5,6,7,8,9],ref='SGP',gselect=13,relax=0.5
;   * THINGS sample  
;     gal_deproj_all,/common_res, select=[17,18,19,20],ref='TGP',sz_temp=1024 (still limited by FOVs of HERACLES)
;   * STING sample
;     gal_deproj_all,/common_res, select=[0,1,4,5,6,11,12,17,18,19,20],ref='SGP'
;     gal_deproj_all,/common_res, select=[0,1,2,3,4,5,21,22],ref='SGP' ; CO Resolution (CO+FUV+IR)
;     gal_deproj_all,fwhm=0.0, select=[0,1,4,5,6,7,8,9,10,11,12],ref='SGP' ; native resolution for each type of maps
;     gal_deproj_all,fwhm=2.0,/kpc,select=[0,1,4,5,6,7,8,9,10,11,12],ref='SGP'
;     gal_deproj_all,fwhm=1.0,/kpc,select=[0,1,4,5,6,7,8,9,10,11,12],ref='SGP'
;   * extracting a dataset for plotting Katrina's figures:
;     gal_deproj_all,fwhm=0.0,/kpc, select=[0,1,2,3,4,6,7],sz_temp=179,/unmsk,ref='SGP'
;     gal_deproj_all,fwhm=0.0,/kpc, select=findgen(10),sz_temp=1024,/unmsk,ref='SGP'
;   * extracting a dataset for plotting a sample figure
;     gal_deproj_all,fwhm=0.0,/kpc, select=indgen(13),sz_temp=750,/unmsk, ref='CGP'
;     M51 dataset
;     gal_deproj_all,fwhm=15.0, select=indgen(19),sz_temp=750,/unmsk, ref='CGP',gselect=6
;     gal_deproj_all,/pacs3_res,select=[0,1,2,3,7,9],sz_temp=750,ref='CGP',gselect=0
;
;   * extracting a highest-resolution dataset for i8-co-uv correlations:
;     gal_deproj_all,/uv_res,select=[0,1,2,3,4,5,8,9,10,11]
;     gal_deproj_all,/uv_res,/ref,select=[0,1,2,3,8,9,10,11]
;   * extracting a highest-resolution dataset for i8-gas-uv correlations:
;     gal_deproj_all,/hi_res,select=[0,1,2,3,4,5,6,7,8,9,10,11]
;
;   * extract a 1kpc resolution dataset for comparing the area-/mass-weighted surface
;     density
;     gal_deproj_all,fwhm=1.0,/kpc, select=[2,4], /wtsm
;   * extract a 1kpc resolution dataset for comparing the area-/mass-weighted surface
;     density. Hoowever, we add 1.5sigma emission at non-detection region for testing
;     gal_deproj_all,fwhm=1.0,/kpc, select=[2,3,4,5,10,11,12,13,14,15,16,17], /wtsm
;
; HISTORY:
;
;   20120217  RX  introduced
;   20120220  RX  fix an issue dealing with an image with rotated pixels
;                 call smooth3d.pro for smoothing    
;   20130310  TW  do a loop over available images
;   20130410  RX  fix an issue related to images using "Jy/beam" as units
;                 use st_struct_build.pro to load galaxy parameters
;   20130412  RX  rename it to st_gal_deproj_all.pro, clean the code
;                 add GALEX data and IRAC4 processing
;   20130423  RX  add GALEX-wt images
;                 GALEX image units: CPS per pixel
;   20130503  RX  rename it to gal_deproj_all.pro and make it a general-purpose procedure
;                 fix an issue when processing image in extensions
;                 fix an issue when processing data from Herschel/PACS
;   20130731  RX  use a header key to specify <sz_temp>
;   20130806  RX  add an option nodp
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
if n_elements(relax) eq 0 then relax=0.2
if n_elements(ps_temp) eq 0 then ps_temp=1.0

; READ THE PARAMETERS FILE
gal_struct_build,ref,s,h
if n_elements(gselect) eq 0 then gselect=indgen(n_elements(s.(0)))


; LOAD PATH/FILENAME INFO
types=gal_deproj_fileinfo(ref)
if n_elements(select) eq 0 then select=indgen(n_elements(types))
subtypes=types[select]

foreach ind,gselect do begin
  
    gal=s.(where(h eq 'Galaxy'))[ind]
;    galno  = strmid(gal, 3, 4)
;    if ref eq 'CGP' then galno = strmid(gal, 4, 4)
    ;if ref eq 'TGP' then galno=gal
    galno=gal
    print, replicate('-',40)
    print, 'Working on galaxy number ',galno,' index',ind
    gpa  = float(s.(where(h eq 'Adopted PA (deg)'))[ind])
    ginc = float(s.(where(h eq 'Adopted Inc (deg)'))[ind])
    if keyword_set(nodp) then ginc=0.0
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
        fwhm=test_bmin>test_bmaj+relax
        kpc=0
        print, "-->  choosing HI deprojected resolution: "+string(fwhm)
      endif
    endif
    
    if keyword_set(uv_res) then begin
      fwhm=0
      m=where(types.tag eq 'nuv')
      DEPROJ_BEAM, types[m].psf, types[m].psf, 0.0, gpa, ginc, test_bmaj,test_bmin,test_bpa
      fwhm=test_bmin>test_bmaj+relax
      kpc=0
      print, "-->  choosing UV deprojected resolution: "+string(fwhm)
    endif
    
    if keyword_set(pacs3_res) then begin
      fwhm=0
      m=where(types.tag eq 'pacs160')
      DEPROJ_BEAM, types[m].psf, types[m].psf, 0.0, gpa, ginc, test_bmaj,test_bmin,test_bpa
      fwhm=test_bmin>test_bmaj+relax
      kpc=0
      print, "-->  choosing PACS169 deprojected resolution: "+string(fwhm)
    endif
    
    if keyword_set(common_res) then begin
      fwhm=0.0
      foreach type,subtypes do begin
        bmaj=type.psf
        bmin=type.psf
        bpa=0.0
        if type.psf eq -1 then begin
          imgfl =type.path+type.prefix+galno+type.posfix+'.fits'
          if file_test(imgfl) then begin
            imgfl = READFITS(imgfl,imgfl_hd,/silent)
            rd_hd, imgfl_hd, s = shi, c = chi, /full
            bmaj=shi.bmaj
            bmin=shi.bmin
            bpa=shi.bpa
          endif
        endif
        print,type.tag,'fwhm:',bmaj,bmin,format='(a10,a10,f10.2,f10.2)'
        DEPROJ_BEAM, bmaj, bmin, bpa, gpa, ginc, test_bmaj,test_bmin,test_bpa
        fwhm=test_bmin>test_bmaj>fwhm
      endforeach
      fwhm=fwhm+relax
      kpc=0
      print, "-->  Choosing the best deprojected resolution: "+string(fwhm)+' arcsec'
    endif
    
    if keyword_set(kpc) then res_as = fwhm*1000./as2pc else res_as = fwhm
    strres = strtrim(string(fix(res_as)),1)
    print,'-->  Smoothing to a resolution of '+string(res_as)+' arcsec'

    ; SET UP TEMPLATE FOR REGRIDDING: default: 1024 x 1024, 1"
    
    if size(sz_temp,/tn) eq size(' ',/tn) $ 
      then sz_im=float(strsplit(s.(where(h eq sz_temp))[ind],',',/extract)) $
      else sz_im=sz_temp
    if n_elements(sz_im) eq 1 then sz_im=replicate(sz_im,2)
    refhd = MK_HD([ra,dec],sz_im,ps_temp)
    if  keyword_set(radec_temp) then begin
        refhd=mk_hd(radec_temp,sz_im,ps_temp)
    endif
    
    if  keyword_set(im_temp) then begin
        refim=types[im_temp].path+types[im_temp].prefix+galno+types[im_temp].posfix+'.fits'
        tmp=readfits(refim,refhd,/silent)
    endif
    
    print,'-->  setting up template ['+strjoin(string(sz_im),',')+'] x '+string(ps_temp)+' arcsec'       
    foreach type,subtypes do begin
      
      imgfl =type.path+type.prefix+galno+type.posfix+'.fits'
      print,'check  ->'+imgfl
      if file_test(imgfl) then begin
        print,'process->'+imgfl
        mom0 = READFITS(imgfl,mom0_hd)
        if n_elements(mom0) eq 1 then mom0 = READFITS(imgfl,mom0_hd,ext=1)
;        if (size(mom0))[0] gt 2 then begin
;          mom0=mom0[*,*,0]
;          SXADDPAR,mom0_hd,'NAXIS3',1
;        endif
        mkfl = type.path+type.prefix+galno+type.mask+'.fits'
        if file_test(mkfl) eq 1 and not keyword_set(unmsk) then begin
           mk = READFITS(mkfl,mk_hd,/silent)
           mom0[where(mk ne 0,/null)]=!VALUES.F_NAN
        endif
        errm=0
        
        
        if STRPOS(type.posfix, '.emom0') ne -1 then errm=1
        if STRPOS(type.posfix, '.4e') ne -1 then errm=1
        if STRPOS(type.posfix, '.1e') ne -1 then errm=1
        if STRPOS(type.posfix, '.sen') ne -1 then errm=1
        if STRPOS(type.posfix, '.err') ne -1 then errm=1
        if STRPOS(type.posfix, '.unc') ne -1 then errm=1
        REGRID3D, mom0,mom0_hd,mom0rg,mom0rg_hd,refhd
        

        ; AREA-WEIGHTED INTENSITY AT LOWER RESOLUTION
        UNDEFINE,scale
        SMOOTH3D,mom0rg,mom0rg_hd,mom0s,mom0s_hd,$
             [res_as,res_as*cos(ginc/180.*!dpi),gpa],$
             ifail=ifail,err=errm,psf_org=type.psf,scale=scale
        DEPROJ_IM, mom0s, mom0s_hd, mom0dp, mom0dp_hd, ginc, gpa
        if  file_test(mkfl) eq 1 and not keyword_set(unmsk) then flag='_mskd' else flag=''
        if  ifail eq 0 then flag=flag+'_smo'+strres else flag=''
        WRITEFITS,type.prefix+galno+type.posfix+flag+'.fits',mom0s, mom0s_hd
        if not keyword_set(nodp) then WRITEFITS,galno+type.posfix+flag+'_dp.fits',mom0dp, mom0dp_hd
        
        ; INTENSITY-WEIGHTED INTENSITY AT LOWER RESOLUTION
        if  ifail eq 0 and keyword_set(wtsm) then begin
          smooth3d,mom0rg*mom0rg,mom0rg_hd,mom0wts,mom0wts_hd,$
             [res_as,res_as*cos(ginc/180.*!dpi),gpa],$
             ifail=ifail,err=errm,psf_org=type.psf
          print,"scale back by",scale
          mom0wts=mom0wts/(mom0s/scale)
          DEPROJ_IM, mom0wts, mom0wts_hd, mom0wtdp, mom0wtdp_hd, ginc, gpa
          WRITEFITS,type.prefix+galno+type.posfix+'_iwt'+flag+'.fits',mom0wts, mom0wts_hd
          if not keyword_set(nodp) then WRITEFITS,galno+type.posfix+'_iwt'+flag+'_dp.fits',mom0wtdp, mom0wtdp_hd
        endif
        
        
      endif
    endforeach

endforeach

END