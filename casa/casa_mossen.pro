PRO CASA_MOSSEN,filename,pattern=pattern

;+
; NAME:
;   CASA_MOSSEN
;
; PURPOSE:
;   CASA takes the dirty beam variation across channel into account when
;   removing model components in the major cycle. In addition, the noise 
;   is flatten in each dirty map to make the model component search easier
;   in the minor cycle. However, ".flux" image doesn't provide any theoretical
;   estimation of channel-wise noise variations (.flux is normalized to 1 in 
;   each plane). This procedure could be used to create such theoretical 
;   noise pattern cube, just like MIRAID/MOSSEN.
;   
;   NOTE: This procedure only works for CLEAN products from CASA 4.x
;
; INPUTS:
;   filename  filename for the CASA clean product file set
;             if you got AA.flux.fits AA.psf.fits AA.image.fits AA.sen.fits, 
;             then filename=AA
;             The output file name is AA.err.fits AA.nsen.fits
;
; OUTPUTS:
;   pattern   noise pattern cube
;             (strictly speaking, the below approach only mathematically correct
;               
;
; HISTORY:
;
;   20130702  RX  introduced
;
;-



flux=readfits(filename+'.flux.fits',fluxhd)
psf=readfits(filename+'.psf.fits',psfhd)
im=readfits(filename+'.image.fits',hd)

nchan=(size(psf,/d))[2]

pattern=1.0/flux
cn=findgen(nchan)
for i=0,nchan-1 do begin
  ipsf=psf[*,*,i]/(flux[*,*,i])^2.0  
  cn[i]=sig2rms(psf=ipsf,/nonormalize)
  pattern[*,*,i]=cn[i]*pattern[*,*,i]
endfor

cn=cn/max(cn,/nan)
pattern=pattern/min(pattern,/nan)
sxaddpar, hd, 'DATAMAX', max(pattern,/nan)
sxaddpar, hd, 'DATAMIN', min(pattern,/nan)
writefits,filename+'.nsen.fits',pattern,hd


; direct estimatons

rd_hd, hd, s=s
dn=findgen(nchan)
for i=0,nchan-1 do begin
  iim=im[*,*,i]
  iim=iim[where(flux[*,*,i] le 3.0)]
  dn[i]=robust_sigma(iim)
endfor
dn=dn/max(dn)
;
set_plot, 'ps'
device, filename=filename+'.nsen.eps', $
bits_per_pixel=8,/encapsulated,$
xsize=8,ysize=4,/inches,/col,xoffset=0,yoffset=0,/cmyk
!p.thick=2.0
!x.thick = 2.0
!y.thick = 2.0
!z.thick = 2.0
!p.charsize=1.0
!p.charthick=1.0

plot,s.v,cn,psym=10,xstyle=1,yrange=[-0.1,1.1],ystyle=1
oplot,s.v,dn,psym=10,linestyle=2,color=cgcolor('red')
al_legend,filename,/bot
device, /close
set_plot,'X'



END

PRO TEST_CASA_MOSSEN

filelist=file_search('/Volumes/Scratch/reduc/sting-co/msc/*/n*co.line.psf.fits')
foreach file,filelist do begin
  casa_mossen,str_replace(file,'.psf.fits',''),pattern=pattern
endforeach



END
