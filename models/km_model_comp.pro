PRO KM_MODEL_COMP

; this procedure is used to test different "versions" of the KMT model
;    
  path=ProgramRootDir()
  readcol,path+'/data/kmt_sol1.txt',sol1_x,sol1_y
  readcol,path+'/data/kmt_sol2.txt',sol2_x,sol2_y
  readcol,path+'/data/kmt_sol2s.txt',sol2s_x,sol2s_y
  readcol,path+'/data/kmt_sol3.txt',sol3_x,sol3_y
  
  
  set_plot, 'ps'
  device, filename='km_model_comp.eps', $
    bits_per_pixel=8,/encapsulated,$
    xsize=8,ysize=8,/inches,/col,xoffset=0,yoffset=0,/cmyk
  
  !p.thick=2.0
  !x.thick = 2.0
  !y.thick = 2.0
  !z.thick = 2.0
  !p.charsize=1.5
  !p.charthick=2.0
  
  pos=pos_mp(0,[1,2],[0.1,0.1,0.1,0.1],[0.02,0.02,0.01,0.02])
  plot,sol1_x,sol1_y,/xlog,/nodata,pos=pos.position,$
    xrange=[1e-2,1e5],$
    yrange=[1e-2,30.],/noe,xstyle=1,ystyle=1,$
    xtitle=textoidl("\Sigma_{H2}")+" [!6M!d!9n!6!n pc!u-2!n]",$
    ytitle=textoidl("\Sigma_{HI}")+" [!6M!d!9n!6!n pc!u-2!n]"
    
    linethick=5
  oplot,sol1_x>1e-2,sol1_y,color=cgcolor('black'),thick=linethick
  oplot,sol2_x>1e-2,sol2_y,color=cgcolor('green'),thick=linethick
  oplot,sol2s_x>1e-2,sol2s_y,color=cgcolor('yellow'),thick=linethick
  oplot,sol3_x>1e-2,sol3_y,color=cgcolor('blue'),thick=linethick
  
  al_legend,['Sol1  [KMT09,Lee12]','Sol2  [KMT09,smooth1]','Sol2s [KMT09,smooth2]','Sol3  [MK10]'],linestyle=[0,0,0,0],$
    color=['black','green','yellow','blue'],thick=5,charsize=1.0
    
  
  pos=pos_mp(1,[1,2],[0.1,0.1,0.1,0.1],[0.02,0.02,0.01,0.02])
  plot,(sol1_x+sol1_y),sol1_x/(sol1_x+sol1_y),/xlog,/nodata,pos=pos.position,$
    xrange=[1e-2,1e5],$
    yrange=[0,1],/noe,xstyle=1,ystyle=1,$
    xtitle=textoidl("\Sigma_{H}")+" [!6M!d!9n!6!n pc!u-2!n]",$
    ytitle=textoidl("f_{mol}")
  oplot,(sol1_x+sol1_y),sol1_x/(sol1_x+sol1_y),color=cgcolor('black'),thick=linethick
  oplot,(sol2_x+sol2_y),sol2_x/(sol2_x+sol2_y),color=cgcolor('green'),thick=linethick
  oplot,(sol2s_x+sol2s_y),sol2s_x/(sol2s_x+sol2s_y),color=cgcolor('yellow'),thick=linethick
  oplot,(sol3_x+sol3_y),sol3_x/(sol3_x+sol3_y),color=cgcolor('blue'),thick=linethick
  
  
  
  al_legend,['Sol1  [KMT09,Lee12]','Sol2  [KMT09,smooth1]','Sol2s [KMT09,smooth2]','Sol3  [MK10]'],linestyle=[0,0,0,0],$
    color=['black','green','yellow','blue'],thick=5,charsize=1.0
  device, /close
  set_plot,'X'
  

  
END