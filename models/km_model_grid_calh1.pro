FUNCTION KM_MODEL_GRID_calh1,h2,zm,km_model_grid,km_model_grid_zm
;+
;speed up a little bit by going through the loop in this procedure.
;-
nh1=h2
for i=0,n_elements(zm)-1 do begin
  if h2[i] le 0.0 then begin
    nh1[i]=0.0
    continue
  endif
  if h2[i] ne h2[i] then begin
    nh1[i]=!values.f_nan
    continue
  endif
  
  tmp=min(abs(zm[i]-km_model_grid_zm),j)
  tmpnh2=km_model_grid[*,1,j]
  tmpnh1=km_model_grid[*,2,j]
  tmp=min(abs(tmpnh2-h2[i]),j)
  nh1[i]=tmpnh1[j]
endfor

return,nh1

END



