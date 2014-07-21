PRO APDR_HI2H2viaSFL,sig_hi,sig_h2
;+
;   if the SF law is indead linear.
;   NUV-based SFR can be used to trace H2 never seen in CO because of H2 detection snestivity.
;
;-
sig_hi=10.^[-0.4,0.4,1.0,-0.4]
SFR=10.^[-6.,-6.,-3.25,-4.25]

sig_h2=SFR/(10.^(-2.1))    


END


PRO A2M_COMP


nh2=10.^(12.+findgen(1200)*0.01)
sh2=nh2*2.*8.00635e-21

sh1=a2m_models_calc(sh2,0.75,model='s14comp')
nh1=sh1/8.00635e-21
nh2c=nh2
nh1c=nh1

sh1=a2m_models_calc(sh2,1.0,model='s14slab')
nh1=sh1/8.00635e-21
nh2s=nh2
nh1s=nh1

sh1=a2m_models_calc(sh2,1.0,model='gd14')
nh1=sh1/8.00635e-21
nh2g=nh2
nh1g=nh1
nh_tag=where(nh2g/nh1g ge 0.1)

sh1=a2m_models_calc(sh2,1.0,model='gd14x')
nh1=sh1/8.00635e-21
nh2gu10=nh2
nh1gu10=nh1
nhu10_tag=where(nh2gu10/nh1gu10 ge 0.1)

sh1=a2m_models_calc(sh2,1.0,model='mk10')
nh1=sh1/8.00635e-21
nh2k=nh2
nh1k=nh1

sh1=a2m_models_calc(sh2,sh2*10.,model='br06')
nh1=sh1/8.00635e-21
nh2r=nh2
nh1r=nh1

APDR_HI2H2viaSFL,sig_hi,sig_h2
nh1u=sig_hi/8.00635e-21*1.6/2.3
nh2u=sig_h2*(1.6/2.3)/8.00635e-21/2.0
rmol_hydro,nh1r,nh2r

;apdr,nh2c,nh1c,niuv=23,z=1.0,geo='complex'
;apdr,nh2s,nh1s,niuv=23,z=1.0,geo='slab'
;GNEDIN,l=500,sig_h2=sig_h2,sig_h1=sig_h1,u=1,dgr_mw=dgr_mw
;nh1g=sig_h1/8.00635e-21*1.67/2.3
;nh2g=sig_h2/8.00635e-21*1.67/2.3/2.0
;nh_tag=where(nh2g/nh1g ge 0.1)
;GNEDIN,l=500,sig_h2=sig_h2u10,sig_h1=sig_h1u10,u=10,dgr_mw=dgr_mw
;nh1gu10=sig_h1u10/8.00635e-21*1.67/2.3
;nh2gu10=sig_h2u10/8.00635e-21*1.67/2.3/2.0
;nhu10_tag=where(nh2gu10/nh1gu10 ge 0.1)

;n_model=100000
;xmodel=FINDGEN(n_model)*0.1+0.1
;fh2_mckee=km_model(xmodel,1.0,3.0)
;nh1k=xmodel*(1.-fh2_mckee)/8.00635e-21
;nh2k=xmodel*fh2_mckee/8.00635e-21/2.0
;nh2k[where(nh2k le 1e14)]=10.^10



;


set_plot, 'ps'
device, filename='apdr_comp_h2vsh1.eps', $
    bits_per_pixel=8,/encapsulated,$
    xsize=4,ysize=4,/inches,/col,xoffset=0,yoffset=0,/cmyk
!p.thick=1.7
!x.thick = 1.7
!y.thick = 1.7
!z.thick = 1.7
!p.charsize=1.0
!p.charthick=1.7

plot,[1],[1],/xlog,/ylog,thick=5,xstyle=1,ystyle=1,$
    yrange=[10.^13,10.^24],xrange=[10.^19,10.^22],$
    xtitle=textoidl('!8N!3_{HI} [M!d!9n!3!n pc!u-2!n]'),$
    ytitle=textoidl('!8N!3_{H2} [M!d!9n!3!n pc!u-2!n]'),$
    ytickformat='logticks_exp',xtickformat='logticks_exp',$
    pos=[0.15,0.15,0.95,0.95],/noe
;    plot,[0],[0],/xlog,/ylog,/noe,xstyle=1,ystyle=1,$
;        xrange=[0.2,1000],yrange=[0.2,1000],$
;        position=[0.1,0.20,0.45,0.90],$
;        xtitle=textoidl('!8N!3_{HI} [M!d!9n!3!n pc!u-2!n]'),$
;        ytitle=textoidl('\Sigma_{HI} [M!d!9n!3!n pc!u-2!n]'),$
;        ytickformat='logticks_exp',xtickformat='logticks_exp'
xabssen=10.^21
yabssen=10.^21
;polyfill,nh1u,nh2u,color=cgcolor('gray')
xyouts,nh1u[0],nh2u[0]*5.0,$
    'Expected H2-HI Relation!cbased on observed linear SFR-H2 relation !cAnd observed SFR-HI relation from (Bigiel et al. 2008,2010)',charsize=0.5
xp=[10.,xabssen,xabssen,10.]
yp=[10,10,yabssen,yabssen]
oplot,xp,yp,noclip=0,color=cgcolor('grey'),thick=20
xyouts,0.2,0.20,'Emission',/normal,charsize=1.0,charthick=5.0,color=cgcolor('black')
xemisen=10.^20
yemisen=10.^20
xp=[xemisen,xemisen,10.^25,10.^25]
yp=[10.^25,yemisen,yemisen,10.^25]
oplot,xp,yp,noclip=0,color=cgcolor('grey'),thick=20
xyouts,0.75,0.85,'Absorption',/normal,charsize=1.0,charthick=5.0,color=cgcolor('black')


nearby_UVHI_RD,shi,sfr,type,name
tt=where(type eq 'Spirals ',/null) ;Spirals Dwarfs
print,n_elements(tt)
shi=shi[tt]
sfr=sfr[tt]
type=type[tt]
name=name[tt]

xx=shi/8.00635e-21*1.67/2.3
yy=SFR/(10.^(-2.1))/8.00635e-21*1.67/2.3/2.0
oplot,xx,yy,psym=symcat(16),symsize=0.1
cgloadct,3, /reverse
plothist2d,xx,yy,0.1,0.1,/xlog,/ylog,$
    xmin=min(xx),xmax=max(xx),ymin=min(yy),ymax=max(yy),$
    clip=[min(xx),min(yy),max(xx),max(yy)],/histlog,$
    /pl_cont,$
    wtid=name
cgloadct,0

plot,[1],[1],/xlog,/ylog,thick=5,xstyle=1,ystyle=1,$
    yrange=[10.^13,10.^24],xrange=[10.^19,10.^22],$
    xtitle=textoidl('!8N!3_{HI} [M!d!9n!3!n pc!u-2!n]'),$
    ytitle=textoidl('!8N!3_{H2} [M!d!9n!3!n pc!u-2!n]'),$
    ytickformat='logticks_exp',xtickformat='logticks_exp',$
    pos=[0.15,0.15,0.95,0.95],/noe
;    plot,[0],[0],/xlog,/ylog,/noe,xstyle=1,ystyle=1,$
;        xrange=[0.2,1000],yrange=[0.2,1000],$
;        position=[0.1,0.20,0.45,0.90],$
;        xtitle=textoidl('!8N!3_{HI} [M!d!9n!3!n pc!u-2!n]'),$
;        ytitle=textoidl('\Sigma_{HI} [M!d!9n!3!n pc!u-2!n]'),$
;        ytickformat='logticks_exp',xtickformat='logticks_exp'

oplot,[10.^19,10.^22],[10.^19,10.^22]*0.1,linestyle=1
oplot,[10.^19,10.^22],[10.^19,10.^22],linestyle=1
oplot,[10.^19,10.^22],[10.^19,10.^22]*10,linestyle=1
oplot,nh1c,nh2c,thick=5,color=cgcolor('red')
oplot,nh1s,nh2s,thick=5,color=cgcolor('red'),linestyle=2

oplot,nh1g[nh_tag],nh2g[nh_tag],linestyle=0,color=cgcolor('green'),thick=5
oplot,nh1g,nh2g,linestyle=1,color=cgcolor('green'),thick=5
oplot,nh1gu10[nhu10_tag],nh2gu10[nhu10_tag],linestyle=0,color=cgcolor('green'),thick=5
oplot,nh1gu10,nh2gu10,linestyle=1,color=cgcolor('green'),thick=5

oplot,nh1k,nh2k
oplot,nh1r,nh2r,color=cgcolor('cyan')




device, /close
set_plot,'X'

set_plot, 'ps'
device, filename='apdr_comp_rmol.eps', $
    bits_per_pixel=8,/encapsulated,$
    xsize=4,ysize=4,/inches,/col,xoffset=0,yoffset=0,/cmyk
!p.thick=1.7
!x.thick = 1.7
!y.thick = 1.7
!z.thick = 1.7
!p.charsize=1.0
!p.charthick=1.7

plot,[1],[1],/xlog,/ylog,thick=5,xstyle=1,ystyle=1,$
    yrange=[0.01,100.],xrange=[10.^20,10.^24],$
    xtitle=textoidl('!8N!3_{H} [M!d!9n!3!n pc!u-2!n]'),$
    ytitle=textoidl('!8R!3_{mol}'),$
    ytickformat='logticks_exp',xtickformat='logticks_exp',$
    pos=[0.15,0.15,0.95,0.95],/noe
;    plot,[0],[0],/xlog,/ylog,/noe,xstyle=1,ystyle=1,$
;        xrange=[0.2,1000],yrange=[0.2,1000],$
;        position=[0.1,0.20,0.45,0.90],$
;        xtitle=textoidl('!8N!3_{HI} [M!d!9n!3!n pc!u-2!n]'),$
;        ytitle=textoidl('\Sigma_{HI} [M!d!9n!3!n pc!u-2!n]'),$
;        ytickformat='logticks_exp',xtickformat='logticks_exp'
;oplot,[10.^19,10.^22],[10.^19,10.^22]*0.1,linestyle=1
;oplot,[10.^19,10.^22],[10.^19,10.^22],linestyle=1
;oplot,[10.^19,10.^22],[10.^19,10.^22]*10,linestyle=1
oplot,nh1c+2.0*nh2c,2.0*nh2c/nh1c,thick=5,color=cgcolor('red')
oplot,nh1s+2.0*nh2s,2.0*nh2s/nh1s,thick=5,color=cgcolor('red'),linestyle=2
oplot,nh1g[nh_tag]+2.0*nh2g[nh_tag],2.0*nh2g[nh_tag]/nh1g[nh_tag],linestyle=0,color=cgcolor('green'),thick=5
oplot,nh1g+2.0*nh2g,2.0*nh2g/nh1g,linestyle=1,color=cgcolor('red'),thick=5
oplot,nh1k+2.0*nh2k,2.0*nh2k/nh1k
oplot,nh1r+2.0*nh2r,2.0*nh2r/nh1r,color=cgcolor('cyan')

device, /close
set_plot,'X'

END




