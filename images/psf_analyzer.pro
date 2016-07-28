PRO PSF_ANALYZER,name,im,flag_image=flag_image
;+
;   use psfex_analyzer products to do some evaluations of the PSFEX results
;-

print,''
print,replicate('+',30)
print,'working on   ',name
print,replicate('+',30)
print,''

;   QUERY GSC CAT / MAKE DS9 REGION FILE

gsc_all=query_refobj(im,$
    flag=flag_image,$
    catalog='GSC2.3',constraint='Class=0',$
    outname=name+'_gsc')
gsc_uns=query_refobj(im,$
    flag=flag_image,/nan,$
    catalog='GSC2.3',constraint='Class=0',$
    outname=name+'_gsc')

print,'all gsc:',n_elements(gsc_all)
print,'uns gsc:',n_elements(gsc_uns)
print,'sat gsc:',n_elements(gsc_all)-n_elements(gsc_uns)

gsc=gsc_all
save,gsc,filename=name+'_gsc_refobj.xdr'
   
ra_gsc=gsc.raj2000
dec_gsc=gsc.dej2000

cube=name+'_vignet.fits'
cube=readfits(cube)
tb=mrdfits(name+'.cat',2)
ra_sex=tb.x_world
dec_sex=tb.y_world
;print,'psfex_vignet:',tag_names(tb)
print,'all vig:',n_elements(ra_sex)

result=matchall_sph(ra_gsc,dec_gsc,ra_sex,dec_sex,1.0/60./60.*0.8,nwithin)
tag=where(nwithin eq 1)
print,string('one to one match:',format='(A-30)'),string(n_elements(tag),format='(i10)')
;
;ind=Result[Result[[tag]]]
;tt=where(tb[ind].flags le 1 and tb[ind].class_star gt 0.95)
;ind=ind[tt]
;print,string('scat okay:',format='(A-30)'),string(n_elements(tt),format='(i10)')








;xdrlist=[]
;subcube=cube[*,*,ind]
;subcube[where(subcube le -1e20,/null)]=!values.f_Nan
;writefits,name+'_psf_star.fits',subcube
;
;for kk=0,n_elements(ind)-1 do begin
;    subim=cube[*,*,ind[kk]]
;    subim[where(subim le -1e20,/null)]=!values.f_Nan
;    writefits,name+'_psf_star'+strtrim(kk+1,2)+'.fits',subim
;    if  total(float(subim eq subim)) le float(n_elements(subim))/2 then continue
;    tmp=radprofile_analyzer(name+'_psf_star'+strtrim(kk+1,2)+'.fits',outname=name+'_psf_star'+strtrim(kk+1,2)+'.xdr',psize=0.150,skyrad=[7,10])
;    xdrlist=[xdrlist,name+'_psf_star'+strtrim(kk+1,2)+'.xdr']
;endfor
;
;;xhs_stack_process_radprofile_plot,xdrlist,'../psf/'+name+'_psf'
;
;im2d_median=median(subcube,dim=3)
;writefits,'../psfex/'+blist[i]+'_'+plist[i]+'_vignet_median.fits',im2d_median

END




;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;+
;   use HST GUIDE STARS for analyzing the image PSF
;-


;plot=plot,magzero=magzero
;

;print,'run psf_analyzer:'
;print,im
;print,catfile+'.cat'
;print,catfile+'_all.cat'
;
;catalogs=['GSC2.3','SDSS-DR7']
;tags=['_gsc','_sdss']
;
;for i=0,1 do begin
;
;    star_pick,im,name+tags[i],flag=flag,catalog=catalogs[i]
;    temp={source:'',$
;        objname:'',$
;        outname:'',$
;        ra:!values.f_nan,$
;        dec:!values.f_nan,$
;        bxsz:!values.f_nan,$
;        cell:!values.f_nan,$
;        band:'',$
;        imfile:'',$
;        ptile:0.95,$
;        imext:0.0,$
;        proc:0.0,$
;        imunit:'counts/s'}
;    st=read_csv(name+tags[i]+'.csv')
;    rlist=st.field1
;    dlist=st.field2
;    hd=headfits(im)
;    getrot,hd,ang,cdelt
;    psize=abs(cdelt[0])*60.0*60.0
;
;    adxy,hd,rlist,dlist,xlist,ylist
;    xlist=xlist+1.0
;    ylist=ylist+1.0
;
;    tb=mrdfits(catfile+'.cat',2)
;    tb_all=mrdfits(catfile+'_all.cat',2)
;
;    print,'high SNR Objects : ', n_elements(tb.x_image)
;    print,'ALL OBjects      : ', n_elements(tb_all.x_image)
;
;    result=matchall_2d(tb.X_IMAGE,tb.Y_IMAGE,tb_all.X_IMAGE,tb_all.Y_IMAGE,3./0.258,nwithin)
;    tag=where(nwithin eq 1.0)
;    ximage=(tb.X_IMAGE)[tag]
;    yimage=(tb.Y_IMAGE)[tag]
;    print,'isolated objects : ', n_elements(tag)
;
;    result=matchall_2d(ximage,yimage,xlist,ylist,4,nwithin)
;    tag_gsc=where(nwithin eq 1.0)
;    ind=Result[Result[[tag_gsc]]]
;    print,'cross-matching objects: ',n_elements(tag_gsc)
;    xd=xlist[ind]-ximage[tag_gsc]
;    yd=ylist[ind]-yimage[tag_gsc]
;
;
;    temp = {ds9reg, $
;        shape:'circle', $         ;- shape of the region
;        x:0., $             ;- center x position
;        y:0., $             ;- center y position
;        radius:10., $        ;- radius (if circle). Assumed to be arcsec
;        angle:0., $         ;- angle, if relevant. Degrees.
;        text:'', $          ;- text label
;        color:'red', $         ;- region color
;        width:10., $         ;- width (if relevant)
;        height:10., $        ;- height (if relevant)
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
;    print,'catalogue xy ds9 region file: ',name+tags[i]+'_cxy.reg'
;    write_ds9reg,name+tags[i]+'_cxy.reg',cxy,'IMAGE'
;
;    sxy=replicate(temp,n_elements(ximage[tag_gsc]))
;    sxy.color='red'
;    sxy.x=ximage[tag_gsc]
;    sxy.y=yimage[tag_gsc]
;
;    print,'sextractor xy ds9 region file: ',name+tags[i]+'_sxy.reg'
;    write_ds9reg,name+tags[i]+'_sxy.reg',sxy,'IMAGE'
;
;    set_plot,'ps'
;    device,filename=name+tags[i]+'_check.eps',bits=8,$
;        xsize=5.5,ysize=5.5,$
;        /inches,/encapsulated,/color
;    !p.thick=2.0
;    !x.thick = 2.0
;    !y.thick = 2.0
;    !z.thick = 2.0
;    !p.charsize=1.0
;    !p.charthick=2.0
;    !x.gridstyle = 0
;    !y.gridstyle = 0
;    xyouts,'!6'
;
;    plot,xd*psize,yd*psize,psym=symcat(9),xrange=[1.5,-1.5],$
;        yrange=[-1.5,1.5],xstyle=1,ystyle=1,$
;        xtitle=textoidl('\delta X ["]'),ytitle=textoidl('\delta Y ["]')
;
;    xm=median(xd*psize)
;    ym=median(yd*psize)
;
;    al_legend,name,box=0,/left,/top
;    al_legend,'Offset: '+repstr(tags[i],'_','')+' - Measured',box=0,/left,/bottom
;    oplot,xm*[1,1],[-10,10],color=cgcolor('red'),thick=4
;    oplot,[-10,10],ym*[1,1],color=cgcolor('red'),thick=4
;
;    device,/close
;    set_plot,'x'
;
;endfor


;---------------------------------------------------------------------------------------------------



;tag=tag[tag_gsc]
;print,n_elements(tag)



;; NDWFS Dey15 fields
;
;fields=['J1434p3311',$
;    'J1431p3311',$
;    'J1434p3346',$
;    'J1431p3346']
;bands=['Bw','R','I']
;repo='/Users/Rui/Workspace/highz/products/NDWFS/images/'
;
;foreach field,fields do begin
;    foreach band,bands do begin
;        im=repo+'NDWFS'+field+'_'+band+'_03.fits'
;        name='dey15_'+band+'_'+field
;        XHS_STACK_PSF_PICK_GUIDESTARS,im,name
;    endforeach
;endforeach
;
;; PCF1/2 fields
;
;fields=['pcf1','pcf2']
;bands=['Bw','R','I','wrc4']
;repo='/Users/Rui/Workspace/highz/products/mosaic/'
;
;foreach field,fields do begin
;    foreach band,bands do begin
;        im=repo+'stack_'+band+'_'+field+'.fits'
;        name='pcf_'+band+'_'+field
;        XHS_STACK_PSF_PICK_GUIDESTARS,im,name
;    endforeach
;endforeach

; MOSAIC Dey15 FIELDs



;for i=0,0 do begin
;    im=repo+bands[i]+'.fits'
;    XHS_STACK_PSF_PICK_GUIDESTARS,im,names[i],mask=repo+'maskiabw.fits.fz'
;    xhs_stack_cutouts,names,band,bxsz=60.0
;    xhs_stack_sexfind,field+'_bstar',band+'_'+field,bg_size=30.0
;    xhs_stack_mask,field+'_bstar',band+'_'+field,bin=10,xrange=[-400,400],yrange=[0,5000]
;    xhs_stack_extract,field+'_bstar',band+'_'+field,rbin=0.258,rout=30.0
;    xhs_stack_extract_plot,field+'_bstar',band+'_'+field,xrange=[0,10],yrange1=[0.001,1e7],yrange2=[0.0001,500],$
;        ymin=5e4,ymax=2e5
;    xhs_stack_extract_model,field+'_bstar',band+'_'+field
;endfor

;XHS_STACK_PSF_PICK_GUIDESTARS,$
;    '/Users/Rui/Workspace/highz/products/dey/rgLAE1_Bw_scaled.fits.fz',$
;    'dey15_bstar_Bw_mosaic',$
;    mask='/Users/Rui/Workspace/highz/products/dey/maskiabw.fits.fz'
;    if  ~keyword_set(format) then format='fits'; format='fits.fz'
;
;    im='/Users/Rui/Workspace/highz/products/*/'+filename+'.'+format
;    imlist=file_search(im)
;    im=readfits(imlist[0],hd)
;    if  keyword_set(mask) then begin
;        mk='/Users/Rui/Workspace/highz/products/*/'+mask+'.'+format
;        mklist=file_search(mk)
;        mk=readfits(mklist[0],mkhd)
;    endif
;    ;+
;    ;   examples:
;    ;   filename='LAE1_ia445_v2_scaled'
;    ;   mask='maskiabw'
;    ;-
;    if  ~keyword_set(format) then format='fits'; format='fits.fz'
;    '../cats/'+output
