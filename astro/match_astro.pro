FUNCTION match_astro,image,flag=flag,$
    catfile,minsnr=minsnr,maxelong=maxelong,$
    outname=outname,$
    hd=hd,$
    xrms=xrms,yrms=yrms,xresid=xresid,yresid=yresid,success=success
;+
; NAME:
;   match_astro
;
; PURPOSE:
;   match astrometry using catalogue stars
;
; INPUTS:
;   image           fits image
;   [flag]          flag image
;   catfile         LDAC catalogue (from a deep sextractor run)
;                   require x_image/y_image 
;   [outname]       name for eps plots and ds9 reg file
;                   outname*_match_astro_check.eps
;                   outname*_match_astro_cxy.reg
;                   outname*_match_astro_sxy.reg
;   [dis]           [arcsec]
;                   if the LDAC only contained 1 object with in [dis] arcsec of star-i, then
;                   we consider star-i and this LDAC object are a valid pair for solving
;                   astrometry
; 
; RETURN:
;   updated astrometry structure 
;   
; OUTOUTS:
;   xrms            xrms
;   yrms            yrms
;   xresid          xresid
;   yresid          yresid
;   hd              update header for fits image
;   
; KEYWORDS:
;
; NOTES:
;   catalogue:  http://vizier.u-strasbg.fr/vizier/cats/U.htx 
;
; HISTORY:
;   20150812    R.Xue   add comments
;   20150814    R.Xue   change from procedure to function and rename it to MATCH_ASTRO
; 
; NOTE:
;   plan to add an option using gcntrd for star image centroid rather than using sextractor catalog
;
;-

if  n_elements(dis) eq 0 then dis=3.0
if  n_elements(outname) eq 0 then outname='match_astro'
if  n_elements(minsnr) eq 0 then minsnr=20.0
if  n_elements(maxelong) eq 0 then maxelong=1.12 ;ell=0.1

catalogs=['GSC2.3','SDSS-DR7']
tags=['_gsc','_sdss']
constraints=['Class=0','us=1,gs=1,rs=1,is=1,zs=1']

;   We alway use SDSS-DR7 as the reference here.

for i=0,1 do begin
    
    ;   QUERY CATALOGUE STARS
        
    st=query_refobj(image,flag=flag,catalog=catalogs[i],$
        constraint=constraints[i],sat=50000.0,/nan,iso=4)
    rlist=st.RAJ2000
    dlist=st.DEJ2000
    hd=headfits(image)
    getrot,hd,ang,cdelt
    psize=abs(cdelt[0])*60.0*60.0
    adxy,hd,rlist,dlist,xlist,ylist
    
    ;   IDL index to pixel index
    
    xlist=xlist+1.0
    ylist=ylist+1.0
    
    ;   CROSS MATCHING OBJECTS
    
    tb=mrdfits(catfile,2)
    tb=tb[where(tb.snr_win gt minsnr and tb.ELONGATION le maxelong)]
    result=matchall_2d(xlist,ylist,tb.x_image,tb.y_image,dis/psize,nwithin)
    tag_gsc=where(nwithin eq 1.0)
    ind=result[result[[tag_gsc]]]
    print,'cross-matching objects: ',n_elements(tag_gsc)
    xd=xlist[tag_gsc]-(tb.x_image)[ind]
    yd=ylist[tag_gsc]-(tb.y_image)[ind]
    
    if  catalogs[i] eq 'SDSS-DR7' then begin
        astr_new=solve_astro(rlist[tag_gsc],dlist[tag_gsc],(tb.x_image)[ind],(tb.y_image)[ind],$
            naxis1=sxpar(hd,'NAXIS1'),naxis2=sxpar(hd,'NAXIS2'),$
            CRVAL=[sxpar(hd,'CRVAL1'),sxpar(hd,'CRVAL2')],$
            xirms=xrms,etarms=yrms,xiresid=xresid,etaresid=yresid,success=success)
        extast,hd,astr
        print,'new astr:'
        print,astr
        print,'old astr:'
        print,astr_new
        putast,hd,astr_new
    end

    ;   WRITE OUT DS9 REGION FILE IN IMAGE COORDS
    
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
    
    cxy=replicate(temp,n_elements(xlist[ind]))
    cxy.color='blue'
    cxy.x=xlist[ind]
    cxy.y=ylist[ind]
    
    print,'catalogue xy ds9 region file: ',outname+tags[i]+'_cxy.reg'
    write_ds9reg,outname+tags[i]+'_match_astro_cxy.reg',cxy,'IMAGE'
    
    sxy=replicate(temp,n_elements(tag_gsc))
    sxy.color='red'
    sxy.x=(tb.x_image)[ind]
    sxy.y=(tb.y_image)[ind]
    
    print,'sextractor xy ds9 region file: ',outname+tags[i]+'_sxy.reg'
    write_ds9reg,outname+tags[i]+'_match_astro_sxy.reg',sxy,'IMAGE'
    
    ;   WRITE OUT CHECK PLOTS
    
    set_plot,'ps'
    device,filename=outname+tags[i]+'_match_astro_check.eps',bits=8,$
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
    
    plot,xd*psize,yd*psize,psym=symcat(9),xrange=[1.5,-1.5],$
        yrange=[-1.5,1.5],xstyle=1,ystyle=1,$
        xtitle=textoidl('\delta X ["]'),ytitle=textoidl('\delta Y ["]'),$
        title='Offset: '+strupcase(catalogs[i])+' - Measured'
    
    xm=median(xd*psize)
    ym=median(yd*psize)
    
    al_legend,outname,box=0,/left,/bottom
    
    if  catalogs[i] eq 'SDSS-DR7' then begin
        al_legend,$
            ['xrms='+string(xrms,format='(f6.2)')+'"',$
            'xrms='+string(yrms,format='(f6.2)')+'"',$
            'xoffset='+string(xm,format='(f6.2)')+'"',$
            'yoffset='+string(ym,format='(f6.2)')+'"'],$
            box=0,$
            /right,/top
    endif
    oplot,xm*[1,1],[-10,10],color=cgcolor('red'),thick=4
    oplot,[-10,10],ym*[1,1],color=cgcolor('red'),thick=4
    
    device,/close
    set_plot,'x'

endfor

return,astr_new

END

PRO TEST_match_astro

astr=match_astro('../images/R_NDWFS1.fits','../psfex/R_NDWFS1.cat',$
    flag='../images/R_NDWFS1_flag.fits',$
    outname='R_NDWFS1_test',$
    hd=hd)
im=readfits('../images/R_NDWFS1.fits',hd_old)
writefits,'R_NDWFS1_new.fits',im,hd
hd=match_astro('R_NDWFS1_new.fits','../psfex/R_NDWFS1.cat',$
    flag='../images/R_NDWFS1_flag.fits',$
    outname='R_NDWFS1_new')
    
END
