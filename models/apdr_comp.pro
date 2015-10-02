PRO APDR_COMP

zm=1.0

nh=10.^(12.+findgen(1500)*0.01)
f=km_model(nh*8.00635e-21,zm,3.0)
print,f
nh1k=nh*(1.-f)
nh2k=nh*(f)/2.0>1.0

nh=10.^(12.+findgen(1500)*0.01)

f=(31.*3.0/(1.+3.1*zm^0.365)*0.5*3e-17*3.2e4)^2.0*nh<1.0
nh1l=nh*(1.-f)
nh2l=nh*(f)/2.0

f=2*31.*3.0/(1.+3.1*zm^0.365)*3e-17/(5.2e-11)
nh1t=nh*(1.-f)
nh2t=nh*(f)/2.0

kk=2*31.*3.0/(1.+3.1*zm^0.365)*3e-17/(5.2e-11)
nh2j=(kk*nh*exp(+1.9e-21*nh)/(1e14)^0.75)^4
nh1j=nh-nh2j*2

apdr,nh2c,nh1c,niuv=31.*3.0/(1.+3.1*zm^0.365),z=zm,geo='slab'

set_plot, 'ps'
device, filename='apdr_comp.eps', $
    bits_per_pixel=8,/encapsulated,$
    xsize=4.0,ysize=4.0,/inches,/col,xoffset=0,yoffset=0,/cmyk
!p.thick=1.7
!x.thick = 1.7
!y.thick = 1.7
!z.thick = 1.7
!p.charsize=1.0
!p.charthick=1.7
xyouts,'!6'   

plot,[1],[1],thick=5,xstyle=1,ystyle=1,$
    yrange=[13.5,23.1],xrange=[18.0,22.2],$
    xtitle=textoidl('log(!8N!3_{H} [cm!u-2!n])'),$
    ytitle=textoidl('log(!8N!3_{H2} [cm!u-2!n])'),$
    ;ytickformat='logticks_exp',xtickformat='logticks_exp',$
    pos=[0.18,0.15,0.97,0.97],/noe
;    plot,[0],[0],/xlog,/ylog,/noe,xstyle=1,ystyle=1,$
;        xrange=[0.2,1000],yrange=[0.2,1000],$
;        position=[0.1,0.20,0.45,0.90],$
;        xtitle=textoidl('!8N!3_{HI} [M!d!9n!3!n pc!u-2!n]'),$
;        ytitle=textoidl('\Sigma_{HI} [M!d!9n!3!n pc!u-2!n]'),$
;        ytickformat='logticks_exp',xtickformat='logticks_exp'
oplot,[18,23],[18+alog10(0.5),23+alog10(0.5)],thick=8,color=cgcolor('gray')
oplot,alog10(nh1c+nh2c*2.0),alog10(nh2c),thick=8
oplot,alog10(nh1k+nh2k*2.0),alog10(nh2k),thick=4,linestyle=2
oplot,alog10(nh1l+nh2l*2.0),alog10(nh2l),thick=4,linestyle=1
oplot,alog10(nh1t+nh2t*2.0),alog10(nh2t),thick=4,linestyle=1
;oplot,alog10(nh1j+nh2j*2.0),alog10(nh2j),thick=4,linestyle=1

device, /close
set_plot,'X'
;
;set_plot, 'ps'
;device, filename='apdr_comp_rmol.eps', $
;    bits_per_pixel=8,/encapsulated,$
;    xsize=4,ysize=4,/inches,/col,xoffset=0,yoffset=0,/cmyk
;!p.thick=1.7
;!x.thick = 1.7
;!y.thick = 1.7
;!z.thick = 1.7
;!p.charsize=1.0
;!p.charthick=1.7
;
;plot,[1],[1],/xlog,/ylog,thick=5,xstyle=1,ystyle=1,$
;    yrange=[0.01,100.],xrange=[10.^20,10.^24],$
;    xtitle=textoidl('!8N!3_{H} [M!d!9n!3!n pc!u-2!n]'),$
;    ytitle=textoidl('!8R!3_{mol}'),$
;    ytickformat='logticks_exp',xtickformat='logticks_exp',$
;    pos=[0.15,0.15,0.95,0.95],/noe
;;    plot,[0],[0],/xlog,/ylog,/noe,xstyle=1,ystyle=1,$
;;        xrange=[0.2,1000],yrange=[0.2,1000],$
;;        position=[0.1,0.20,0.45,0.90],$
;;        xtitle=textoidl('!8N!3_{HI} [M!d!9n!3!n pc!u-2!n]'),$
;;        ytitle=textoidl('\Sigma_{HI} [M!d!9n!3!n pc!u-2!n]'),$
;;        ytickformat='logticks_exp',xtickformat='logticks_exp'
;;oplot,[10.^19,10.^22],[10.^19,10.^22]*0.1,linestyle=1
;;oplot,[10.^19,10.^22],[10.^19,10.^22],linestyle=1
;;oplot,[10.^19,10.^22],[10.^19,10.^22]*10,linestyle=1
;oplot,nh1c+2.0*nh2c,2.0*nh2c/nh1c,thick=5,color=cgcolor('red')
;oplot,nh1s+2.0*nh2s,2.0*nh2s/nh1s,thick=5,color=cgcolor('red'),linestyle=2
;oplot,nh1g[nh_tag]+2.0*nh2g[nh_tag],2.0*nh2g[nh_tag]/nh1g[nh_tag],linestyle=0,color=cgcolor('green'),thick=5
;oplot,nh1g+2.0*nh2g,2.0*nh2g/nh1g,linestyle=1,color=cgcolor('red'),thick=5
;oplot,nh1k+2.0*nh2k,2.0*nh2k/nh1k
;oplot,nh1r+2.0*nh2r,2.0*nh2r/nh1r,color=cgcolor('cyan')
;
;device, /close
;set_plot,'X'

END




