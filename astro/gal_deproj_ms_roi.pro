PRO GAL_DEPROJ_MS_ROI,ref,roi=roi

;+
; NAME:
;   GAL_DEPROJ_MS_ROI
;
; PURPOSE:
;   make measurement from ROIs
;-


; LOOP THROUGH ALL GALAXIE

ref='MGP'
all_ms=[]


gal_struct_build,ref,s,h,/silent

ind=where(s.(where(h eq 'Galaxy')) eq 'LMC')
dist=s.(where(h eq 'Distance (Mpc)'))[ind]*10.^6
as2pc=dist/206264.806



ms = { $
  galno:"", $
  roi:!values.d_nan,$
  co_magma_sgm:!values.d_nan,$
  coe_magma_sgm:!values.d_nan,$
  mips24_org:!values.f_nan}

  types=gal_deproj_fileinfo(ref)

  typetag=[31,32,29]

  imroi=readfits(roi,hdroi,/silent)
  gal_ms=replicate(ms,max(imroi))

  foreach type,types[typetag] do begin
      im='LMC'+type.posfix+'.fits'
      im=readfits(im,hd)
      getrot,hd,angle,cdelt
      psize=abs(cdelt[0])*3600.0
      
      conf=1.0
      if STRPOS(strupcase(type.tag), 'MAGMA') ne -1 then begin

          conf=calc_cn(1.0,'co1-0',hd=hd,/MSPPC2,/HELIUM)*(psize*as2pc)^2.0
      endif
      
      if STRPOS(strupcase(type.tag), 'MIPS24') ne -1 then begin
          conf=3.05d-4*1e6*(psize/3600)^2.0
      endif
      for ind=1,max(imroi) do begin
          roitag=where(imroi eq ind)

          tagindex=where(TAG_NAMES(ms) eq strupcase(type.tag))
          gal_ms[ind-1].(tagindex)=total(im[roitag],/nan)
          
          if strupcase(type.tag) eq 'COE_MAGMA_SGM' then begin
            gal_ms[ind-1].(tagindex)=sqrt(total(im[roitag]^2.0,/nan))
            ;gal_ms[ind-1].(tagindex)=(total(im[roitag],/nan))
          endif
          gal_ms[ind-1].roi=ind
          gal_ms[ind-1].(tagindex)=gal_ms[ind-1].(tagindex)*conf

      endfor
  endforeach
  
  save,filename='magma_roi.dat',gal_ms
  
END

PRO TEST_GAL_DEPROJ_MS_POI


GAL_DEPROJ_MS_ROI,roi='lmc_v9.co.vbin.sgm.roi.fits'

restore,'magma_roi.dat'

set_plot, 'ps'
device, filename='roi_corr.eps', $
    bits_per_pixel=8,/encapsulated,$
    xsize=10,ysize=10,/inches,/col,xoffset=0,yoffset=0,/cmyk
    !p.thick=2.0
    !x.thick = 2.0
    !y.thick = 2.0
    !z.thick = 2.0
    !p.charsize=1.0
    !p.charthick=2.0
plot,gal_ms.co_magma_sgm,gal_ms.mips24_org,psym=symcat(16),/xlog,/ylog,xrange=[1e1,1e7],yrange=[0.01,1e4],$
    xtitle='Cloud Mass (Msun,xco=2e20,+helium)',ytitle='MIPS24 (Jy)',xstyle=1,ystyle=1,pos=[0.1,0.1,0.9,0.9]
oploterror,gal_ms.co_magma_sgm,gal_ms.mips24_org,gal_ms.coe_magma_sgm,replicate(0,n_elements(gal_ms)),psym=3,$
    /nohat
xyouts,gal_ms.co_magma_sgm,gal_ms.mips24_org,strtrim(fix(gal_ms.roi),2),/data
for i=0,n_elements(gal_ms)-1 do begin
    print,fix(gal_ms[i].roi),gal_ms[i].co_magma_sgm,gal_ms[i].coe_magma_sgm,gal_ms[i].mips24_org
endfor

device, /close
set_plot,'X'

END


PRO TEST_MASKEXPAND


    im=readfits('lmc_v9.co.vbin.sgm.mask.fits',hd)
    ;step=2
    ;
    ;;newim=padding(float(im),step)
    ;newim=im
    ;base=newim*0.0
    ;print,'padding'
    ;; z
    ;for i=1,step-1 do begin
    ;    base=shift(newim,0,0,i)+base
    ;    base=shift(newim,0,0,-i)+base
    ;endfor
    ;
    ;; x
    ;for i=1,step-1 do begin
    ;    base=shift(newim,i,0,0)+base
    ;    base=shift(newim,i,0,0)+base
    ;endfor
    ;
    ;; y
    ;for i=1,step-1 do begin
    ;    base=shift(newim,0,i,0)+base
    ;    base=shift(newim,0,-i,0)+base
    ;endfor
    
    base=total(im,3)
    ;newim=padding(base,-step)
    
    label=label_region(base gt 0, all_neighbors = all_neighbors, /ulong)
    
    writefits,'lmc_v9.co.vbin.sgm.roi.fits',float(label),hd
    writefits,'lmc_v9.co.vbin.sgm.mask0.fits',float(base),hd
    
END




