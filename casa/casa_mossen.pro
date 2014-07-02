PRO CASA_MOSSEN,prefix,postfix,pattern=pattern,$
    pbstat=pbstat,pbkeep=pbkeep,$
    mask0=mask0,_EXTRA=extra

;+
; NAME:
;   CASA_MOSSEN
;
; PURPOSE:
; 
;   CASA naturally uses a channel/position-dependent psf when removing model components in major cycles 
;   because the process is done in the vis domain. The noise is usually flatten for each plane to make the model 
;   component searching easier in minor cycles. 
;   However, .flux image doesn't provide information on the channel-wise noise variation (it is normalized to 1 in each plane).
;    
;   This procedure could be helpful to create a theoretical noise pattern cube, taking account of
;   effects from: beam variation, primmary beam / mosaic pattern, partial spectral window coverage, etc.
;   
;   NOTE:   This procedure only works for CLEAN products from CASA 4.2, still experimental!
;
; INPUTS:
; 
;   filename    filename root for the CLEAN product file set
;               if you got AA.flux.fits, AA.psf.fits, etc., 
;               then filename=AA
;               
;
;   pbstat     the .flux level above which we use to evaluate the normalized noise 
;               (default: 0.5)
;   pbkeep     the .flux level above which we don't blank in the .err file 
;               (default: 1/3)
;   _extra      any keywords for err_cube.pro
; 
; KEYWORDS:
;   
;   mask0       mask pixels where some channels are blank.
;               this optional might be useful if for the primary beam masking from CASA slightly
;               varied across different channels and you don't like it... 
;   
; OUTPUTS:
;   
;   the output file name is AA.err.fits
;   
;   pattern     normalized noise pattern cube
;               
;               
;
; EXAMPLE:
;   casa_mossen,'n891co.line'
;   
; HISTORY:
;
;   20130702    RX  introduced
;   20130910    RX  merge st_mossen.pro into casa_mossen.pro
;
;-

filename=prefix+'.'+postfix

if not keyword_set(pbstat) then pbstat=0.5
if not keyword_set(pbkeep) then pbkeep=1./3.

flux=readfits(filename+'.flux.fits',fluxhd)
im=readfits(filename+'.image.fits',hd)
rd_hd,hd,s=s
sgrid=s.v
nchan=(size(im,/d))[2]
if  file_test(filename+'.cpsf.fits') then begin
    bpp=1
    psf=readfits(filename+'.cpsf.fits',psfhd) 
endif else begin
    bpp=0
    if  file_test(filename+'.psf.fits') then begin 
        psf=readfits(filename+'.psf.fits',psfhd)
    endif else begin
        filename2=repstr(filename,'line','coli')
        psf=readfits(filename2+'.psf.fits',psfhd)
    endelse    
endelse


; IMPLICT ESTIMATION

pattern=1.0/flux
cn=findgen(nchan)

ncol=0
if  file_test(prefix+'.src.ms.sumwt.log') then begin
    ncol=count_columns(prefix+'.src.ms.sumwt.log')
    if  ncol eq 1 then readcol,prefix+'.src.ms.sumwt.log',vs
    if  ncol eq 3 then readcol,prefix+'.src.ms.sumwt.log',ich,iv,vs
endif else begin
    vs=cn*0.0+1.0
endelse    
for i=0,nchan-1 do begin
    
    ipick=nchan-i-1
    if  ncol eq 3 then tmp=min(abs(sgrid[i]-iv),ipick)
    print,  'chan:',strtrim(i,2),$
            ' .f_peak:',string(max(flux[*,*,i],/nan,floc),format='(f0.2)'),$
            ' .p_peak:',string(max(psf[*,*,i],/nan,ploc),format='(f0.2)'),$
            ' .sumwt:',string(vs[ipick],format='(f0.2)'),$
            ' .ipick:',string(ipick)
    indflux=array_indices(flux[*,*,i],floc)
    indpsf=array_indices(flux[*,*,i],ploc)
    spsf=shift(psf[*,*,i],indflux[0]-indpsf[0],indflux[1]-indpsf[1])
    if  bpp eq 1 then begin
        ipsf=spsf*(pattern[*,*,i])^1.0
    endif
    if  bpp eq 0 then begin
        ipsf=spsf
    endif
    ipsf[where(flux[*,*,i] le pbstat,/null)]=!values.f_nan
    ipsf=ipsf/max(ipsf,/nan)
    cn[i]=sig2rms(psf=ipsf,/non)
    print,cn[i]
    if  file_test(prefix+'.src.ms.sumwt.log') then begin
        cn[i]=(1./vs[ipick])^0.5/cn[i]
    endif
    pattern[*,*,i]=cn[i]*pattern[*,*,i]
endfor
pattern=pattern/min(pattern,/nan)

mask=float(flux gt pbstat)
sen=ERR_CUBE(im/flux, hd, pattern=pattern,mask=mask,_extra=extra)

if  keyword_set(mask0) then begin
    fov=total(float(flux gt pbkeep),3)
    peak=max(fov,/nan)
    fov[where(fov lt peak,/null)]=!values.f_nan
    fov[where(fov eq peak,/null)]=0.0
    fov=cmreplicate(fov,nchan)
    sen=sen+fov
endif else begin
    sen[where(flux lt pbkeep,/null)]=!values.f_nan
endelse

sxaddpar, hd, 'DATAMAX', max(sen,/nan)
sxaddpar, hd, 'DATAMIN', min(sen,/nan)
writefits,filename+'.err.fits',sen,hd


; EXPLICT ESTIMATION + COMPARISON

rd_hd, hd, s=s
dn=findgen(nchan)
cn=findgen(nchan)
;nrms=robust_sigma(im/flux/pattern,/zero)
for i=0,nchan-1 do begin
    iim=im[*,*,i]
    iim=iim[where(flux[*,*,i] gt pbstat)]
    dn[i]=robust_sigma(iim,/zero)
    ;dn[i]=errfind(iim)
    ;dn[i]=STDDEV(iim)
    ;cn[i]=nrms*min(pattern[*,*,i],/nan)
    cn[i]=min(sen[*,*,i],/nan)
endfor

;
set_plot, 'ps'
device, filename=filename+'.err.eps', $
    bits_per_pixel=8,/encapsulated,$
    xsize=8,ysize=4,/inches,/col,xoffset=0,yoffset=0,/cmyk
!p.thick=2.0
!x.thick = 2.0
!y.thick = 2.0
!z.thick = 2.0
!p.charsize=1.0
!p.charthick=1.0
cgloadct,0

yrange=[-0.2,1.2]*max([cn,dn])
plot,s.v,cn,psym=10,xstyle=1,ystyle=1,yrange=yrange
oplot,s.v,dn,psym=10,linestyle=2,color=cgcolor('red')
oplot,s.v,cn,psym=cgsymcat(16),linestyle=2
oplot,s.v,dn,psym=cgsymcat(9),linestyle=2,color=cgcolor('red')
al_legend,filename,/bot

cgloadct,0
device, /close
set_plot,'X'


END



PRO ST_MOSSEN,version,files=files

; for STING
    ; version: mscr, mscn, mscr-nearest
    ; NOTES The noise in .flux<1/3 region of *.image.fits become weired and primary beam
    ; correction is not reliable anymore. Do not use them for .err calculations
    ; pb_stat: the pb response level above which we use to evaluate the normalized noise (default: 0.5)
    ; pb_keep: the pb response level above which we don't blank in the .err file (default: 1/3)
    ; files: n*.line.psf.fits'
    
    if keyword_set(files) then begin
        filelist=file_search(files)
    endif else begin
        filelist=file_search('/Volumes/Scratch/reduc/sting-co/'+version+'/n*/n*co.line.psf.fits')
    endelse
    print, filelist
    
    foreach file,filelist do begin
    
        casa_mossen,repstr(file,'.psf.fits',''),/mask0
        
    endforeach
    
END

PRO TEST_CASA_MOSSEN_INTER

a=readfits('/Volumes/Scratch/reduc/sting-co/mscr/n0772/n0772co.line.err.fits',ahd)
b=readfits('/Volumes/Scratch/reduc/sting-co/mscr-nearest/n0772/n0772co.line.err.fits',bhd)
rd_hd,ahd,s=sa
rd_hd,bhd,s=sb
window,0,xsize=750,ysize=750
plot,a*sa.jypb2k,b*sb.jypb2k,xrange=[0,1.0],yrange=[0,1.0]
oplot,[0,1],[0,1],color=cgcolor('red')

END




;psf=readfits(filename+'.cpsf.fits',psfhd)
;dm=readfits(filename+'_d.image.fits',dmhd)
;beampar=mrdfits(filename+'_d.image.fits',1,/use_colnum)
;pattern=1.0/flux
;cn=findgen(nchan)
;for i=0,nchan-1 do begin
;  ipsf=psf[*,*,i]/(flux[*,*,i])^2.0
;  cn[i]=sig2rms(psf=ipsf,/nonormalize)
;  pattern[*,*,i]=cn[i]*pattern[*,*,i]
;endfor
;cn=cn/max(cn,/nan)
;pattern=pattern/min(pattern,/nan)
;
;pattern=1.0/flux
;cn=findgen(nchan)
;rd_hd,hd,s=s,c=c,/full
;psize=abs(s.cdelt[0]*3600)
;for i=0,nchan-1 do begin
;  ;print,min(pattern[*,*,i],/nan),max(psf[*,*,i],/nan)
;  gkernel,s.bmaj,s.bmin,s.bpa,beampar[i].C1,beampar[i].C2,beampar[i].C3,bmaj,bmin,bpa,ifail,/quiet
;  print,s.bmaj,s.bmin,s.bpa,beampar[i].C1,beampar[i].C2,beampar[i].C3,bmaj,bmin,bpa,ifail
;
;  tmp=max(psf[*,*,i],pos)
;  pos=ARRAY_INDICES(psf[*,*,i],pos)
;  kpsf=psf_gaussian(npixel=(size(psf[*,*,i]))[1:2],fwhm=[bmin/psize,bmaj/psize],$
;                    CENTROID=pos,$
;                    /NORMALIZE,/DOUBLE)
;  kpsf=rot(kpsf,-bpa,1.0,pos[0],pos[1],/INTERP,missing=0.0)
;  kpsf=(kpsf>0d)
;  kpsf=kpsf/max(kpsf,/nan)
;
;  ipsf=psf[*,*,i]/(flux[*,*,i])^2.0
;  ipsf[where(ipsf ne ipsf,/null)]=0.0
;  kpsf[where(kpsf ne kpsf,/null)]=0.0
;
;  ;ipsf=convol_fft(ipsf,kpsf)
;  cn[i]=sig2rms(psf=ipsf,/nonormalize)
;  pattern[*,*,i]=cn[i]*pattern[*,*,i]
;  ;cn[i]=sig2rms(psf=kpsf)
;endfor
;cn=cn/max(cn,/nan)
;pattern=pattern/min(pattern,/nan)



;sxaddpar, hd, 'DATAMAX', max(pattern,/nan)
;sxaddpar, hd, 'DATAMIN', min(pattern,/nan)
;writefits,filename+'.nsen.fits',pattern,hd
