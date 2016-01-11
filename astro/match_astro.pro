FUNCTION match_astro,image,flag=flag,$
    catfile=catfile,minsnr=minsnr,maxelong=maxelong,$   ; OPTION 1
    ra=ra,dec=dec,$                                     ; OPTION 2
    ximage=ximage,yimage=yimage,$                       ; OPTION 3
    gcntrd=gcntrd,cntrd=cntrd,fwhm=fwhm,$               ; OPTION 4
    refcat=refcat,$                                     ; USER REF OBJ LIST
    outname=outname,$
    xrms=xrms,yrms=yrms,xresid=xresid,yresid=yresid,success=success,$
    check_image=check_image
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

if  n_elements(dis) eq 0 then dis=3.0
if  n_elements(outname) eq 0 then outname='match_astro'
if  n_elements(minsnr) eq 0 then minsnr=15.0
if  n_elements(maxelong) eq 0 then maxelong=1.2 ;ell=0.1
if  n_elements(fwhm) eq 0 then fwhm=4.0
if  n_elements(flag) eq 0 then flag=''

catalogs=['GSC2.3','SDSS-DR7','SDSS-DR9']
tags=['_gsc232','_sdss7','_sdss9']
constraints=['Class=0','us=1,gs=1,rs=1,is=1,zs=1','us=1,gs=1,rs=1,is=1,zs=1']

catalogs=['SDSS-DR9']
tags=['_sdss9']
constraints=['gs=1,rs=1,is=1']

if  n_elements(refcat) ne 0 then begin
    catalogs=[catalogs,refcat.name]
    tags=[tags,'_'+string(refcat.name)]
    constraints=[constraints,'user']
endif

;   We alway use SDSS-DR7 as the reference here.

ms=[]

for i=0,n_elements(catalogs)-1 do begin
    
    ;   QUERY CATALOG STARS
        
    if  constraints[i] ne 'user' then begin 
        st=query_refobj(image,flag=flag,catalog=catalogs[i],$
            constraint=constraints[i],sat=50000.0,/nan,iso=3.0,$
            outname=outname+tags[i]+'_match_astro_radec')
        if  size(st,/tn) ne size({tmp:''},/tn) then continue
            rlist=st.RAJ2000
            dlist=st.DEJ2000
    endif else begin
        rlist=refcat.ra
        dlist=refcat.dec
    endelse
    
    ;   GET "EXPECTED" STAR X-Y POSITION BASED ON:
    ;       * stars ra/dec in the reference system
    ;       * original image header 
    hd=headfits(image)
    getrot,hd,ang,cdelt
    psize=abs(cdelt[0])*60.0*60.0
    adxy,hd,rlist,dlist,xlist,ylist ; <--

    ;   GET STAR-LIKE OBJECT X-Y POSITION

    if  n_elements(catfile) ne 0 then begin
        tb=mrdfits(catfile,2)
        tb=tb[where(tb.snr_win gt minsnr and tb.ELONGATION le maxelong and tb.flags eq 0)]
        xi=tb.x_image-1. ; pixel number -> IDL index
        yi=tb.y_image-1. ; pixel number -> IDL index
    endif
    if  n_elements(ra) ne 0 then begin
        adxy,hd,ra,dec,xi,yi
    endif
    if  n_elements(x) ne 0 then begin
        xi=x
        yi=y
    endif
    if  keyword_set(gcntrd) then begin
        im=readfits(image,hd)
        gcntrd,im,xlist,ylist,xi,yi,fwhm/psize,/silent,MAXGOOD=25000
    endif
    if  keyword_set(cntrd) then begin
        im=readfits(image,hd)
        cntrd,im,xlist,ylist,xi,yi,fwhm/psize,/silent
    endif

    ;   CROSS-MATCHING IMAGE-OBJECTS AND CATALOG STARS

    result=matchall_2d(xlist,ylist,xi,yi,dis/psize,nwithin)
    tag_gsc=where(nwithin eq 1.0)
    ind=result[result[[tag_gsc]]]
    
    print,'cross-matching candidate pairs: ',n_elements(tag_gsc)

    xcat=xlist[tag_gsc]
    ycat=ylist[tag_gsc]
    ximg=xi[ind]
    yimg=yi[ind]
    xd=ximg-xcat
    yd=yimg-ycat
    
    astr_new=solve_astro(rlist[tag_gsc],dlist[tag_gsc],ximg+1.0,yimg+1.0,$
        naxis1=sxpar(hd,'NAXIS1'),naxis2=sxpar(hd,'NAXIS2'),$
        CRVAL=[sxpar(hd,'CRVAL1'),sxpar(hd,'CRVAL2')],$
        distort='tnx',xterms=2,etaorder=6,xiorder=6,niter=3,$
        xirms=xrms,etarms=yrms,xiresid=xiresid,etaresid=etaresid,success=success,wfit=wfit)

    extast,hd,astr
    hd_new=hd
    putast,hd_new,astr_new
    ;    print,'new astr:'
    ;    print,astr
    ;    print,'old astr:'
    ;    print,astr_new

    histlabel = 'MATCH_ASTRO: '
    SXADDPAR, hd_new, 'HISTORY', histlabel+systime()
    SXADDPAR, hd_new, 'HISTORY', histlabel+'image='+image
    SXADDPAR, hd_new, 'HISTORY', histlabel+'flag='+flag
    SXADDPAR, hd_new, 'HISTORY', histlabel+'outname='+outname
    
    
    ;   OPTIONAL: PRODUCE CHECK CUBE

    if  keyword_set(check_image) then begin
        xra=rlist[tag_gsc]
        xdec=dlist[tag_gsc]
        cube1=make_array(51,51,n_elements(xra),/f,/no,value=!values.f_nan)
        cube2=make_array(51,51,n_elements(xra),/f,/no,value=!values.f_nan)
        im=readfits(image,hd)
        for k=0,n_elements(xra)-1 do begin
            temphd=mk_hd([xra[k],xdec[k]],51,psize/3.0)
            hastrom_nan,im,hd,imk,imkhd,temphd,missing=!VALUES.F_NAN,/silent,interp=0
            cube1[*,*,k]=imk
            hastrom_nan,im,hd_new,imk,imkhd,temphd,missing=!VALUES.F_NAN,/silent,interp=0
            cube2[*,*,k]=imk
        endfor
        writefits,outname+tags[i]+'_match_astro_check-old.fits',cube1
        writefits,outname+tags[i]+'_match_astro_check-new.fits',cube2
    endif

    tmp={   refsys:catalogs[i],$
            astr:astr_new,$
            hd:hd_new}
    ms=[ms,tmp]
    
    ;   WRITE OUT CHECK PLOTS
    
    set_plot,'ps'
    device,filename=outname+tags[i]+'_match_astro_check.eps',bits=8,$
        xsize=8,ysize=8.0,$
        /inches,/encapsulated,/color
    !p.thick=2.0
    !x.thick = 2.0
    !y.thick = 2.0
    !z.thick = 2.0
    !p.charsize=0.8
    !p.charthick=2.0
    !x.gridstyle = 0
    !y.gridstyle = 0
    xyouts,'!6'

    ;+++++++
    ; BEFORE
    ;+++++++
    
    plot,xd*(-psize),yd*psize,psym=symcat(3),xrange=[1.5,-1.5],$
        yrange=[-1.5,1.5],xstyle=1,ystyle=1,$
        xtitle='',ytitle=textoidl('\delta eta ["]'),$
        title='Offsets: Measured-Expected('+catalogs[i]+')',$
        pos=[0.1,0.5,0.5,0.9],/noe,xtickformat='(A1)'
    
    ;oplot,xd[wfit]*psize,yd[wfit]*psize,psym=symcat(9),color=cgcolor('red')
    
    RESISTANT_Mean, xd, 2, xm, sigdx
    RESISTANT_Mean, yd, 2, ym, sigdy
    
    al_legend,outname,box=0,/left,/bottom
    
    al_legend,$
      ['matching rate:',$
      string(n_elements(ximg),format='(i4)')+'/'+$
      string(n_elements(xlist),format='(i4)'),$
      'xrms='+string(sigdx,format='(f6.3)')+'"',$
      'xrms='+string(sigdy,format='(f6.3)')+'"',$
      'xoffset='+string(xm*(-psize),format='(f6.3)')+'"',$
      'yoffset='+string(ym*psize,format='(f6.3)')+'"',$
      'pix='+strtrim(string(psize,format='(f6.3)'),2)+'"'],$
      box=0,$
      /right,/top
    
    oplot,xm*psize*[-1,-1],[-10,10],color=cgcolor('red'),thick=4
    oplot,[-10,10],ym*psize*[1,1],color=cgcolor('red'),thick=4
    
    plot,xcat,yd*psize,yrange=[-1.7,1.7],psym=symcat(3),xrange=[0,sxpar(hd,'NAXIS1')],xstyle=1,/noe,$
        pos=[0.6,0.75,0.99,0.9],$
        xtitle='px',ytitle=textoidl('\delta ETA ["]'),ystyle=1,symsize=0.5

    oplot,[0,100000],ym*psize*[1,1],color=cgcolor('red'),thick=4

    plot,ycat,xd*(-psize),yrange=[-1.7,1.7],psym=symcat(3),xrange=[0,sxpar(hd,'NAXIS2')],xstyle=1,/noe,$
        pos=[0.6,0.55,0.99,0.70],$
        xtitle='py',ytitle=textoidl('\delta XI ["]'),ystyle=1,symsize=0.5

    oplot,[0,100000],xm*psize*[-1,-1],color=cgcolor('red'),thick=4
    
    ;+++++++
    ; AFTER
    ;+++++++
    
    adxy,hd_new,rlist,dlist,xlist,ylist

    xcat=xlist[tag_gsc]
    ycat=ylist[tag_gsc]
    xd=ximg-xcat
    yd=yimg-ycat
    
    
    plot,xd*(-psize),yd*psize,psym=symcat(3),xrange=[1.5,-1.5],$
      yrange=[-1.5,1.5],xstyle=1,ystyle=1,$
      xtitle=textoidl('\delta xi ["]'),ytitle=textoidl('\delta eta ["]'),$
      pos=[0.1,0.1-0.01,0.5,0.5-0.01],/noe

    ;oplot,xd[wfit]*psize,yd[wfit]*psize,psym=symcat(9),color=cgcolor('red')

    RESISTANT_Mean, xd, 2, xm, sigdx
    RESISTANT_Mean, yd, 2, ym, sigdy

    al_legend,outname,box=0,/left,/bottom

    al_legend,$
      ['matching rate:',$
      string(n_elements(ximg),format='(i4)')+'/'+$
      string(n_elements(xlist),format='(i4)'),$
      'xrms='+string(sigdx,format='(f6.3)')+'"',$
      'xrms='+string(sigdy,format='(f6.3)')+'"',$
      'xoffset='+string(xm*(-psize),format='(f6.3)')+'"',$
      'yoffset='+string(ym*psize,format='(f6.3)')+'"',$
      'pix='+strtrim(string(psize,format='(f6.3)'),2)+'"'],$
      box=0,$
      /right,/top

    oplot,xm*psize*[-1,-1],[-10,10],color=cgcolor('red'),thick=4
    oplot,[-10,10],ym*psize*[1,1],color=cgcolor('red'),thick=4

    plot,xcat,yd*psize,yrange=[-1.7,1.7],psym=symcat(3),xrange=[0,sxpar(hd,'NAXIS1')],xstyle=1,/noe,$
      pos=[0.6,0.5-0.01-0.15,0.99,0.5-0.01],$
      xtitle='px',ytitle=textoidl('\delta ETA ["]'),ystyle=1,symsize=0.5

    oplot,[0,100000],ym*psize*[1,1],color=cgcolor('red'),thick=4

    plot,ycat,xd*(-psize),yrange=[-1.7,1.7],psym=symcat(3),xrange=[0,sxpar(hd,'NAXIS2')],xstyle=1,/noe,$
      pos=[0.6,0.5-0.01-0.15-0.05-0.15,0.99,0.5-0.01-0.15-0.05],$
      xtitle='py',ytitle=textoidl('\delta XI ["]'),ystyle=1,symsize=0.5

    oplot,[0,100000],xm*psize*[-1,-1],color=cgcolor('red'),thick=4
    
    device,/close
    set_plot,'x'
    
    ;WRITE OUT DS9 REGION FILE IN IMAGE COORDS
;    temp = {ds9reg, $
;        shape:'circle', $         ;- shape of the region
;        x:0., $             ;- center x position
;        y:0., $             ;- center y position
;        radius:0.2, $       ;- radius (if circle). Assumed to be arcsec
;        angle:0., $         ;- angle, if relevant. Degrees.
;        text:'', $          ;- text label
;        color:'red', $      ;- region color
;        width:10., $        ;- width (if relevant)
;        height:10., $       ;- height (if relevant)
;        font:'', $          ;- font for label
;        select:1B, $        ;- is selected?
;        fixed:0B, $         ;- is fixed?
;        edit:1B, $          ;- is editable?
;        move:1B, $          ;- is moveable?
;        rotate:0B, $        ;- can be rotated?
;        delete:1B}          ;- can be deleted?
;
;    cxy=replicate(temp,n_elements(xlist[ind]))
;    cxy.color='blue'
;    cxy.x=xlist[ind]
;    cxy.y=ylist[ind]
;
;    print,'catalogue xy ds9 region file: ',outname+tags[i]+'_cxy.reg'
;    write_ds9reg,outname+tags[i]+'_match_astro_cxy.reg',cxy,'IMAGE'
;
;    sxy=replicate(temp,n_elements(tag_gsc))
;    sxy.color='red'
;    sxy.x=xi[ind]
;    sxy.y=yi[ind]
;
;    print,'sextractor xy ds9 region file: ',outname+tags[i]+'_sxy.reg'
;    write_ds9reg,outname+tags[i]+'_match_astro_sxy.reg',sxy,'IMAGE'

endfor

return,ms

END


PRO TEST_MATCH_ASTRO

astr=match_astro('../images/R_NDWFS1.fits',catfile='../psfex/R_NDWFS1.cat',$
    flag='../images/R_NDWFS1_flag.fits',$
    outname='R_NDWFS1_test')
im=readfits('../images/R_NDWFS1.fits',hd_old)
writefits,'R_NDWFS1_new.fits',im,astr[2].hd
hd=match_astro('R_NDWFS1_new.fits',catfile='../psfex/R_NDWFS1.cat',$
    flag='../images/R_NDWFS1_flag.fits',$
    outname='R_NDWFS1_new')

END

