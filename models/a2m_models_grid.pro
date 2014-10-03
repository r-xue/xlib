PRO A2M_MK10_GRID

x_model=10.0^(findgen(1000)*0.01-2.)
zm=10.^(7.0+(9.5-7.0)*findgen(100)*0.01-8.69)
mk10_grid=fltarr(n_elements(x_model),4,n_elements(zm))
for i=0,99 do begin
  f=km_model(x_model,zm[i],3.0)
  f=f>1e-10
  mk10_grid[*,0,i]=x_model          ;
  mk10_grid[*,1,i]=x_model*f        ;h2
  mk10_grid[*,2,i]=x_model*(1-f)    ;hi
  mk10_grid[*,3,i]=f                ;h2 mass faraction
endfor

window,0,xsize=500,ysize=500
plot,[1],[1],xrange=[0.1,100],yrang=[1e-7,1e3],/xlog,/ylog,xstyle=1,ystyle=1
for i=0,99 do begin
  oplot,mk10_grid[*,2,i],mk10_grid[*,1,i]
endfor

path=cgsourcedir()
datfile=path+'/a2m_mk10_grid.dat'
mk10_zm=zm

save,filename=datfile,mk10_grid,mk10_zm

END

PRO A2M_MK10PH10_GRID

x_model=10.0^(findgen(1000)*0.01-2.)
zm=10.^(7.0+(9.5-7.0)*findgen(100)*0.01-8.69)
mk10_grid=fltarr(n_elements(x_model),4,n_elements(zm))
for i=0,99 do begin
    f=km_model(x_model,zm[i],10.0)
    f=f>1e-10
    mk10_grid[*,0,i]=x_model          ;
    mk10_grid[*,1,i]=x_model*f        ;h2
    mk10_grid[*,2,i]=x_model*(1-f)    ;hi
    mk10_grid[*,3,i]=f                ;h2 mass faraction
endfor

window,0,xsize=500,ysize=500
plot,[1],[1],xrange=[0.1,100],yrang=[1e-7,1e3],/xlog,/ylog,xstyle=1,ystyle=1
for i=0,99 do begin
    oplot,mk10_grid[*,2,i],mk10_grid[*,1,i]
endfor

path=cgsourcedir()
datfile=path+'/a2m_mk10ph10_grid.dat'
mk10_zm=zm
mk10ph10_grid=mk10_grid
save,filename=datfile,mk10ph10_grid,mk10_zm
    
END

PRO A2M_MK10PH1_GRID

x_model=10.0^(findgen(1000)*0.01-2.)
zm=10.^(7.0+(9.5-7.0)*findgen(100)*0.01-8.69)
mk10_grid=fltarr(n_elements(x_model),4,n_elements(zm))
for i=0,99 do begin
    f=km_model(x_model,zm[i],1.0)
    f=f>1e-10
    mk10_grid[*,0,i]=x_model          ;
    mk10_grid[*,1,i]=x_model*f        ;h2
    mk10_grid[*,2,i]=x_model*(1-f)    ;hi
    mk10_grid[*,3,i]=f                ;h2 mass faraction
endfor

window,0,xsize=500,ysize=500
plot,[1],[1],xrange=[0.1,100],yrang=[1e-7,1e3],/xlog,/ylog,xstyle=1,ystyle=1
for i=0,99 do begin
    oplot,mk10_grid[*,2,i],mk10_grid[*,1,i]
endfor

path=cgsourcedir()
datfile=path+'/a2m_mk10ph1_grid.dat'
mk10_zm=zm
mk10ph1_grid=mk10_grid
save,filename=datfile,mk10ph1_grid,mk10_zm
    
END


PRO A2M_S14_GRID

zm=10.^(7.0+(9.5-7.0)*findgen(100)*0.01-8.69)
s14slab_grid=fltarr(2400,4,n_elements(zm))
s14comp_grid=fltarr(2400,4,n_elements(zm))
for i=0,99 do begin
    apdr,nh2c,nh1c,niuv=31.*3.0/(1.+3.1*zm[i]^0.365),z=zm[i],geo='complex'
    apdr,nh2s,nh1s,niuv=31.*3.0/(1.+3.1*zm[i]^0.365),z=zm[i],geo='slab'
    s14comp_grid[*,0,i]=(nh1c+nh2c*2.0)*8.00635e-21
    s14comp_grid[*,1,i]=(nh2c*2.0)*8.00635e-21
    s14comp_grid[*,2,i]=(nh1c)*8.00635e-21
    s14comp_grid[*,3,i]=nh2c*2.0/(nh1c+nh2c*2.0)
    s14slab_grid[*,0,i]=(nh1s+nh2s*2.0)*8.00635e-21
    s14slab_grid[*,1,i]=(nh2s*2.0)*8.00635e-21
    s14slab_grid[*,2,i]=(nh1s)*8.00635e-21
    s14slab_grid[*,3,i]=nh2s*2.0/(nh1s+nh2s*2.0)  
endfor

window,0,xsize=500,ysize=500
plot,[1],[1],xrange=[0.1,100],yrang=[1e-7,1e3],/xlog,/ylog,xstyle=1,ystyle=1
for i=0,99 do begin
    if  zm[i] gt 0.95 and zm[i] le 1.05 then begin
        oplot,s14comp_grid[*,2,i],s14comp_grid[*,1,i]
        oplot,s14slab_grid[*,2,i],s14slab_grid[*,1,i],color=cgcolor('red')
    endif
endfor

path=cgsourcedir()
datfile=path+'/a2m_s14_grid.dat'
s14_zm=zm

save,filename=datfile,s14comp_grid,s14slab_grid,s14_zm
    
END




PRO A2M_BR06_GRID

sigs=10.0^(findgen(1000)*0.01-2.)
br06_grid=fltarr(1000,4,n_elements(sigs))

for i=0,1000-1 do begin
    RMOL_HYDRO,nh1c,nh2c,v=8.0,h=300.,sigs=sigs[i]
    br06_grid[*,0,i]=(nh1c+nh2c*2.0)*8.00635e-21
    br06_grid[*,1,i]=(nh2c*2.0)*8.00635e-21
    br06_grid[*,2,i]=(nh1c)*8.00635e-21
    br06_grid[*,3,i]=nh2c*2.0/(nh1c+nh2c*2.0)
endfor

window,0,xsize=500,ysize=500
plot,[1],[1],xrange=[0.1,100],yrang=[1e-7,1e3],/xlog,/ylog,xstyle=1,ystyle=1
for i=0,1000-1 do begin
    oplot,br06_grid[*,2,i],br06_grid[*,1,i]
endfor

path=cgsourcedir()
datfile=path+'/a2m_br06_grid.dat'
br06_sigs=sigs

save,filename=datfile,br06_grid,br06_sigs
    
END

PRO A2M_GD14_GRID

zm=10.^(7.0+(9.5-7.0)*findgen(100)*0.01-8.69)
gd14_grid=fltarr(1000,4,n_elements(zm))
gd14x_grid=fltarr(1000,4,n_elements(zm))
for i=0,99 do begin
    GNEDIN,l=500,sig_h2=sig_h2,sig_h1=sig_h1,u=1.0,dgr_mw=zm[i]
    GNEDIN,l=500,sig_h2=sig_h2x,sig_h1=sig_h1x,u=10.0,dgr_mw=zm[i]
    gd14_grid[*,0,i]=(sig_h1+sig_h2)*1.67/2.3
    gd14_grid[*,1,i]=sig_h2*1.67/2.3
    gd14_grid[*,2,i]=sig_h1*1.67/2.3
    gd14_grid[*,3,i]=sig_h2/(sig_h2+sig_h1)
    gd14x_grid[*,0,i]=(sig_h1x+sig_h2x)*1.67/2.3
    gd14x_grid[*,1,i]=sig_h2x*1.67/2.3
    gd14x_grid[*,2,i]=sig_h1x*1.67/2.3
    gd14x_grid[*,3,i]=sig_h2x/(sig_h2x+sig_h1x)
endfor

window,0,xsize=500,ysize=500
plot,[1],[1],xrange=[0.1,100],yrang=[1e-7,1e3],/xlog,/ylog,xstyle=1,ystyle=1
for i=0,99 do begin
    oplot,gd14_grid[*,2,i],gd14_grid[*,1,i],color=cgcolor('blue')
    oplot,gd14x_grid[*,2,i],gd14x_grid[*,1,i],color=cgcolor('cyan')
endfor
oplot,[0.01,1000],[0.01,1000]*0.1,color=cgcolor('red'),thick=5

path=cgsourcedir()
datfile=path+'/a2m_gd14_grid.dat'
gd14_zm=zm
save,filename=datfile,gd14_grid,gd14x_grid,gd14_zm
    
END