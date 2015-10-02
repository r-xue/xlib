FUNCTION smodel,p,x=x,y=y,err=err

ym=p[0]*exp(-x/p[1])
return,(y-ym)/err

END

PRO RADPROFILE_PLOT,rp,name,extrafun=extrafun

set_plot,'ps'
device,filename=name+'_radprofile.eps',bits=8,$
    xsize=5.0,ysize=5.0,$
    /inches,/encapsulated,/color
!p.thick=2.0
!x.thick = 2.0
!y.thick = 2.0
!z.thick = 2.0
!p.charsize=0.8
!p.charthick=2.0
!x.gridstyle = 0
!y.gridstyle = 0
xyouts,'!6'
;tmp=cgRootName(Directory=current)

xrange=[0.,8.]
yrange=[2e-5,2]

plot,[1],[1],psym=cgsymcat(1),$
    xrange=xrange,xstyle=1,$
    ytickformat='logticks_exp',$
    yrange=yrange,ystyle=8,/ylog,$
    xtitle='Radius ["]',$
    ytitle='Normalized Radial Profile',$
    ;title=csv+'_'+band+'_'+gtag+'_'+stag+'.dat'$
    /nodata,pos=[0.1,0.55,0.9,0.95]

ns=max(rp.median,/nan)
ns1=max(rp.mean,/nan)

c2f=1.0

axis,YAxis=1, YLog=1, YRange=yrange*ns*c2f,$
    ytitle='image units',$
    ytickformat='logticks_exp'
for i=0,n_elements(rp.center)-1 do begin    
    cgplots,[rp.center[i],rp.center[i]],([rp.quarlow[i],rp.quarup[i]]/ns)>(min(yrange)*0.1),thick=5,color=cgcolor('red'),noclip=0
    ;print,rp.center[i],rp.quarlow[i],rp.quarup[i],rp.mean[i]
    cgplots,rp.center[i],rp.median[i]/ns,psym=symcat(16),noclip=0,color=cgcolor('red')
    ;cgplots,rp.center[i],rp.mean[i]/ns1,psym=symcat(6),noclip=0,color=cgcolor('black')
endfor
tag=where(rp.center gt 1.75 and rp.center le 4.0)
start_params=[2.0,3.0]
xx=rp.center[tag]
yy=rp.median[tag]/ns
ee=(abs(rp.quarlow/ns-yy)*abs(rp.quarup/ns-yy))^0.5
functargs = {x:xx, y:yy, err:ee}
params=mpfit('smodel',start_params,functargs=functargs,perr=perr,BESTNORM=bestn,dof=dof)
;oplot,xx,params[0]*exp(-xx/params[1])
forward_function DCOMOVINGTRANSVERSE
red,omega0=0.27,omegalambda=0.73,h100=0.7
dps=DCOMOVINGTRANSVERSE(3.78)*!dpi/(180.*60*60)
print,'-----',params
print,'-----',params[1]*dps/1000.,perr[1]*dps/1000.*sqrt(bestn/dof)
;oplot,rp.center,rp.sigma,linestyle=2,color=cgcolor('red')
;oplot,[0,100],rp.psigma*3.0*[1.,1.],linestyle=2,color=cgcolor('red')

gnote='unkown'

note=name
note=[note,'skysub='+string(rp.skysub,format='(f8.5)'),'sky='+string(rp.sky,format='(f8.5)')]
al_legend,[note,'!6FWHM!dOBJ!n='+string(rp.fwhmd,format='(f4.2)')+'"'],box=0,/top,/right

oplot,rp.center_model,rp.mean_model/ns,linestyle=0,color=cgcolor('red')


if  n_elements(extrafun) ne 0 then begin
    CALL_PROCEDURE,extrafun
endif

ftag=where(rp.center gt xrange[0] and rp.center le xrange[1])
plot,[1],[1],psym=cgsymcat(1),$
  xrange=xrange,xstyle=1,$
  yrange=[0,max((rp.cflux)[ftag],/nan)*1.1],ystyle=1,$
  xtitle='Radius ["]',$
  ytitle='Cumulative Flux',$
  ;title=csv+'_'+band+'_'+gtag+'_'+stag+'.dat'$
  /nodata,pos=[0.1,0.1,0.9,0.50],/noe
oploterror,rp.center,rp.cflux,rp.cflux_sig
;; FOR PSF
;
;
;restore,'../../v5/psf/pcf2_bstar_I_pcf2_extract_median.xdr',/v
;if  csv eq 'dey15' then restore,'../../v5/psf/lae1_bstar_R_lae1_extract_median.xdr',/v
;if  keyword_set(refpsf) then  restore,refpsf,/v
;oplot,rx,ry/max(ry,/nan),color=cgcolor('gray'),thick=5,linestyle=2
;
;;nx=rp.median/rymean
;;nx=median(nx[[0,1]])
;;
;;dist_ellipse,temp,1201,600,600,1.0,0.,/double
;;temp=temp*0.05
;;psf=temp
;;for i=0,n_elements(rxmean)-1 do begin
;;    psf[where(temp le rxmean[i]+0.258/2.0 and temp gt rxmean[i]-0.258/2.0, /null)]=rymean[i]
;;endfor
;;rxb=0.5+findgen(10/0.5)*1.0
;;ryb=[]
;;for i=0,n_elements(rxb)-1 do begin
;;    ring=psf[where(temp lt rxb[i]+0.5 and temp ge rxb[i]-0.5, /null)]
;;    ryb=[ryb,median(ring)]
;;endfor
;
;;oplot,rxb,ryb/max(ryb,/nan),color=cgcolor('gray'),thick=5,linestyle=2
;;oplot,rxmean,rymean*nx,color=cgcolor('blue'),thick=5
;;yt=rymean*(max(rp.median,/nan)/max(rymean,/nan))
;
;;xt=[reverse(rxmean[1:*]),rxmean]
;;yt=[reverse(yt[1:*]),yt]
;;res=mpfitpeak(xt,yt,a,/moffat,/nan,nterms=4)
;;parinfo={fixed:0}
;;parinfo=replicate(parinfo,6)
;;parinfo[0].fixed=1
;;es=a
;;es[0]=0.0
;;;res=mpfitpeak(xt,yt,a,/moffat,parinfo=parinfo,es=es)
;;oplot,xt,res,color=cgcolor('blue'),linestyle=2
;;
;;fwhm=2.0*interpol(rxmean,alog10(rymean),alog10(max(rymean,/nan)*0.5),/nan)
;;al_legend,'!6FWHM!dPSF!n='+string(fwhm,format='(f4.2)')+'"',box=0,/bottom,/left,textcolor='blue'
;
;;+++
;;restore,'../psf/xhs_stack_extract_merge_'+band+'_pcf1.xdr',/v
;;nx=rp.median/rymean
;;nx=median(nx[[0,1]])
;;;oplot,rxmean,rymean*nx,color=cgcolor('blue'),thick=5
;;yt=rymean;*(max(rp.median,/nan)/max(rymean,/nan))
;xt=[reverse(rx[1:*]),rx]
;yt=[reverse(ry[1:*]),ry]
;res=mpfitpeak(xt,yt,a,/moffat,/nan,nterms=4)
;parinfo={fixed:0}
;parinfo=replicate(parinfo,6)
;parinfo[0].fixed=1
;es=a
;es[0]=0.0
;;res=mpfitpeak(xt,yt,a,/moffat,parinfo=parinfo,es=es)
;;ns=max(ryb,/nan)
;;print,ns
;;oplot,xt,res/ns,color=cgcolor('gray'),linestyle=2
;;
;fwhm=2.0*interpol(rx,alog10(ry),alog10(max(ry,/nan)*0.5),/nan)
;al_legend,'!6FWHM!dPSF!n='+string(fwhm,format='(f4.2)')+'"',box=0,/bottom,/left,textcolor='gray'
;;---

device,/close
set_plot,'x'

END
