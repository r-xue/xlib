PRO GAL_DEPROJ_MS_ROI,ref,roi=roi

;+
; NAME:
;   GAL_DEPROJ_MS_ROI
;
; PURPOSE:
;   make measurement from ROIs
;-

ref='MGP'
roi='LMC.co_magma.cm.sm.label_smo60.fits'
gal_struct_build,ref,s,h,/silent

; LOOP THROUGH ALL GALAXIE



all_ms=[]

ms = { $
  galno:"", $
  roi:!values.d_nan,$
  co_magma:!values.d_nan,$
  coe_magma:!values.d_nan,$
  mips24:!values.f_nan}

  types=gal_deproj_fileinfo(ref)

  typetag=[1,4,22]
  imroi=readfits(roi,hdroi,/silent)
  
  gal_ms=replicate(ms,max(imroi))
  
  foreach type,types[typetag] do begin
      im='LMC'+type.posfix+'_smo60.fits'
      im=readfits(im,hd)
      for ind=1,max(imroi)-1 do begin
          roitag=where(imroi eq ind)
          tagindex=where(TAG_NAMES(ms) eq strupcase(type.tag))
          gal_ms[ind-1].(tagindex)=total(im[roitag],/nan)
          print,total(im[roitag])
      endfor
  endforeach
  
  save,filename='roi.dat',gal_ms
  
END

PRO TEST_GAL_DEPROJ_MS_POI


GAL_DEPROJ_MS_ROI

restore,'roi.dat'
plot,gal_ms.co_magma,gal_ms.mips24,psym=3,/xlog,/ylog,xrange=[0.1,1e6],yrange=[0.1,1e8],$
    xtitle='CO',ytitle='MIPS24'

END


