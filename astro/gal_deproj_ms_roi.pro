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
  mips24_org:!values.f_nan,$
  irac8_org:!values.f_nan,$
  irac8resid_org:!values.f_nan,$
  hi:!values.f_nan,$
  hie:!values.f_nan,$
  area:!values.f_nan}

  types=gal_deproj_fileinfo(ref)

  typetag=[31,32,29,30,33,2,5]

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
      if STRPOS(strupcase(type.tag), 'HI') ne -1 then begin
          conf=calc_cn(1.0,'hi',hd=hd,/MSPPC2,/HELIUM)*(psize*as2pc)^2.0
      endif
      if STRPOS(strupcase(type.tag), 'MIPS24') ne -1 then begin
          conf=3.05d-4*1e6*(psize/3600)^2.0
      endif
      if STRPOS(strupcase(type.tag), 'IRAC8') ne -1 then begin
          conf=3.05d-4*1e6*(psize/3600)^2.0
      endif
      
      for ind=1,max(imroi) do begin
          roitag=where(imroi eq ind)

          tagindex=where(TAG_NAMES(ms) eq strupcase(type.tag))
          gal_ms[ind-1].(tagindex)=total(im[roitag],/nan)
          
          if strupcase(type.tag) eq 'COE_MAGMA_SGM' then begin
            gal_ms[ind-1].(tagindex)=sqrt(total(im[roitag]^2.0,/nan))
          endif
          if strupcase(type.tag) eq 'HIE' then begin
              gal_ms[ind-1].(tagindex)=sqrt(total(im[roitag]^2.0,/nan))
          endif
          gal_ms[ind-1].roi=ind
          gal_ms[ind-1].area=n_elements(roitag) ; in units of pixel
          gal_ms[ind-1].(tagindex)=gal_ms[ind-1].(tagindex)*conf

      endfor
  endforeach
  
  save,filename='magma_roi_ms.dat',gal_ms
  
END

PRO TEST_GAL_DEPROJ_MS_POI_PLOT


;GAL_DEPROJ_MS_ROI,roi='lmc_v9.co.vbin.sgm.roi.fits'

restore,'magma_roi_ms.dat'

set_plot, 'ps'
device, filename='roi_corr_co_mips24.eps', $
    bits_per_pixel=8,/encapsulated,$
    xsize=10,ysize=10,/inches,/col,xoffset=0,yoffset=0,/cmyk
    !p.thick=2.0
    !x.thick = 2.0
    !y.thick = 2.0
    !z.thick = 2.0
    !p.charsize=1.0
    !p.charthick=2.0
plot,gal_ms.co_magma_sgm,gal_ms.mips24_org,psym=symcat(16),/xlog,/ylog,xrange=[1e1,1e7],yrange=[0.01,1e4],$
    xtitle='Cloud Mass (Msun,xco=2e20,+helium)',ytitle='MIPS24 (Jy)',xstyle=1,ystyle=1,pos=[0.1,0.1,0.9,0.9],/nodata

oploterror,gal_ms.co_magma_sgm,gal_ms.mips24_org,gal_ms.coe_magma_sgm,replicate(0,n_elements(gal_ms)),psym=symcat(9),$
    /nohat,color=cgcolor('red')
x=alog10(gal_ms.co_magma_sgm)
y=alog10(gal_ms.mips24_org)
coe=linfit(x,y)
oplot,10.^(findgen(100)*0.1),10.^(findgen(100)*0.1*coe[1]+coe[0]),color=cgcolor('red')
coe1=coe

oploterror,gal_ms.hi,gal_ms.mips24_org,gal_ms.hie,replicate(0,n_elements(gal_ms)),psym=symcat(6),$
        /nohat,color=cgcolor('blue')
x=alog10(gal_ms.hi)
y=alog10(gal_ms.mips24_org)
coe=linfit(x,y)
oplot,10.^(findgen(100)*0.1),10.^(findgen(100)*0.1*coe[1]+coe[0]),color=cgcolor('blue')
coe2=coe

;xyouts,gal_ms.co_magma_sgm,gal_ms.mips24_org,strtrim(fix(gal_ms.roi),2),/data
al_legend,['MIPS24 vs. MolecularISM Mass','MIPS24 vs. AtomicISM Mass'],psym=[9,6],color=['red','blue']
al_legend,['log(mips24)=a+log(MOL_mass)*b:'+strjoin(string(coe1,format='(f0.3)'),','),$
            'log(mips24)=a+log(ATO_mass)*b:'+strjoin(string(coe2,format='(f0.3)'),',')],/right,/bottom

device, /close
set_plot,'X'

for i=0,n_elements(gal_ms)-1 do begin
    print,  fix(gal_ms[i].roi),$
        gal_ms[i].co_magma_sgm,gal_ms[i].coe_magma_sgm,$
        gal_ms[i].hi,gal_ms[i].hie,$
        gal_ms[i].mips24_org,$
        gal_ms[i].irac8_org,gal_ms[i].irac8resid_org,$
        gal_ms[i].area
endfor

set_plot, 'ps'
device, filename='roi_corr_co_i8.eps', $
    bits_per_pixel=8,/encapsulated,$
    xsize=10,ysize=10,/inches,/col,xoffset=0,yoffset=0,/cmyk
!p.thick=2.0
!x.thick = 2.0
!y.thick = 2.0
!z.thick = 2.0
!p.charsize=1.0
!p.charthick=2.0
plot,gal_ms.co_magma_sgm,gal_ms.irac8_org,psym=symcat(16),/xlog,/ylog,xrange=[1e1,1e7],yrange=[0.01,1e4],$
    xtitle='Cloud Mass (Msun,xco=2e20,+helium)',ytitle='I8 (Jy)',xstyle=1,ystyle=1,pos=[0.1,0.1,0.9,0.9],/nodata
oploterror,gal_ms.co_magma_sgm,gal_ms.irac8_org,gal_ms.coe_magma_sgm,replicate(0,n_elements(gal_ms)),psym=symcat(9),$
    /nohat,color=cgcolor('red')
    x=alog10(gal_ms.co_magma_sgm)
    y=alog10(gal_ms.irac8_org)
    coe=linfit(x,y)
    oplot,10.^(findgen(100)*0.1),10.^(findgen(100)*0.1*coe[1]+coe[0]),color=cgcolor('red')
coe1=coe    
oploterror,gal_ms.hi,gal_ms.irac8_org,gal_ms.hie,replicate(0,n_elements(gal_ms)),psym=symcat(6),$
        /nohat,color=cgcolor('blue')
        
    x=alog10(gal_ms.hi)
    y=alog10(gal_ms.irac8_org)
    coe=linfit(x,y)
    oplot,10.^(findgen(100)*0.1),10.^(findgen(100)*0.1*coe[1]+coe[0]),color=cgcolor('blue')
    coe2=coe
    
;xyouts,gal_ms.co_magma_sgm,gal_ms.irac8_org,strtrim(fix(gal_ms.roi),2),/data
al_legend,['I8 vs. MolecularISM Mass','I8 vs. AtomicISM Mass'],psym=[9,6],color=['red','blue']
al_legend,['log(I8)=a+log(MOL_mass)*b:'+strjoin(string(coe1,format='(f0.3)'),','),$
    'log(I8)=a+log(ATO_mass)*b:'+strjoin(string(coe2,format='(f0.3)'),',')],/right,/bottom
device, /close
set_plot,'X'


END


PRO test_gal_deproj_ms_roi_relabel


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




