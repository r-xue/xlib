

PRO RADPROFILE_PLOT,rp,name,$
    extrafun=extrafun,$
    drange=drange,xrange=xrange,ymax=ymax,$
    moffat=moffat,rscale=rscale,$
    kpc=kpc,$
    sfwhm=sfwhm,sname=sname,label=label,bunit=bunit
    
    
;+
;   plot maffat reference function
;       moffat[0]   ;   FWHM in arcsec
;       moffat[1]   ;   moffat beta
;       
;       
;   kpc:    switch units to kpc, psize will be in kpc
;-

if  n_elements(rscale) eq 0 then rscale=1.0
if  n_elements(ymax) eq 0 then ymax=5.0

set_plot,'ps'
device,filename=name+'_radprofile.eps',bits=8,$
    xsize=6.0,ysize=6.0,$
    /inches,/encapsulated,/color
!p.thick=2.0
!x.thick = 2.0
!y.thick = 2.0
!z.thick = 2.0
!p.charsize=1.0
!p.charthick=2.0
!x.gridstyle = 0
!y.gridstyle = 0
xyouts,'!6'

if  ~keyword_set(drange) then drange=1e4
if  ~keyword_set(xrange) then xrange=[0.,max(rp.center)]
yrange=ymax/[drange,1.0]

plot,[1],[1],psym=cgsymcat(1),$
    xrange=xrange,xstyle=1,$
    ytickformat='logticks_exp',$
    yrange=yrange,ystyle=9,/ylog,$
    xtitle='',$
    xtickformat='(a1)',$
    ytitle='Normalized Radial Profile',$
    ;title=csv+'_'+band+'_'+gtag+'_'+stag+'.dat'$
    /nodata,pos=[0.15,0.40,0.9,0.95]

ns=abs(max(rp.median,/nan))
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

if  n_elements(moffat) eq 2 then begin
    mpsize=rp.psize
    mhalfsz=max(rp.center)
    mpsf=get_psf('moffat',fwhm=moffat[0],beta=moffat[1],psize=mpsize,halfsz=mhalfsz,outname=name+'_moffat')
    mrp=radprofile_analyzer(name+'_moffat.fits',psize=mpsize,rbin=mpsize,/nosub,/silent)
    oplot,mrp.center,mrp.median,color=cgcolor('red')
endif

for i=0,n_elements(rp.center)-1 do begin
    limits=rp.median[i]>0.0+rp.unc[i]*2.0*[-1,1]
    limits=limits/ns
    limits=limits>(min(yrange)*0.1)
    
    if  rp.median[i]/ns gt 0 then begin
        scode=16
        flip=1.0
        lstyle=0 
    endif else begin
        scode=5
        flip=-1.0
        lstyle=0
    endelse
    cgplots,rp.center[i],flip*rp.median[i]/ns,psym=cgsymcat(scode),noclip=0,color=cgcolor('dark gray'),symsize=0.8
    cgplots,rp.center[i]*[1,1],([rp.pertile25[i],rp.pertile75[i]]/ns)>(min(yrange)*0.1),$
        linestyle=lstyle,$
        thick=1,color=cgcolor('dark gray'),noclip=0
        
    
    ;cgplots,[rp.center[i],rp.center[i]],limits,thick=5,color=cgcolor('dark gray'),noclip=0
    ;cgplots,rp.center[i],rp.median[i]/ns,psym=symcat(16),noclip=0,color=cgcolor('black')
    ;cgplots,rp.center[i],rp.mean[i]/ns,psym=symcat(6),noclip=0,color=cgcolor('red')
endfor
;oplot,rp.center,3.0*rp.unc/ns,linestyle=2

if  keyword_set(kpc) then begin
    runits_string='kpc'
endif else begin
    runits_string='"'
endelse

note=[]
if  keyword_set(sname) then note=[note,name]
if  keyword_set(label) then note=[label,note]
if  keyword_set(sfwhm) then note=[note,'!6FWHM='+string(rp.fwhmi,format='(f5.2)')+runits_string]
if  n_elements(note) ne 0 then al_legend,note,box=0,/top,/right

ystyle=1
if  keyword_set(bunit) then ystyle=9
plot,[1],[1],psym=cgsymcat(1),$
    xrange=xrange,xstyle=1,$
    ytickformat='logticks_exp',$
    yrange=yrange,ystyle=ystyle,/ylog,$
    xtitle='',$
    xtickformat='(a1)',$
    ytitle='Normalized Radial Profile',$
    ;title=csv+'_'+band+'_'+gtag+'_'+stag+'.dat'$
    /nodata,pos=[0.15,0.40,0.9,0.95],/noe
if  ystyle eq 9 then begin
    axis,YAxis=1, YLog=1, YRange=yrange*ns*c2f,$
        ytitle='image units',$
        ytickformat='logticks_exp',ystyle=1
endif

;   LOWER PANEL

rscale_string=string(rscale,format='(i0)')+runits_string
plot,[1],[1],psym=cgsymcat(1),$
    xrange=xrange,xstyle=1,$
    yrange=[0,2.0],ystyle=1,$
    xtitle='Radius ['+runits_string+']',$
    ytitle='Flux!dr!n/Flux!dr<'+rscale_string+'!n',$
    /nodata,pos=[0.15,0.1,0.9,0.39],/noe

if  n_elements(extrafun) ne 0 then begin
    CALL_PROCEDURE,extrafun.name,extrafun.p1,'cflux',rscale
endif

if  n_elements(moffat) eq 2 then begin
    tmp=min(abs(mrp.center-rscale),tag)
    mns=(mrp.cflux)[tag]
    oplot,mrp.center,mrp.cflux/mns,color=cgcolor('red')
endif


tmp=min(abs(rp.center-rscale),tag)
ns=abs((rp.cflux)[tag])

for i=0,n_elements(rp.center)-1 do begin
    if  rp.median[i]/ns gt 0 then begin
        scode=16
        flip=1.0
        lstyle=0
    endif else begin
        scode=5
        flip=-1.0
        lstyle=0
    endelse
    cgplots,rp.center[i],rp.cflux[i]/ns,psym=symcat(scode),symsize=0.8,noclip=0,color=cgcolor('dark gray')
    cgplots,rp.center[i]*[1,1],(rp.cflux_sig[i]*[-1,+1]+rp.cflux[i])/ns,$
        linestyle=lstyle,$
        thick=1,color=cgcolor('dark gray'),noclip=0
endfor
oplot,rscale*[1.,1.],[0.7,0.9],color=cgcolor('red'),thick=10
oplot,rscale*[1.,1.],[1.1,1.3],color=cgcolor('red'),thick=10

device,/close
set_plot,'x'

END

;FUNCTION smodel,p,x=x,y=y,err=err
;
;    ym=p[0]*exp(-x/p[1])
;    return,(y-ym)/err
;
;END


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
