PRO CASA_MOSSEN,prefix,$
    pattern=pattern,$
    sumwtlog=sumwtlog,$
    senslog=senslog,$
    pbstat=pbstat,pbkeep=pbkeep,$
    mask0=mask0,_EXTRA=extra

;+
; NAME:
;   CASA_MOSSEN
;
; PURPOSE:
; 
;   CASA naturally uses a channel/position-dependent psf when removing model components in major cycles 
;   because the process is done in the visibility domain. The noise is usually flatten for each plane to make the model 
;   component searching easier in minor cycles. 
;   However, .flux image doesn't provide information on the channel-wise noise variation (it is normalized to 1 in each plane).
;    
;   This procedure could be helpful to create a theoretical noise pattern cube, taking account of
;   effects from: beam variation, primmary beam / mosaic pattern, partial spectral window coverage, etc.
;   
;   NOTE:   This procedure works for CLEAN products from CASA>=4.2.2
;
; INPUTS:
; 
;   prefix     prefix for the imaging name (e.g. ngc4254co)
;   posfix     postfix for the imaging name (e.g. line or coli)
;              the imaging products name will be prefix.posfix following the convention in the pipeline
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
;   casa_mossen,'n891co','line'
;   casa_mossen,'n0772co_ro.line',pbkeep=1./3.,/mask0,pbstat=0.5,senslog='n0772co_ro.line.sens.log'
;   casa_mossen,'n0772co13_na.line',pbkeep=1./3.,/mask0,pbstat=0.5,senslog='n0772co13_na.line.sens.log'
;   casa_mossen,'n3147co_na.line',pbkeep=1./3.,/mask0,pbstat=0.5,sumwtlog='n3147co.src.ms.sumwt.log'
;   casa_mossen,'n3147co_na.line',pbkeep=1./3.,/mask0,pbstat=0.5,senslog='n3147co_na.line.sens.log'
;   casa_mossen,'n3147co_ro.line',pbkeep=1./3.,/mask0,pbstat=0.5,sumwtlog='n3147co.src.ms.sumwt.log'
;   casa_mossen,'n3147co_ro.line',pbkeep=1./3.,/mask0,pbstat=0.5,senslog='n3147co_ro.line.sens.log'
;   casa_mossen,'n3147co_na.line',pbkeep=1./3.,/mask0,pbstat=0.5,senslog='n3147co_na.line.sens.log'
;   casa_mossen,'n3147co13_na.line',pbkeep=1./3.,/mask0,pbstat=0.5,senslog='n3147co13_na.line.sens.log'
;   casa_mossen,'n3147co13_ro.line',pbkeep=1./3.,/mask0,pbstat=0.5,senslog='n3147co13_ro.line.sens.log'
;   casa_mossen,'n3147co13_na.line',pbkeep=1./3.,/mask0,pbstat=0.5,sumwtlog='n3147co13.src.ms.sumwt.log'
;   
; HISTORY:
;
;   20130702    RX  introduced
;   20130910    RX  merge st_mossen.pro into casa_mossen.pro
;   20150127    RX  remove the cpsf method for the products with resmooth=True
;                   The weight table (prefix+'.src.ms.sumwt.log', generated using xu.sumwt() in casapy) 
;                   is required if tracking channel-wise noise variation is desired.
;-

filename=prefix

if not keyword_set(pbstat) then pbstat=0.5
if not keyword_set(pbkeep) then pbkeep=1./3.

flux=readfits(filename+'.flux.fits',fluxhd)
im=readfits(filename+'.image.fits',hd)
rd_hd,hd,s=s
sgrid=s.v
nchan=(size(im,/d))[2]

if  file_test(filename+'.psf.fits') then begin 
    psf=readfits(filename+'.psf.fits',psfhd)
    if  file_test(filename+'.cpsf.fits') then begin
        cpsf=readfits(filename+'.cpsf.fits',cpsfhd)
    endif
endif else begin
    filename2=repstr(filename,'line','coli')
    psf=readfits(filename2+'.psf.fits',psfhd)
    if  file_test(filename2+'.cpsf.fits') then begin
        cpsf=readfits(filename2+'.cpsf.fits',cpsfhd)
    endif
endelse


; IMPLICT ESTIMATION

pattern=1.0/flux
cn=findgen(nchan)

ncol=0


sens=cn*0.0+10.0 ; presudo values (mJy)
if  keyword_set(sumwtlog)  then begin
    if  file_test(sumwtlog) then begin
        ncol=count_columns(sumwtlog)
        if  ncol eq 1 then begin
            print,'oldstyle sumwt log:'
            print,sumwtlog
            readcol,sumwtlog,vs,format='(f)'
        endif
        if  ncol eq 3 then begin
            print,'newstyle sumwt log:'
            print,sumwtlog
            readcol,sumwtlog,ich,iv,vs,format='(f,f,f)'
        endif
        sens=(1./vs)^0.5/1.414*1000.0
    endif
endif
if  keyword_set(senslog)  then begin
    if  file_test(senslog) then begin
        print,'sens log:'
        print,senslog
        readcol,senslog,sens,senscale
        sens=sens*1000.0
    endif
endif

for i=0,nchan-1 do begin
    ipick=nchan-i-1
    if  ncol eq 3 then tmp=min(abs(sgrid[i]-iv),ipick)
    tmp1=max(flux[*,*,i],/nan,floc)
    tmp2=max(psf[*,*,i],/nan,ploc)
    indflux=array_indices(flux[*,*,i],floc)
    indpsf=array_indices(flux[*,*,i],ploc)
    ;print,'flux peak:',indflux,'psf peak:',indpsf
    ;spsf=shift(psf[*,*,i],indflux[0]-indpsf[0],indflux[1]-indpsf[1])
    spsf=psf[*,*,i]
    ipsf=spsf+(flux[*,*,i])-(flux[*,*,i])
    ipsf=ipsf/max(ipsf,/nan)
    ;ipsf=ipsf>0.0
    ipsf=ipsf<0.0
    srms=sig2rms(psf=ipsf,/non)
    if  n_elements(cpsf) ne 0 then begin
        crms=sig2rms(psf=cpsf[*,*,i]/max(cpsf[*,*,i]),/non)
        ;crms=sig2rms(psf=cpsf[*,*,i],/non)
        print,  'im-chan:',string(i,format='(i3)'),$
            ' .f-peak:',string(max(flux[*,*,i],/nan,floc),format='(f5.2)'),$
            ' .p-peak:',string(max(psf[*,*,i],/nan,ploc),format='(f5.2)'),$
            ' .sens:',string(sens[ipick],format='(f8.2)')+'mJy',$
            ' .ipick:',string(ipick,format='(i3)'),$
            '  sig2rms (1jy->1jy/dirtybeam),',string(srms,format='(f0.2)'),$
            '  sig2rms (1jy->1jy/cleanbeam),',string(crms,format='(f0.2)')
        cn[i]=sens[ipick]/srms;*crms
    endif else begin
        print,  'im-chan:',string(i,format='(i3)'),$
            ' .f-peak:',string(max(flux[*,*,i],/nan,floc),format='(f5.2)'),$
            ' .p-peak:',string(max(psf[*,*,i],/nan,ploc),format='(f5.2)'),$
            ' .sens:',string(sens[ipick],format='(f8.2)')+'mJy',$
            ' .ipick:',string(ipick,format='(i3)'),$
            '  sig2rms (1jy->1jy/dirtybeam),',string(srms,format='(f0.2)')
        cn[i]=sens[ipick]/srms
    endelse
    pattern[*,*,i]=cn[i]*pattern[*,*,i]
endfor
pattern=pattern/min(pattern,/nan)

mask=float(flux gt pbstat)
sen=ERR_CUBE(im/flux, pattern=pattern,mask=mask,_extra=extra)

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
    ;print,median(iim),dn[i]
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

yrange=[-0.2,1.2]*max([cn,dn])
plot,s.v,cn,psym=10,xstyle=1,ystyle=1,yrange=yrange
oplot,s.v,dn,psym=10,linestyle=2,color=cgcolor('red')
oplot,s.v,cn,psym=cgsymcat(16),linestyle=2
oplot,s.v,dn,psym=cgsymcat(9),linestyle=2,color=cgcolor('red')
al_legend,filename,/bot

device, /close
set_plot,'X'


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

PRO TEST_CASA_MOSSEN_COMP,prefix




!P.Multi = [0, 2, 1]


readcol,prefix+'.src.ms.sumwt.log',wt
readcol,prefix+'_ro.line.sens.log',sen1,senscale
plot,findgen(n_elements(wt)),sqrt(1/wt)/sqrt(2.)
oplot,findgen(n_elements(wt)),sen1,color=cgcolor('red')
oplot,findgen(n_elements(wt)),sqrt(1/wt)/sqrt(2.)/sen1*0.005
print,mean(sqrt(1/wt)/sen1/sqrt(2.))

readcol,prefix+'.src.ms.sumwt.log',wt
readcol,prefix+'_na.line.sens.log',sen1,senscale
plot,findgen(n_elements(wt)),sqrt(1/wt)/sqrt(2.)
oplot,findgen(n_elements(wt)),sen1,color=cgcolor('red')
oplot,findgen(n_elements(wt)),sqrt(1/wt)/sqrt(2.)/sen1*0.002
print,mean(sqrt(1/wt)/sen1/sqrt(2.))

END

PRO TEST_CASA_MOSSEN_NEGTEST

psf=readfits('n0772co13_st.line.psf.fits')
psf=psf[*,*,0]
psf=psf/max(psf)

flux=readfits('n0772co13_st.line.flux.fits')
tag=where(flux ne flux or flux le 0.2)
psf[tag]=0.0

im=fltarr(1000,1000)
im=im+randomn(seed,1000,1000)
im=im>0.0
print,size(nim)
cim=convol_fft(im,psf)

writefits,'test_cim.fits',cim
writefits,'test_psf.fits',psf
writefits,'test_im.fits',im

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
