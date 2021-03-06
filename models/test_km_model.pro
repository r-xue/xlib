PRO test_km_model


loc='/Users/Rui/Workspace/sting/analysis/'


n_model=100000
x_model=FINDGEN(n_model)*0.05+0.1
theta=0.+2.*!pi/100.*findgen(100)
sc_list=[[4.,4.],[8.,8.],[12.,12.]]

z_list=[0.2,1.0,5.0]
z_color=['red','green','blue']
nm=n_elements(z_list)

fh2_mckee=fltarr(n_model,nm)
for i=0,nm-1 do begin
 fh2_mckee[*,i]=km_model(x_model,z_list[i],3.0) 
endfor
fh2_mckee10=fltarr(n_model,nm)
for i=0,nm-1 do begin
 fh2_mckee10[*,i]=km_model(x_model,z_list[i],8.0) 
endfor

sat=[]
for i=0,nm-1 do begin
;tmp=INTERPOL(x_model, fh2_mckee[*,i], 0.5)/2
tmp=km_model_simp(z_list[i],3.0)
sat=[sat,tmp]
endfor


fh2_jump=fltarr(n_model,nm)
for i=0,nm-1 do begin
tag=where(x_model gt sat[i])
fh2_jump[tag,i]=(x_model[tag]-sat[i])/x_model[tag]
endfor

set_plot, 'ps'
device, filename='test.eps', $
bits_per_pixel=8,/encapsulated,$
xsize=8,ysize=8,/inches,/col,xoffset=0,yoffset=0,/cmyk

!p.thick=1.7
!x.thick = 1.7
!y.thick = 1.7
!z.thick = 1.7
!p.charsize=1.0
!p.charthick=1.7


plot,[0],[0],/xlog,/ylog,/noe,xstyle=1,ystyle=1,$
  xrange=[0.2,2000],yrange=[0.2,2000],$
  position=[0.1,0.55,0.45,0.90],$
  xtitle=textoidl('\Sigma_{H2}+\Sigma_{HI} [M!d!9n!3!n pc!u-2!n]'),$
  ytitle=textoidl('\Sigma_{HI} [M!d!9n!3!n pc!u-2!n]'),$
  ytickformat='logticks_exp',xtickformat='logticks_exp'
xsig=[0.2,2000]
ysig=[1.0,1.0]
polyfill,[xsig,2000,0.2],[ysig,0.2,0.2],color=220
xsig=[0.2,2000]
ysig=[1.414,1.414]
polyfill,[ysig,0.2,0.2],[xsig,2000,0.2],color=220
for i=0,nm-1 do begin  
oplot,x_model,x_model*(1-fh2_mckee[*,i]),color=cgcolor(z_color[i]),linestyle=0
oplot,x_model,x_model*(1-fh2_mckee10[*,i]),color=cgcolor(z_color[i]),linestyle=1
oplot,x_model,x_model*(1-fh2_jump[*,i]),color=cgcolor(z_color[i]),linestyle=2
endfor
al_legend,["Z'=0.2Z!d!9n!3!n","Z'=1Z!d!9n!3!n","Z'=5Z!d!9n!3!n"],$
  textcolors=cgcolor(z_color),$
  pos=[0.12,0.80],/norm,box=0
al_legend,['MK10 '+textoidl('\phi_{CNM}=3'),$
        'MK10M '+textoidl('\phi_{CNM}=3'),$
        'MK10 '+textoidl('\phi_{CNM}=8')],$
        linestyle=[0,2,1],$
  textcolors=50,colors=50,$
  pos=[0.12,0.87],/norm,box=0
for i=0,2 do begin
sc=sc_list[*,i]
x=sc[0]+3.0*cos(theta)
y=sc[1]+3.0*sin(theta)
oplot,x+y,x,color=150
oplot,[sc[1]+sc[0]],[sc[0]],psym=symcat(16),color=150,symsize=0.5
endfor
plot,[0],[0],/xlog,/ylog,/noe,xstyle=1,ystyle=1,$
  xrange=[0.2,2000],yrange=[0.2,2000],$
  position=[0.1,0.55,0.45,0.90],$
  xtitle=textoidl('\Sigma_{H2}+\Sigma_{HI} [M!d!9n!3!n pc!u-2!n]'),$
  ytitle=textoidl('\Sigma_{HI} [M!d!9n!3!n pc!u-2!n]'),$
  ytickformat='logticks_exp',xtickformat='logticks_exp'


plot,[0],[0],/xlog,/ylog,/noe,xstyle=1,ystyle=1,$
  xrange=[0.2,2000],yrange=[0.2,2000],$
  position=[0.55,0.55,0.90,0.90],$
  xtitle=textoidl('\Sigma_{HI} [M!d!9n!3!n pc!u-2!n]'),$
  ytitle=textoidl('\Sigma_{H2} [M!d!9n!3!n pc!u-2!n]'),$
  ytickformat='logticks_exp',xtickformat='logticks_exp'
xsig=[0.2,2000]
ysig=[1.0,1.0]
polyfill,[xsig,2000,0.2],[ysig,0.2,0.2],color=220
xsig=[0.2,2000]
ysig=[1.0,1.0]
polyfill,[ysig,0.2,0.2],[xsig,2000,0.2],color=220
for i=0,nm-1 do begin  
oplot,x_model*(1-fh2_mckee[*,i]),x_model*fh2_mckee[*,i],color=cgcolor(z_color[i]),linestyle=0
oplot,x_model*(1-fh2_mckee10[*,i]),x_model*fh2_mckee10[*,i],color=cgcolor(z_color[i]),linestyle=1
oplot,x_model*(1-fh2_jump[*,i]),x_model*fh2_jump[*,i],color=cgcolor(z_color[i]),linestyle=2
endfor
for i=0,2 do begin
sc=sc_list[*,i]
x=sc[0]+3.0*cos(theta)
y=sc[1]+3.0*sin(theta)
oplot,x,y,color=150
oplot,[sc[0]],[sc[1]],psym=symcat(16),color=150,symsize=0.5
endfor
oplot,[0.2,2000.],[0.2,2000.],color=100
plot,[0],[0],/xlog,/ylog,/noe,xstyle=1,ystyle=1,$
  xrange=[0.2,2000],yrange=[0.2,2000],$
  position=[0.55,0.55,0.90,0.90],$
  xtitle=textoidl('\Sigma_{HI} [M!d!9n!3!n pc!u-2!n]'),$
  ytitle=textoidl('\Sigma_{H2} [M!d!9n!3!n pc!u-2!n]'),$
  ytickformat='logticks_exp',xtickformat='logticks_exp'


plot,[0],[0],/xlog,/noe,xstyle=1,ystyle=1,$
  xrange=[0.2,2000],yrange=[-1.5,4],$
  position=[0.1,0.13,0.45,0.48],$
  xtitle=textoidl('\Sigma_{H2}+\Sigma_{HI} [M!d!9n!3!n pc!u-2!n]'),$
  ytitle=textoidl('log(\Sigma_{H2}/\Sigma_{HI})'),$
  xtickformat='logticks_exp',$
  yMINOR=4
xsig=[-1.5,4]
ysig=[1.414,1.414]
polyfill,[ysig,0.2,0.2],[xsig,4,-1.5],color=220
for i=0,nm-1 do begin  
oplot,x_model,alog10(fh2_mckee[*,i]/(1-fh2_mckee[*,i])),color=cgcolor(z_color[i]),linestyle=0
oplot,x_model,alog10(fh2_mckee10[*,i]/(1-fh2_mckee10[*,i])),color=cgcolor(z_color[i]),linestyle=1
oplot,x_model,alog10(fh2_jump[*,i]/(1-fh2_jump[*,i])),color=cgcolor(z_color[i]),linestyle=2
endfor
for i=0,2 do begin
sc=sc_list[*,i]
x=sc[0]+3.0*cos(theta)
y=sc[1]+3.0*sin(theta)
oplot,x+y,alog10(y/x),color=150
oplot,[sc[1]+sc[0]],[alog10(sc[1]/sc[0])],psym=symcat(16),color=150,symsize=0.5
endfor 
plot,[0],[0],/xlog,/noe,xstyle=1,ystyle=1,$
  xrange=[0.2,2000],yrange=[-1.5,4],$
  position=[0.1,0.13,0.45,0.48],$
  xtitle=textoidl('\Sigma_{H2}+\Sigma_{HI} [M!d!9n!3!n pc!u-2!n]'),$
  ytitle=textoidl('log(\Sigma_{H2}/\Sigma_{HI})'),$
  xtickformat='logticks_exp',$
  yMINOR=4

plot,[0],[0],/xlog,/noe,xstyle=1,ystyle=1,$
  xrange=[0.2,2000],yrange=[0.0,1],$
  position=[0.55,0.13,0.90,0.48],$
  xtitle=textoidl('\Sigma_{H2}+\Sigma_{HI} [M!d!9n!3!n pc!u-2!n]'),$
  ytitle=textoidl('!8f!3_{H2}'),$
  xtickformat='logticks_exp'
xsig=[0.0,1.0]
ysig=[1.414,1.414]
polyfill,[ysig,0.2,0.2],[xsig,1.0,0.0],color=220
for i=0,nm-1 do begin  
oplot,x_model,fh2_mckee[*,i],color=cgcolor(z_color[i]),linestyle=0
oplot,x_model,fh2_mckee10[*,i],color=cgcolor(z_color[i]),linestyle=1
oplot,x_model,fh2_jump[*,i],color=cgcolor(z_color[i]),linestyle=2
endfor
for i=0,2 do begin
sc=sc_list[*,i]
x=sc[0]+3.0*cos(theta)
y=sc[1]+3.0*sin(theta)
oplot,x+y,y/(x+y),color=150
oplot,[sc[1]+sc[0]],[sc[1]/(sc[0]+sc[1])],psym=symcat(16),color=150,symsize=0.5
endfor
plot,[0],[0],/xlog,/noe,xstyle=1,ystyle=1,$
  xrange=[0.2,2000],yrange=[0.0,1],$
  position=[0.55,0.13,0.90,0.48],$
  xtitle=textoidl('\Sigma_{H2}+\Sigma_{HI} [M!d!9n!3!n pc!u-2!n]'),$
  ytitle=textoidl('!8f!3_{H2}'),$
  xtickformat='logticks_exp'


device, /close
set_plot,'X'

End


