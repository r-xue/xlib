PRO IMS_MAKEMASK,str,areamax=areamax,$
    flatrange=flatrange,fwhm=fwhm,$
    silent=silent
;+
;   create bg images
;   create masked images
;   smask: star mask parameters in arcsec
;   xrange/yrange/bin for plotting background histogram
;-

ra=str.ra
dec=str.dec
name=str.outname

if  ~keyword_set(areamax) then areamax=!dpi*8^2.0   ; basically when will use the center continous region..
if  ~keyword_set(flatrange) then flatrange=[5.0,10.0]
if  ~n_elements(fwhm) then fwhm=0.9     ; if dist(peak,catcenter) gt 3.0 then reject 

for io=0,n_elements(name)-1 do begin

    ; LOAD IMAGES
    
    if  ~file_test(name[io]+'.fits') then continue
    if  ~file_test(name[io]+'_seg.fits') then continue
    if  ~file_test(name[io]+'_seg_edge.fits') then continue
    if  ~file_test(name[io]+'_sbg.fits') then continue
    if  ~file_test(name[io]+'_flag.fits') then continue
    
    imk=readfits(name[io]+'.fits',imkhd,/silent)                ;   oimg image
    sbg=readfits(name[io]+'_sbg.fits',sbghd,/silent)       ;   sbkg image
    msk_edge=readfits(name[io]+'_seg_edge.fits',mskhd,/silent)  ;   segm image
    msk_core=readfits(name[io]+'_seg.fits',mskhd,/silent)       ;   segm image
    flg=readfits(name[io]+'_flag.fits',flghd,/silent)           ;   flag image
    
    getrot,imkhd,rotang,cdelt
    psize=abs(cdelt[0]*60.*60.)
    adxy,imkhd,ra[io],dec[io],xc,yc
    sz=size(imk,/dim)
    dist_ellipse,temp,sz[[0,1]],xc,yc,1.0,0.
    temp=temp*psize

    if  ~(xc le sz[0]-1 and xc ge 0 and yc le sz[1]-1 and yc ge 0) then continue
    
    ;   IF NO VALID DATA THEN SKIP

    vtag=where(imk eq imk and msk_core eq 0 and flg eq 0,con)
    if  con eq 0 then continue
    vtag=where(imk eq imk and msk_core eq 0 and flg eq 0 and temp gt flatrange[0] and temp le flatrange[1],con)
    if  con eq 0 then continue

    msk_tmp1=(msk_edge+flg) ne 0
    msk_tmp2=(msk_core+flg) ne 0
    msk_best=float(dilate_mask(msk_tmp2, constraint = msk_tmp1))
    ;        for i=0,1 do begin
    ;            for j=0,1 do begin
    ;                emsk=(emsk+shift(emsk,i,j)+shift(emsk,-i,j)+shift(emsk,i,-j)+shift(emsk,-i,-j))
    ;            endfor
    ;        endfor
    writefits,name[io]+'_mask.fits',msk_best,flaghd


    ;   SUBTRACT LARGE-SCALE BACKGROUND
    
    imk_sub=imk*!values.f_nan
    imk_mkd=imk*!values.f_nan
    vtag=where(imk eq imk and flg eq 0,con)
    imk_sub[vtag]=imk[vtag];-sbg[vtag]
    vtag=where(imk eq imk and msk_best eq 0 and flg eq 0,con)
    imk_mkd[vtag]=imk[vtag];-sbg[vtag]
    
    ;   RECOVERING SCIENCE TARGET (if the msk_best in center)
    
    if  msk_best[round(xc),round(yc)] ne 0 then begin
        
        recover=0.0
        id=msk_edge[round(xc)-1:round(xc)+1,round(yc)-1:round(yc)+1]
        id=max(id)
        id_tag=where(msk_edge eq id,cont)
        if  ~keyword_set(silent) then begin
            print,'ra,dec',double(ra[io]),double(dec[io])
            print,'xc,yc:',xc,yc
            print,'id(edge_seg):',id
        endif

        cat=mrdfits(name[io]+'_edge.cat',2,/silent)
        objx=(cat.xpeak_image)[id-1]-1.0
        objy=(cat.ypeak_image)[id-1]-1.0
        obje=(cat.elongation)[id-1]
        objerra=(cat.erra_image)[id-1]
        objerrb=(cat.errb_image)[id-1]
        fluxauto=(cat.FLUX_AUTO)[id-1]
        fluxauto_err=(cat.FLUXERR_AUTO)[id-1]
        objfwhm=(cat.fwhm_world)[id-1]*3600.0
        if  ~keyword_set(silent) then begin
            print,'center object properties:'
            print,'ids/obje:',id,obje,objerra,objerrb,FLUXAUTO,FLUXAUTO_err,objfwhm,((cont*psize^2.0)/!dpi)^0.5
            print,'objx/objy/catx/caty/dis',objx,objy,xc,yc,((objx-xc)^2.0+(objy-yc)^2.0)^0.5*psize
        endif
        if  cont*psize^2.0 le areamax then recover=1.0
        if  ((objx-xc)^2.0+(objy-yc)^2.0)^0.5*psize gt fwhm/2.0 then recover=recover*0.0
        if  obje gt 2.0 then recover=recover*0.0

        if  total(msk_best*1.0) gt n_elements(flg)*0.5 then recover=recover*0.0
        
        if  ~keyword_set(silent) then print,'recover:',round(recover)
        if  recover ne 0 then begin
            imk_mkd[where(msk_edge eq id and flg eq 0, /null)]=imk_sub[where(msk_edge eq id and flg eq 0, /null)]
        endif
        
    endif
    
    ;   CREATE CORRECTED IMAGES
    
    vtag=where(imk_mkd eq imk_mkd and temp gt flatrange[0] and temp le flatrange[1])
    resistant_mean,imk_mkd[vtag],3.0,skymod_imk,sigma_imk,num_rej
    sigma_imk=sigma_imk*sqrt((n_elements(vtag)-num_rej-1)*1.0)
    imk_gro=radprofile_grow(imk_mkd,xc,yc,1.0,/fast,addnoise=sigma_imk)
    
    ;   SUBTRACT GLOBAL-SCALE BACKGROUND
    
    vtag=where(imk_mkd eq imk_mkd and temp gt flatrange[0] and temp le flatrange[1])
    bgk_vec=imk_mkd[vtag]
    resistant_mean,bgk_vec,3.0,skymod_imk,sigma_imk,num_rej
    sigma_imk=sigma_imk*sqrt((n_elements(vtag)-num_rej-1)*1.0)
    mmm,bgk_vec,skymod_imk,sigma_mk,skew
    ;removesky=median(bgk_vec)
    removesky=skymod_imk
    removesky=0.0
    
    if  ~keyword_set(silent) then begin
        print,replicate('+',20)
        print,'sky npixel:',n_elements(vtag)
        print,'resistant_mean for msk_core: sky/sig/skew/npix/med:',skymod_imk,sigma_imk,n_elements(bgk_vec),median(bgk_vec)
        print,replicate('+',20)
    endif
    
    imk_sub=imk_sub-removesky;skymod_imk
    imk_mkd=imk_mkd-removesky;skymod_imk
    imk_gro=imk_gro-removesky;skymod_imk
    
    sxaddpar, imkhd, 'DATAMAX', max(imk_mkd,/nan),before='HISTORY'
    sxaddpar, imkhd, 'DATAMIN', min(imk_mkd,/nan),before='HISTORY'
    sxaddpar, imkhd, 'MMMSKY',skymod_imk
    sxaddpar, imkhd, 'MMMSIG',sigma_imk
    writefits,name[io]+'_mkd.fits',float(imk_mkd),imkhd
    sxaddpar, imkhd, 'DATAMAX', max(imk_sub,/nan),before='HISTORY'
    sxaddpar, imkhd, 'DATAMIN', min(imk_sub,/nan),before='HISTORY'
    sxaddpar, imkhd, 'MMMSKY',skymod_imk
    sxaddpar, imkhd, 'MMMSIG',sigma_imk
    writefits,name[io]+'_sub.fits',float(imk_sub),imkhd
    sxaddpar, imkhd, 'DATAMAX', max(imk_gro,/nan),before='HISTORY'
    sxaddpar, imkhd, 'DATAMIN', min(imk_gro,/nan),before='HISTORY'
    sxaddpar, imkhd, 'MMMSKY',skymod_imk
    sxaddpar, imkhd, 'MMMSIG',sigma_imk
    writefits,name[io]+'_gro.fits',float(imk_gro),imkhd

endfor

END



;        if  obj_reg[round(objx),round(objy)] eq obj_i or obj_reg[round(objx),round(objy)] eq 0 then begin
;
;            ;if  objfwhm gt 1.65 then recover=recover*0.0
;            ;if  obje gt 2.00 and (fluxauto gt 6.0*fluxauto_err) then recover=recover*0.0
;        endif
;        val=va_edge
;        msk_ids=msk_edge[where(msk_edge eq val_edge and msk_best ne 0)]
;        msk_ids_n=n_elements(rem_dup(msk_ids))
;        ;+ label_region will fix the bug in segmentmap (isolated segments with the same index)
;        if  msk_ids_n eq 1 then begin
;;            msk_cat=name[io]+'_edge.cat'
;;            obj_reg=label_region(msk_edge eq val_edge)
;;            tmp=where(msk_edge eq val_edge,cont)
;            val=val_edge
;        endif else begin
;            msk_cat=name[io]+'.cat'
;            obj_reg=label_region(msk_core eq val_core)
;            tmp=where(msk_core eq val_core,cont)
;            val=val_core
;        endelse
;
;        obj_i=obj_reg[round(xc),round(yc)]
;        if  obj_i eq 0 then begin
;            obj_i=max(obj_reg[round(xc)-1:round(xc)+1,round(yc)-1:round(yc)+1])
;        endif

;    val_edge=msk_edge[round(xc),round(yc)]
;    if  val_edge eq 0 then begin
;        val_edge=msk_edge[round(xc)-1:round(xc)+1,round(yc)-1:round(yc)+1]
;        val_edge=max(val_edge)
;    endif
;    val_core=msk_core[round(xc),round(yc)]
;    if  val_core eq 0 then begin
;        val_core=msk_core[round(xc)-1:round(xc)+1,round(yc)-1:round(yc)+1]
;        val_core=max(val_core)
;    endif
;   seg from sextractor might not be uniq.
;   msk=label_region(msk) depending on how they split objects...
;+
;   we only recover center objects when:
;       size<areamax (in arcsec^2.0) (avoid contamination)
;       sextractor ojects center within 3" of our sources. (avoid blending sources)
;-


;EXPANDING BLANKING MASK
;            temp=imk_mkd*0.0
;            for i=0,1 do begin
;                for j=0,1 do begin
;                    temp=(temp+shift(imk_mkd,i,j)*0.0+shift(imk_mkd,-i,j)*0.0+shift(imk_mkd,i,-j)*0.0+shift(imk_mkd,-i,-j)*0.0)
;                endfor
;            endfor
;            imk_mkd=imk_mkd+temp
;;   ADD STAR MASK
;if  keyword_set(smask) then begin
;    mask=star_mask(imk_new,round(xc),round(yc),dr=smask[0]/psize,dx=smask[1]/psize,dy=smask[2]/psize,ds=smask[3]/psize)
;    imk_new[where(mask ne 0,/null)]=!values.f_nan
;endif
;   xrange=xrange,yrange=yrange,bin=bin,plot=plot
;        ; PLOT BACKGROUND HISTOGRAMS
;
;        if  keyword_set(plot) then begin
;
;            eps=[eps,name[io]+'_background']
;            set_plot,'ps'
;            device,filename=name[io]+'_background.eps',bits=8,$
;                xsize=7.5,ysize=7.5,$
;                /inches,/encapsulated,/color
;            !p.thick=2.0
;            !x.thick = 2.0
;            !y.thick = 2.0
;            !z.thick = 2.0
;            !p.charsize=1.0
;            !p.charthick=2.0
;            !x.gridstyle = 0
;            !y.gridstyle = 0
;            xyouts,'!6'
;            plot,xrange,yrange,xstyle=1,ystyle=1,/nodata
;            plothist1d,bgk_vec,bin,color=cgcolor('gray'),xmin=xrange[0],xmax=xrange[1]
;            oplot,[skymod,skymod],[0,1e5]
;            oplot,[skymod,skymod]+sigma,[0,1e5]
;            oplot,[skymod,skymod]-sigma,[0,1e5]
;            plot,xrange,yrange,xstyle=1,ystyle=1,/nodata,/noe
;            al_legend,name[io]
;            device,/close
;            set_plot,'x'
;
;        endif
;   if  keyword_set(plot) then pineps,csv+'_'+band+'_bg',eps,/clean