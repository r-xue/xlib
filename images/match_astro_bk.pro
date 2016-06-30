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
