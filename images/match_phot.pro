FUNCTION match_phot,catfile,imfile,band
;+
; NAME:
;   match_astro
;
; PURPOSE:
;   obtain new astrometry using a list of star-like objects (based on the input image) 
;   and catalogue stars (from vizier or user inputs)
;     
;
; INPUTS:
;   image           fits image
;   [flag]          flag image
;
;   >information on image-based objects
;   
;   +++OPTION 1
;   [catfile]       LDAC catalogue fits (from a deep sextractor run)
;                   require x_image/y_image
;   [minsnr]        require snr_win
;   [maxelong]      require ELONGATION         
;   
;   +++OPTION 2
;   [ra/dec]        RA/DEC [must be tied to the fits image astrometry] 
;
;   +++OPTION 3
;   [x/y]           x/y (IDL convention) in the fits image
;   
;   +++OPTION 4
;   [/gcntrd or /cntrd]
;   [fwhm=4]        gcntrd/cntrd FWHM
;
;   [outname]       name for eps plots and ds9 reg file
;                   outname*_match_astro_check.eps
;                   outname*_match_astro_cxy.reg
;                   outname*_match_astro_sxy.reg
;   
;   >information on reference objects in desired astrometry
;   
;       default it will pick up ['GSC2.3','SDSS-DR7','SDSS-DR9']
;       you might specify your own using. 
;           refcat  .ra:    R.A. J2000 (vector)
;                   .dec:   Dec. J2000 (vector)
;                   .name:  string for labeling your reference system
;        
;   
;   [dis]           in arcsec
;   
; 
; RETURN:
;   structure containing astrometry/header information (could be vectors)
;       .refsys     reference system name
;       .astr       astrometry structure
;       .hd         updated image header
;   
; OUTOUTS:
;   xrms            xrms
;   yrms            yrms
;   xresid          xresid
;   yresid          yresid
;   hd              update header for fits image (vector, one for each catalog)
;   
; KEYWORDS:
;
; NOTES:
;   
;   * catalogue descriptions:  http://vizier.u-strasbg.fr/vizier/cats/U.htx
;   
;   * if only one imobject-i is within <dis> of catstar-j, then we consider im-object-i x cat-star-j is 
;     a valid pair (candidate) for solving astrometry.
;   
;   * we only used "isolated" cat-stars queried "on-the-fly", which are less likely to be blended in images.
;   
;   * assume the astrometry of input image is not way off. 
;   
;   * it's better to have a matching list which are:
;       star-like (e.g. class_star>0.95)
;       not saturated (e.g. flag=0/1)
;       high SNR (e.g. snr_win>20)
;       small elongation (e.g. elongation<1.2) 
;       relatively isolated in deep catalogues (try match2d)
;       
;   * Even with some mis-matching in candidate pairs, solve_astro.pro will throw away outliners.
;
; HISTORY:
;   20150812    R.Xue   add comments
;   20150814    R.Xue   change from procedure to function and rename it to MATCH_ASTRO
;   20150821    R.Xue   add an option using ra/dec or x/y (IDL convention) vector instead of LDAC catalogue
;                       now includes 3 catalogs=['GSC2.3','SDSS-DR7','SDSS-DR9']
;
;-

hd = mrdfits(catfile,1)
tb = mrdfits(catfile,2)
print,hd
print,tag_names(tb)

;reftb=query_refobj(imfile,catalog='SDSS-DR9',constraint='us=1,gs=1,rs=1,is=1,zs=1')
;;reftb=query_refobj(imfile,catalog='SDSS-DR9')
;;restore,'ia445_NDWFS1_refobj.xdr'
;cat=reftb
;print,tag_names(cat)
;sdss=cat
;sdra = sdss.raj2000
;sddec = sdss.dej2000
;sdG = sdss.Gmag
;sdGerr = sdss.e_Gmag
;sdG = sdss.Gpmag
;sdGerr = sdss.e_Gpmag

sdss=mrdfits('/Users/Rui/Workspace/highz/products/dey/Stacks/Bootes_SDSS.fits',1)
sdra = sdss.ra
sddec = sdss.dec
sdG = sdss.G
sdGerr = sdss.err_G


;sdU = sdss.Umag
;sdR = sdss.Rmag
;sdI = sdss.Imag
;sdZ = sdss.Zmag
;sdUerr = sdss.e_Umag
;sdRerr = sdss.e_Rmag
;sdIerr = sdss.e_Imag
;sdZerr = sdss.e_Zmag
;nsd = n_elements(sdU)


;ra = tb.alphawin_j2000
;dec = tb.deltawin_j2000
ra = tb.alpha_j2000
dec = tb.delta_j2000
mag4 = tb.mag_aper[4]
mag4err = tb.magerr_aper[4]
magiso = tb.mag_iso
magisoerr = tb.magerr_iso
magauto = tb.mag_auto
magautoerr = tb.magerr_auto
f1 = tb.flags
f3 = tb.imaflags_iso

tt=where(magisoerr le 0.05 and mag4err le 0.2 and magauto le 30 and f3 le 19 and f1 lt 1 and magautoerr le 0.05)  


ra = ra[tt]
dec = dec[tt]
;mag4 = mag4[tt]
;mag4err = mag4err[tt]
magiso = magiso[tt]
magisoerr = magisoerr[tt]
magauto = magauto[tt]
magautoerr = magautoerr[tt]
f1 = f1[tt]
f3 = f3[tt]


;f3 = tb.imaflags_iso

if  band eq 'r' then begin
    sdm=sdr
    sdmerr=sdrerr
endif

if  band eq 'g' then begin
    sdm=sdg
    sdmerr=sdgerr
endif

if  band eq 'i' then begin
    sdm=sdi
    sdmerr=sdierr
endif

res=matchall_sph(sdra,sddec,ra,dec,1.0/60./60.,nwidth)
sdtag=where(nwidth eq 1 and sdmerr le 0.05 and sdmerr gt 0.0 and sdm le 23.0 and sdm ge 15.0)
tbtag=res[res[sdtag]]

x=magauto[tbtag]
y=sdm[sdtag]
xe=magautoerr[tbtag]
f1=f1[tbtag]
tag=where(xe le 0.05 and f1 le 4)


plot,y[tag],x[tag]-y[tag],psym=symcat(16),xstyle=1,ystyle=1,yrange=[-1,1],xrange=[17,23],$
    xtitle='SDSS-g',ytitle='MAG_IM-MAG_SDSS'
offset=median(x[tag]-y[tag])
print,'mag_im-mag_sdss',offset
oplot,[0,30],[0,0]+offset,color=cgcolor('red')
oplot,[0,30],[0,0]
al_legend,"zpt(IM-SDSS)="+string(offset,format='(f6.2)')

END

PRO TEST_MATCH_PHOT

catfile='test_psfex_all.cat'
;temp=match_phot('R_NDWFS1_all.cat','../images/R_NDWFS1.fits','r')
;temp=match_phot('I_NDWFS1_all.cat','../images/I_NDWFS1.fits','i')
;temp=match_phot('Bw_NDWFS1_all.cat','../images/Bw_NDWFS1.fits','i')

;temp=match_phot('wrc4_pcf1_all.cat','../images/wrc4_pcf1.fits','r')
;temp=match_phot('wrc4_pcf2_all.cat','../images/wrc4_pcf2.fits','r')

;temp=match_phot('R_pcf1_all.cat','../images/R_pcf1.fits','r')
;temp=match_phot('R_pcf2_all.cat','../images/R_pcf2.fits','r')

;temp=match_phot('I_pcf1_all.cat','../images/I_pcf1.fits','i')
;temp=match_phot('I_pcf2_all.cat','../images/I_pcf2.fits','i')

;temp=match_phot('ia445_NDWFS1_all.cat','../images/ia445_NDWFS1.fits','g')
;temp=match_phot('ia445_NDWFS4_all.cat','../images/ia445_NDWFS4.fits','g')
;temp=match_phot('ia445_NDWFS5_all.cat','../images/ia445_NDWFS5.fits','g')
temp=match_phot('ia445_NDWFS6_all.cat','../images/ia445_NDWFS6.fits','g')
;temp=match_phot('LAE1_ia445_nosm.cat','LAE1_ia445_nosm.fits','g')
;temp=match_phot('LAE1_ia445.cat','LAE1_ia445.fits','g')

;temp=match_phot('mos027sS.fits.cat','mos027sS.fits','g')


END
