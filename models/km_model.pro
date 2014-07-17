; This function will calculation the predicted molecular fraction
; for a given pair of metalicity z' and total H column density
; 
; KM's Z' definition:
;   log Z′ = [log(O/H) + 12] − 8.76.
; 
;

; u= 1.27 or 1.39 (2.34/1.67372) being the mean molecular weight per particle
function km_model,xmodel,metal,phi
;phi=3->10
; xmodel is the surface density of Sigma H total
  zm=metal
  tauc=0.093563*xmodel*zm
  kai=3.1/phi*3*(1+3.1*zm^0.365)/4.1
  s=alog(1+0.6*kai+0.01*kai^2.0)/0.6/tauc
  fh2_mckee=1.0-(3.0/4.0)*s/(1+0.25*s)
  tag0=where(fh2_mckee le 0.000001)
  if tag0[0] ne -1 then begin
    fh2_mckee(tag0)=0.00
  endif  
  return, fh2_mckee
End

PRO KM_MODEL_GRID

x_model = FINDGEN(100000)*0.01+0.1
zm=10.^(7.0+(9.5-7.0)*findgen(100)*0.01-8.69)
km_model_grid=fltarr(n_elements(x_model),4,n_elements(zm))
for i=0,99 do begin
  f=km_model(x_model,zm[i],3.0)
  km_model_grid[*,0,i]=x_model          ;
  km_model_grid[*,1,i]=x_model*f        ;h2
  km_model_grid[*,2,i]=x_model*(1-f)    ;hi
  km_model_grid[*,3,i]=f                ;h2 mass faraction
endfor

window,0,xsize=500,ysize=500
plot,[1],[1],xrange=[0.1,100],yrang=[0.1,1000],/xlog,/ylog
for i=0,99 do begin
  oplot,km_model_grid[*,2,i],km_model_grid[*,1,i]
endfor

path=ProgramRootDir()
datfile=path+'/km_model_grid.dat'
km_model_grid_zm=zm

save,filename=datfile,km_model_grid,km_model_grid_zm
END