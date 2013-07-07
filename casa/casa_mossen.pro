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
;             if you got AA.flux.fits AA.psf.fits AA.image.fits AA.sen,fits, 
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

PRO STING_CASA_MOSSEN

; NOTES The noise in .flux<1/3 region of *.image.fits become weired and primary beam
; correction is not reliable anymore. Do not use them for .err calculations  

filelist=file_search('/Volumes/Scratch/reduc/sting-co/msc/n*/n*co.line.psf.fits')
foreach file,filelist do begin
  casa_mossen,repstr(file,'.psf.fits',''),pattern=pattern
  sfits=repstr(file,'psf','cm')
  efits=repstr(file,'psf','err')
  pfits=repstr(file,'psf','flux')
  im=readfits(sfits,hd)
  flux=readfits(pfits,maskhd)
  mask=float(flux gt 0.5) 
  sen=ERR_CUBE(im, hd, pattern=pattern,mask=mask)

  
  fov=float(flux gt 0.5)
  fov=total(fov,3)

  peak=max(fov,/nan)
  fov[where(fov lt peak,/null)]=!values.f_nan
  fov[where(fov eq peak,/null)]=0.0
  fov=cmreplicate(fov,(size(flux,/d))[2])
    writefits,'test.fits',fov
  sen=sen+fov
  sxaddpar, hd, 'DATAMAX', max(sen,/nan)
  sxaddpar, hd, 'DATAMIN', min(sen,/nan)
  writefits,efits,sen,hd
endforeach

;  tf=[]
;  ntf=[]
;  for i=0,n_elements(fitslist)-1 do begin
;    sfits=fitslist[i]
;    efits=repstr(sfits,'psf',''
;    cfits=repstr(sfits,'sen','cm')
;    nsfits=repstr(sfits,'sen','err')
;    nsfits=repstr(nsfits,'cube','err')
;    sim=readfits(sfits,shd)
;    cim=readfits(cfits,chd)
;    nsim=ERR_CUBE(cim, chd, pattern=sim)
;    writefits,nsfits,nsim,shd
;    tf=[tf,mean(sim,/nan)]
;    ntf=[ntf,mean(nsim,/nan)]
;  endfor
;  
;  plot,tf,ntf,psym=2,xtitle='RMS (old) [Jy/beam]',ytitle='RMS (new) [Jy/beam]',charsize=2.0
;  oplot,[0,1.0e6],[0,1.0e6]
  
END