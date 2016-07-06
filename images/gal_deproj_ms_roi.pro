PRO GAL_DEPROJ_MS_ROI,ref,galno,roi=roi,comgrid=comgrid,select=select,out=out

;+
; NAME:
;   GAL_DEPROJ_MS_ROI
;
; PURPOSE:
;   make measurements from ROIs
;   
; INPUTS:
;   ref             data fileinfo tag
;   galno           galaxy name (e.g. 'LMC')
;   select          select bands
;   
; KEYWORDS:
;   comgrid:        if the multi-band images are on the same frame,
;                   COMGRID will force the script to use WHERE to find 
;                   out the pixels in each ROI. Otherwise, a polygon+inside/online approach
;                   will be used by default, which doesn't care if interested images are 
;                   on the same frame or not.
;                   For SAGE/IRAC images, regridding before measuring
;                   flux may be still better since the original image
;                   sizes are large. Also the polygon method may be less acurate in some 
;                   cases (e.g. much larger pixel size compared with that of the ROI image)
; 
; HISTORY:
;   20131007    RX  introduced
;   20131020    RX  images doesn't need to be on the same frame now.
;                   tag for each band will be added automatically
; 
; EXAMPLES:
;   gal_deproj_ms_roi,'MGP','LMC',roi='lmc_v9.co.vbin.sgm.roi.fits',select=[31,32,29,30,33,2,5],$
;       out='magma_roi_ms'
;   
;-

gal_struct_build,ref,s,h,/silent
types=gal_deproj_fileinfo(ref)

if n_elements(select) eq 0 then typetag=indgen(n_elements(types))
typetag=select
ind=where(s.(where(h eq 'Galaxy')) eq galno)
dist=s.(where(h eq 'Distance (Mpc)'))[ind]*10.^6
as2pc=dist/206264.806

imroi=readfits(roi,hdroi,/silent)
nxy=size(imroi,/d)

ms = { $
    galno:galno, $
    roi:!values.d_nan,$
    area:!values.f_nan,$
    ra:replicate(!values.f_nan,2*(nxy[0]+nxy[1])),$         ; boundary pixel R.A.
    dec:replicate(!values.f_nan,2*(nxy[0]+nxy[1])) }        ; boundary pixel Dec.
for i=0,n_elements(typetag)-1 do begin
    ms=create_struct(ms,types[typetag[i]].tag,!values.d_nan)
endfor
gal_ms=replicate(ms,max(imroi,/nan))


for ind=1,max(imroi,/nan) do begin
    roitag=where(imroi eq ind)
    bp=find_boundary(roitag,xsize=nxy[0],ysize=nxy[1])
    xyad,hdroi,bp[0,*],bp[1,*],bra,bdec
    bn=n_elements(bra)
    gal_ms[ind-1].ra[0:bn-1]=bra
    gal_ms[ind-1].dec[0:bn-1]=bdec
    gal_ms[ind-1].area=n_elements(roitag)                  ; in units of pixel (defined in the ROI label image)
    gal_ms[ind-1].roi=ind
endfor

foreach type,types[typetag] do begin
  
  print,''
  print, 'working on -->',type.tag
  print,''
  
  im=type.path+galno+type.posfix+'.fits'
  im=readfits(im,hd)
  nxy=size(im,/d)
  getrot,hd,angle,cdelt
  psize=abs(cdelt[0])*3600.0
  
  conf=1.0
  ; CO/HI -> Msun
  if STRPOS(strupcase(type.tag), 'MAGMA') ne -1 then begin
      conf=calc_cn(1.0,'co1-0',hd=hd,/MSPPC2,/HELIUM)*(psize*as2pc)^2.0
  endif
  if STRPOS(strupcase(type.tag), 'HI') ne -1 then begin
      conf=calc_cn(1.0,'hi',hd=hd,/MSPPC2,/HELIUM)*(psize*as2pc)^2.0
  endif
  ; MJy/sr -> Jy
  if STRPOS(strupcase(type.tag), 'MIPS24') ne -1 then begin
      conf=3.05d-4*1e6*(psize/3600)^2.0
  endif
  if STRPOS(strupcase(type.tag), 'IRAC8') ne -1 then begin
      conf=3.05d-4*1e6*(psize/3600)^2.0
  endif
  
  for ind=1,max(imroi,/nan) do begin
      
      ra=gal_ms[ind-1].ra
      dec=gal_ms[ind-1].dec
      ra=ra[where(ra eq ra, /null)]
      dec=dec[where(dec eq dec, /null)]
      adxy,hd,ra,dec,bx,by
      
      if not keyword_set(comgrid) then begin
        nxy=size(im,/d)
        xmin=floor(min(bx))
        xmax=ceil(max(bx))
        ymin=floor(min(by))
        ymax=ceil(max(by))
        make_2d,findgen(xmax-xmin+1)+xmin,findgen(ymax-ymin+1)+ymin,xx,yy
        obj_roi=obj_new('IDLanROI',round(bx),round(by))
        tag_roi=obj_roi->containspoints(xx[*],yy[*])
        obj_destroy,obj_roi
        tag_roi=where(tag_roi ne 0)
        roitag=round(xx[tag_roi]+yy[tag_roi]*nxy[0])
      endif else begin
        roitag=where(imroi eq ind)
      endelse
        
      tagindex=where(TAG_NAMES(ms) eq strupcase(type.tag))
      gal_ms[ind-1].(tagindex)=total(im[roitag],/nan)
      
      if  strupcase(type.tag) eq 'COE_MAGMA_SGM' then begin
          gal_ms[ind-1].(tagindex)=sqrt(total(im[roitag]^2.0,/nan))
      endif
      if  strupcase(type.tag) eq 'HIE' then begin
          gal_ms[ind-1].(tagindex)=sqrt(total(im[roitag]^2.0,/nan))
      endif
      gal_ms[ind-1].(tagindex)=gal_ms[ind-1].(tagindex)*conf
  endfor
  
endforeach
save,filename=out+'.dat',gal_ms

END



