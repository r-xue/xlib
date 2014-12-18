PRO GAL_DEPROJ,$
    cat=cat,$                                   ; galaxy/fileinfo table names
    fwhm=fwhm,kpc=kpc,select_res=select_res,$                     
    gselect=gselect,bselect=bselect,$           ; select galaxies and bands based on index in tables
    gkey=gkey,gval=gval,$                       ; select galaxies based on label
    bkey=bkey,bval=bval,$                       ; select bands based on label
    unmsk=unmsk,$
    sz_temp=sz_temp,ps_temp=ps_temp,radec_temp=radec_temp,im_temp=im_temp,$ 
    wtsm=wtsm,relax=relax,$
    nodp=nodp
;+
; NAME:
;   gal_deproj
;
; PURPOSE:
;   * smooth multi-band images to desired deprojected physical/spatial resolutions
;   * deproject images to face-on view with surface brightness corrected by mutiplying cos(inc)
;
; INPUTS:
;   FWHM        desired FWHM circular beam (in arcsec) after deprojection
;               Note: turn off convolution by setting fwhm=0
;   /KPC        FWHM is given in kpc rather than arcsec
;   /UNMSK      do NOT use the available mask image
;   SZ_TEMP     template size in pixel default: 1024
;               it could be a catalog header (e.g. 'HI sz_temp (")').
;               then sz_temp value will be read from the matching column.   
;   PS_TEMP     pixesize for the common frame
;   RADEC_TEMP  specify template center, default value from galaxy table
;   im_temp     choose a map type for the frame template. this will override ps/sz/radec_temp
;   gselect     select galaxies based on table index
;   bselect     select bands based on table index
;   select_res  select the resolution based on image tag, e.g. 
;                   select_res='hi'     smooth to HI resolution
;                   select_res='same'   fwhm will be choosen automatically 
;                                       based on the best common deprojected resolutions
;                                       offered by the selected multi-band dataset.
;   /wtsm       derive the intneisity-weighted intensity at lower resolutions
;   ref         galaxy metadata tag: 
;                   CGP:        CANON survey
;                   Coma:       Coma Cluster
;                   MAGMA/MGP:  LMC/SMC
;                   SGP:        STING           CO10/HI21cm
;                   TGP:        THING/HERACLES  CO21/HI21cm
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
;   *   nearby test
;       gal_deproj,select_res='same',bkey='test',bval='*nearby-r*'  ;r0
;       gal_deproj,select_res='same',bkey='test',bval='*nearby-r*',gkey='Galaxy',gval='ngc4654'  ;r0
;       gal_deproj,fwhm=0.25,/kpc,bkey='test',bval='*nearby-r*'     ;r1
;       gal_deproj,fwhm=0.50,/kpc,bkey='test',bval='*nearby-r*'     ;r2
;       gal_deproj,fwhm=1.00,/kpc,bkey='test',bval='*nearby-r*'     ;r3
;       gal_deproj,fwhm=2.00,/kpc,bkey='test',bval='*nearby-r*'     ;r4
;       
;       gal_deproj_ms,bkey='test',bval='*nearby-r*',out='r0'
;       gal_deproj_ms,bkey='test',bval='*nearby-r*',out='r1'
;       gal_deproj_ms,bkey='test',bval='*nearby-r*',out='r2'
;       gal_deproj_ms,bkey='test',bval='*nearby-r*',out='r3'
;       gal_deproj_ms,bkey='test',bval='*nearby-r*',out='r4'
;       
;   * M51
;       gal_deproj,select_res='same',gkey='Galaxy',gval='ngc5194',bkey='tracer',bval=['molecular','star','pah','atomic']
;       gal_deproj_ms,gkey='Galaxy',gval='ngc5194',bkey='tracer',bval=['molecular','star','pah','atomic'],out='m51'
;       plot,calc_cn(all_ms.hi_things,'HI',/msppc2),calc_cn(all_ms.co_paws,'CO1-0',/msppc2),psym=3,/xlog,/ylog,xrange=[0.1,100],yrange=[0.1,1000],xstyle=1,ystyle=1
;       plot,calc_cn(all_ms.hi_things,'HI',/msppc2),calc_cn(all_ms.co21,'CO2-1',/msppc2),psym=3,/xlog,/ylog,xrange=[0.1,100],yrange=[0.1,1000],xstyle=1,ystyle=1
;       gal_deproj,select_res='same',gkey='Galaxy',gval='ngc0772',bkey='tracer',bval=['molecular','star','pah','atomic']
;       gal_deproj_ms,gkey='Galaxy',gval='ngc0772',bkey='tracer',bval=['molecular','star','pah','atomic'],out='n0772'
;       plot,[1],[1],psym=3,/xlog,/ylog,xrange=[0.1,100],yrange=[0.1,1000],xstyle=1,ystyle=1
;       plot,calc_cn(all_ms.hi,'HI',/msppc2),calc_cn(all_ms.co,'CO1-0',/msppc2),psym=3,/xlog,/ylog,xrange=[0.1,100],yrange=[0.1,1000],xstyle=1,ystyle=1
;       oploterror,calc_cn(all_ms.hi,'HI',/msppc2),calc_cn(all_ms.co,'CO1-0',/msppc2),calc_cn(all_ms.hie,'HI',/msppc2),calc_cn(all_ms.coe,'CO1-0',/msppc2),psym=3
;
;   * FOV extracting for ATLAS plotting:
;     CO FOV:
;       gal_deproj,fwhm=0.0,/kpc,gkey='Project',gval='*SGP*',bkey='tag',bval=['co','comom1','coe','coerr','cosnrpk','irac1','nuv'],/unmsk,sz_temp=179,/nodp
;     HI FOV:
;       gal_deproj,fwhm=0.0,/kpc,gkey='Project',gval='*SGP*',bkey='tag',bval=['hi','himom1','hisnrpk','irac4','dss','sdssg','cont'],/unmsk,sz_temp='HI sz_temp (")',/nodp
;   

;   
;   * G/n mapping test (STING + MAGMA-LMC/SMC + THING/HERACLES: (in sting/gas-com)
;     extract a CO+HI dataset with smallest common resolution
;     LMC/SMC:
;       HI+MAGMA
;           gal_deproj,select=[1,2,4,5],ps_temp=30.0,gselect=[0],sz_temp=fix([8.0,7.8]*60.*60./30.),ref='MGP',/nodp,/common_res
;           gal_deproj,select=[1,2,4,5],ps_temp=15.0,gselect=[1],sz_temp=fix([3.3,2.8]*60.*60./15.),ref='MGP',/nodp,/common_res,radec_temp=[15.84013,-72.871587]
;       HI+NANTEN+MAGMA
;           gal_deproj,select=[0,1,2,3,4,5],ps_temp=30.0,gselect=[0],sz_temp=fix([8.0,7.8]*60.*60./30.),ref='MGP',/nodp,/common_res
;           gal_deproj,select=[0,1,2,3,4,5],ps_temp=15.0,gselect=[1],sz_temp=fix([3.3,2.8]*60.*60./15.),ref='MGP',/nodp,/common_res,radec_temp=[15.84013,-72.871587]
;     STING:
;           gal_deproj,select=[2,3,4,5,6,7,12,13]-2,ref='SGP',/nodp,/common_res
;           gal_deproj,select=[12,13]-2,ref='SGP',/nodp
;     THINGS/HERACLES
;           gal_deproj,select=[17,18,19,20],ref='TGP',sz_temp=1024,/nodp,/common_res (still limited by FOVs of HERACLES)
;           gal_deproj,select=[21,22]-2,ref='TGP',sz_temp=1024,/nodp (tgp-hinat)
;   * SDI vs. MSC test:
;     extract a dataset with common resolution on the same frame
;       gal_deproj,gselect=[14],im_temp=1,ref='MSC',/nodp,/common
;       
;   * MCs:
;   
;     extract a dataset for the dust SED fitting
;     
;       gal_deproj,select=[8,9,10,11,12,13,14,15,16,17,31,32]-2,ps_temp=10.0,ref='MGP',/nodp,/common_res,sz_temp=fix([8.0,7.8]*60.*60./10.)
;       
;     extract a dataset of M24/CO/I8/I8resid/HI with common resolution on the same frame
;       gal_deproj,select=[4,7,8,9,10,11,12,13,14,15,16,17,31,32,33,34,41]-2,gselect=[0],ref='MGP',/nodp,radec_temp=[81.0385,-71.9047],ps_temp=15,sz_temp=71,fwhm=46
;       gal_deproj,select=[4,7,8,9,10,11,12,13,14,15,16,17,31,32,33,34,41]-2,gselect=[0],ref='MGP',/nodp,radec_temp=[78.9374,-68.0443],ps_temp=15,sz_temp=71,fwhm=46
;       gal_deproj,select=[4,7,8,9,10,11,12,13,14,15,16,17,31,32,33,34,41,3,6]-2,gselect=[0],ref='MGP',/nodp,radec_temp=[80.56, -67.95],ps_temp=15,sz_temp=71,fwhm=46
;       gal_deproj,select=[4,7,8,9,10,11,12,13,14,15,16,17,31,32,33,34,41,3,6]-2,gselect=[0],ref='MGP',/nodp,radec_temp=[74.26666667,-66.40138889],ps_temp=15,sz_temp=181,fwhm=46
;       gal_deproj,select=[4,7,8,9,10,11,12,13,14,15,16,17,31,32,33,34,41,3,6]-2,gselect=[0],ref='MGP',/nodp,radec_temp=[85.,-70.5],ps_temp=15,sz_temp=721,fwhm=46
;
;       gal_deproj,select=[1,4,22],gselect=[0],im_temp=1,ref='MGP',/nodp,/common
;       gal_deproj,select=[4,7,24,25,26,33,34,37,39]-2,gselect=[0],im_temp=4,ref='MGP',/nodp,/common_res
;       gal_deproj,select=[31,32,29,30,33,2,5,6,7,8,9,10,34],gselect=[0],im_temp=31,ref='MGP',/nodp (in magmap-grid)
;     extract a dataset with native resolution + 60" pixel size on the same frame (in allmap-nat)
;       gal_deproj,ps_temp=60.0,gselect=[0],sz_temp=fix([8.0,7.8]*60.*60./60.),ref='MGP',/nodp
;       gal_deproj,ps_temp=60.0,gselect=[1],sz_temp=fix([6.0,4.5]*60.*60./60.),ref='MGP',/nodp
;     extract a dataset with native resolution + 15" pixel size on the same frame (in allmap-nat-sp)
;       gal_deproj,ps_temp=15.0,gselect=[0],sz_temp=fix([8.0,7.8]*60.*60./15.),ref='MGP',/nodp
;       gal_deproj,ps_temp=15.0,gselect=[1],sz_temp=fix([6.0,4.5]*60.*60./15.),ref='MGP',/nodp

;     extract a gasmap dataset with HI resolution and on the same frame (in gasmap-hires) * this version is for MAGCLOUDS
;       gal_deproj,select=[1,2,4,5],ps_temp=30.0,gselect=[0],sz_temp=fix([8.0,7.8]*60.*60./30.),ref='MGP',/nodp,/common_res
;       gal_deproj,select=[1,2,4,5],ps_temp=15.0,gselect=[1],sz_temp=fix([6.0,4.5]*60.*60./15.),ref='MGP',/nodp,/common_res
;     extract a gapmap dataset with NANTEN resolution and on the same frame (in gasmap-nantenres) * this version is for MAGCLOUDS
;       gal_deproj,select=[0,1,2,3,4,5],ps_temp=30.0,gselect=[0],sz_temp=fix([8.0,7.8]*60.*60./30.),ref='MGP',/nodp,/common_res
;       gal_deproj,select=[0,1,2,3,4,5],ps_temp=15.0,gselect=[1],sz_temp=fix([6.0,4.5]*60.*60./15.),ref='MGP',/nodp,/common_res
;

;       
;   * extracting a dataset with 1kpc resolution
;     gal_deproj,fwhm=1.0,/kpc 
;   * extracting a dataset with a round deprojected HI beam from the STING sample
;     gal_deproj,/hi_res, select=[0,1,4,5,6,7,8,9],ref='SGP',gselect=[0,1,2,3,4,5,6,9,11,12,14,15,16,17,18,19,20,21,22]
;     For some galaxy, the beam size of 1.5GHz continuum is larger than the beam size from the spectral cube.
;     We need to set a larger relax parameter:
;     gal_deproj,/hi_res, select=[4,5,6,7,8,9],ref='SGP',gselect=7,relax=2.5
;     gal_deproj,/hi_res, select=[4,5,6,7,8,9],ref='SGP',gselect=8,relax=1.5
;     gal_deproj,/hi_res, select=[4,5,6,7,8,9],ref='SGP',gselect=10,relax=1.5
;     gal_deproj,/hi_res, select=[4,5,6,7,8,9],ref='SGP',gselect=13,relax=0.5
;   * THINGS sample  
;     gal_deproj,/common_res, select=[17,18,19,20],ref='TGP',sz_temp=1024 (still limited by FOVs of HERACLES)
;   * STING sample
;     gal_deproj,/common_res, select=[0,1,4,5,6,11,12,17,18,19,20],ref='SGP'
;     gal_deproj,/common_res, select=[0,1,2,3,4,5,21,22],ref='SGP' ; CO Resolution (CO+FUV+IR)
;     gal_deproj,fwhm=0.0, select=[0,1,4,5,6,7,8,9,10,11,12],ref='SGP' ; native resolution for each type of maps
;     gal_deproj,fwhm=2.0,/kpc,select=[0,1,4,5,6,7,8,9,10,11,12],ref='SGP'
;     gal_deproj,fwhm=1.0,/kpc,select=[0,1,4,5,6,7,8,9,10,11,12],ref='SGP'
;   * extracting a dataset for plotting Katrina's figures:
;     gal_deproj,fwhm=0.0,/kpc, select=[0,1,2,3,4,6,7],sz_temp=179,/unmsk,ref='SGP'
;     gal_deproj,fwhm=0.0,/kpc, select=findgen(10),sz_temp=1024,/unmsk,ref='SGP'
;   * extracting a dataset for plotting a sample figure
;     gal_deproj,fwhm=0.0,/kpc, select=indgen(13),sz_temp=750,/unmsk, ref='CGP'
;     M51 dataset
;     gal_deproj,fwhm=15.0, select=indgen(19),sz_temp=750,/unmsk, ref='CGP',gselect=6
;     gal_deproj,/pacs3_res,select=[0,1,2,3,7,9],sz_temp=750,ref='CGP',gselect=0
;
;   * extracting a highest-resolution dataset for i8-co-uv correlations:
;     gal_deproj,/uv_res,select=[0,1,2,3,4,5,8,9,10,11]
;     gal_deproj,/uv_res,/ref,select=[0,1,2,3,8,9,10,11]
;   * extracting a highest-resolution dataset for i8-gas-uv correlations:
;     gal_deproj,/hi_res,select=[0,1,2,3,4,5,6,7,8,9,10,11]
;
;   * extract a 1kpc resolution dataset for comparing the area-/mass-weighted surface
;     density
;     gal_deproj,fwhm=1.0,/kpc, select=[2,4], /wtsm
;   * extract a 1kpc resolution dataset for comparing the area-/mass-weighted surface
;     density. Hoowever, we add 1.5sigma emission at non-detection region for testing
;     gal_deproj,fwhm=1.0,/kpc, select=[2,3,4,5,10,11,12,13,14,15,16,17], /wtsm
;
; HISTORY:
;
;   20120217  RX  introduced
;   20120220  RX  fix an issue dealing with an image with rotated pixels
;                 call smooth3d.pro for smoothing    
;   20130310  TW  do a loop over available images
;   20130410  RX  fix an issue related to images using "Jy/beam" as units
;                 use st_struct_build.pro to load galaxy parameters
;   20130412  RX  rename it to st_gal_deproj.pro, clean the code
;                 add GALEX data and IRAC4 processing
;   20130423  RX  add GALEX-wt images
;                 GALEX image units: CPS per pixel
;   20130503  RX  rename it to gal_deproj.pro and make it a general-purpose procedure
;                 fix an issue when processing image in extensions
;                 fix an issue when processing data from Herschel/PACS
;   20130731  RX  use a header key to specify <sz_temp>
;   20130806  RX  add an option nodp
;   20140625  RX  use gal_deproj_meta.pro to get galaxy/bands information from tables.
;                 better way to select galaxy/bands  
;-

;+
;NOTE:
;   IRAC appx PSF: http://irsa.ipac.caltech.edu/data/SPITZER/docs/irac/iracinstrumenthandbook/5/
;   GALEX appx PSF: http://www.galex.caltech.edu/wiki/Public:Documentation/Chapter_2
;-


; DEFAULT OPTIONS
; READ THE PARAMETERS FILE
resolve_routine,'gal_deproj_meta'
!except=1
if  n_elements(fwhm) eq 0 then fwhm=0
if  n_elements(sz_temp) eq 0 then sz_temp=1024
if  n_elements(relax) eq 0 then relax=0.2
if  n_elements(ps_temp) eq 0 then ps_temp=1.0
if  not keyword_set(cat) then cat='nearby'

GAL_DEPROJ_META, cat, g, gh, b, bh,$
    gselect=gselect,bselect=bselect,$  
    gkey=gkey,gval=gval,$              
    bkey=bkey,bval=bval

s=g
h=gh
types=b

gselect=indgen(n_elements(s.(0)))
select=indgen(n_elements(types))
subtypes=types[select]


foreach ind,gselect do begin
  
    gal=s.(where(h eq 'Galaxy'))[ind]
;    galno  = strmid(gal, 3, 4)
;    if ref eq 'CGP' then galno = strmid(gal, 4, 4)
    ;if ref eq 'TGP' then galno=gal
    galno=strtrim(gal,2)
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

    
    if  keyword_set(select_res) then begin
        fwhm=0.0
        foreach type,subtypes do begin
            
            imgfl =type.path+type.prefix+galno+type.posfix+'.fits'
            if  not file_test(imgfl) then continue
            
            bmaj=type.psf
            bmin=type.psf
            bpa=0.0

            if  type.psf eq -1 then begin
                imgfl = READFITS(imgfl,imgfl_hd,/silent)
                rd_hd, imgfl_hd, s = shi, c = chi, /full
                bmaj=shi.bmaj
                bmin=shi.bmin
                bpa=shi.bpa
            endif
            print,type.tag,'fwhm:',bmaj,bmin,bpa,'tabpsf:',type.psf,format='(a10,a10,f8.2,f8.2,f8.2,a10,f8.2)'
            DEPROJ_BEAM, bmaj, bmin, bpa, gpa, ginc, test_bmaj,test_bmin,test_bpa
            if select_res eq 'same' then begin
                fwhm=test_bmin>test_bmaj>fwhm
            endif else begin
                if type.tag eq select_res then fwhm=test_bmin>test_bmaj>fwhm
            endelse
        endforeach
        fwhm=fwhm+relax
        kpc=0
        print,  "-->  Selecting the deprojected resolution:    "+string(fwhm,format='(f8.2)')+' arcsec'
    endif
    
    if keyword_set(kpc) then res_as = fwhm*1000./as2pc else res_as = fwhm
    strres = strtrim(string(fix(res_as)),1)
    print,      '-->  Smoothing to the deprojected resolution: '+string(res_as,format='(f8.2)')+' arcsec'

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
    
    getrot,refhd,tmpra,tmpcd
    tmpsz=[abs(sxpar(refhd,'naxis1')),abs(sxpar(refhd,'naxis2'))]

    print,      '-->  Setting up template ['+strjoin(strtrim(tmpsz,2),',')+'] x '+strtrim(abs(tmpcd[0]*60.*60.),2)+' arcsec'       
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
        
        
        if  type.type eq '2de' or type.type eq '3de' then errm=1
        ;   oversampling will not change error map characteristics 
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
        if not keyword_set(nodp) then WRITEFITS,type.prefix+galno+type.posfix+flag+'_dp.fits',mom0dp, mom0dp_hd
        
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