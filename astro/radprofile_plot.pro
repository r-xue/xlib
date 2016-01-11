FUNCTION smodel,p,x=x,y=y,err=err

ym=p[0]*exp(-x/p[1])
return,(y-ym)/err

END

PRO RADPROFILE_PLOT,rp,name,$
    extrafun=extrafun,drange=drange,$
    xrange=xrange,label=label

set_plot,'ps'
device,filename=name+'_radprofile.eps',bits=8,$
    xsize=6.0,ysize=6.0,$
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

if  ~keyword_set(drange) then drange=1e4
if  ~keyword_set(xrange) then xrange=[0.,max(rp.center)]
yrange=5/[drange,1.0]

plot,[1],[1],psym=cgsymcat(1),$
    xrange=xrange,xstyle=1,$
    ytickformat='logticks_exp',$
    yrange=yrange,ystyle=9,/ylog,$
    xtitle='',$
    xtickformat='(a1)',$
    ytitle='Normalized Radial Profile',$
    ;title=csv+'_'+band+'_'+gtag+'_'+stag+'.dat'$
    /nodata,pos=[0.15,0.40,0.9,0.95]

ns=max(rp.median,/nan)
ns1=max(rp.mean,/nan)
c2f=1.0

;ty1=[]
;ty2=[]
;tx=[]
;for i=0,n_elements(rp.center)-1 do begin
;    ;cgplots,[rp.center[i],rp.center[i]],([rp.quarlow[i],rp.quarup[i]]/ns)>(min(yrange)*0.1),thick=5,color=cgcolor('dark gray'),noclip=0
;    ;cgplots,[rp.center[i],rp.center[i]],(rp.median[i]/ns+[-rp.rms[i],+rp.rms[i]]/ns)>(min(yrange)*0.1),thick=5,color=cgcolor('dark gray'),noclip=0
;    ;print,rp.center[i],rp.quarlow[i],rp.quarup[i],rp.mean[i]
;    cgplots,rp.center[i],rp.median[i]/ns,psym=symcat(16),noclip=0,color=cgcolor('dark gray')
;    cgplots,rp.center[i],rp.mean[i]/ns,psym=symcat(16),noclip=0,color=cgcolor('red')
;    ;cgplots,rp.center[i],rp.mean[i]/ns1,psym=symcat(6),noclip=0,color=cgcolor('black')
;    tx=[tx,rp.center[i]]
;    ty1=[ty1,(rp.median[i]/ns+[-rp.sigma[i]]/ns)>(min(yrange)*0.1)]
;    ty2=[ty2,(rp.median[i]/ns+[+rp.sigma[i]]/ns)>(min(rp.sigma[i])/ns)]
;endfor
;oplot,xrange,rp.psigma*[1.,1.]/ns,color=cgcolor('black')
;oplot,rp.center,2.0*rp.sigma/ns,color=cgcolor('gray')

;polyfill,[tx,reverse(tx)],[ty2,reverse(ty1)],color=cgcolor('gray'),noclip=0

if  n_elements(extrafun) ne 0 then begin
    CALL_PROCEDURE,extrafun.name,extrafun.p1,'dflux'
endif

for i=0,n_elements(rp.center)-1 do begin
    limits=rp.median[i]+rp.unc[i]*[-1,1]
    limits=limits/ns
    limits=limits>(min(yrange)*0.1)
    cgplots,[rp.center[i],rp.center[i]],limits,thick=5,color=cgcolor('dark gray'),noclip=0
    cgplots,rp.center[i],rp.median[i]/ns,psym=symcat(16),noclip=0,color=cgcolor('black')
    cgplots,rp.center[i],rp.mean[i]/ns,psym=symcat(6),noclip=0,color=cgcolor('red')
endfor
note=name
if  keyword_set(label) then note=[label,note]
;oplot,[0,100],2.0*rp.skysig/ns*[1,1]
oplot,rp.center,2.0*rp.unc/ns,linestyle=2
al_legend,[note,'!6FWHM!dOBJ!n='+string(rp.fwhma,format='(f4.2)')+'"'],box=0,/top,/right


plot,[1],[1],psym=cgsymcat(1),$
    xrange=xrange,xstyle=1,$
    ytickformat='logticks_exp',$
    yrange=yrange,ystyle=9,/ylog,$
    xtitle='',$
    xtickformat='(a1)',$
    ytitle='Normalized Radial Profile',$
    ;title=csv+'_'+band+'_'+gtag+'_'+stag+'.dat'$
    /nodata,pos=[0.15,0.40,0.9,0.95],/noe
axis,YAxis=1, YLog=1, YRange=yrange*ns*c2f,$
    ytitle='image units',$
    ytickformat='logticks_exp',ystyle=1
    

rscale=1.0
plot,[1],[1],psym=cgsymcat(1),$
    xrange=xrange,xstyle=1,$
    yrange=[0,2.5],ystyle=1,$
    xtitle='Radius ["]',$
    ytitle='Flux!dr!n/Flux!d1"!n',$
    /nodata,pos=[0.15,0.1,0.9,0.38],/noe
if  n_elements(extrafun) ne 0 then begin
    CALL_PROCEDURE,extrafun.name,extrafun.p1,'cflux',rscale
endif
tmp=min(abs(rp.center-rscale),tag)
ns=(rp.cflux)[tag]
oploterror,rp.center,rp.cflux/ns,rp.cflux_sig/ns,psym=symcat(16),/nohat

;
;tag=where(rp.center gt 1.75 and rp.center le 4.0)
;start_params=[2.0,3.0]
;xx=rp.center[tag]
;yy=rp.median[tag]/ns
;ee=(abs(rp.quarlow/ns-yy)*abs(rp.quarup/ns-yy))^0.5
;functargs = {x:xx, y:yy, err:ee}
;params=mpfit('smodel',start_params,functargs=functargs,perr=perr,BESTNORM=bestn,dof=dof)
;;oplot,xx,params[0]*exp(-xx/params[1])
;forward_function DCOMOVINGTRANSVERSE
;red,omega0=0.27,omegalambda=0.73,h100=0.7
;dps=DCOMOVINGTRANSVERSE(3.78)*!dpi/(180.*60*60)
;print,'-----',params
;print,'-----',params[1]*dps/1000.,perr[1]*dps/1000.*sqrt(bestn/dof)
;;oplot,rp.center,rp.sigma,linestyle=2,color=cgcolor('red')
;;oplot,[0,100],rp.psigma*3.0*[1.,1.],linestyle=2,color=cgcolor('red')

;oplot,rp.center_model,rp.mean_model/ns,linestyle=0,color=cgcolor('red')
;;note=[note,'skysub='+string(rp.skysub,format='(f8.5)'),'sky='+string(rp.sky,format='(f8.5)')]
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
