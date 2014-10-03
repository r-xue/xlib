FUNCTION A2M_MODELS_CALC,h2,zm,model=model
;+
;speed up a little bit by going through the loop in this procedure.
;-
;   use h2 to calculate H1 from models.
;-
;
;

COMMON a2m_models,$
    mk10_grid,mk10_zm,$
    mk10ph10_grid,mk10ph1_grid,$
    s14comp_grid,s14slab_grid,s14_zm,$
    br06_grid,br06_sigs,$
    gd14_grid,gd14x_grid,gd14_zm

if n_elements(h2) gt 1 and n_elements(zm) eq 1 then zm=replicate(zm,n_elements(h2))
if n_elements(h2) eq 1 and n_elements(zm) gt 1 then h2=replicate(h2,n_elements(zm))

if  model eq 'mk10' then begin    
    h1=h2
    for i=0,n_elements(zm)-1 do begin
        if  h2[i] le 0.0 then begin
            h1[i]=0.0
            continue
        endif
        if  h2[i] ne h2[i] then begin
            h1[i]=!values.f_nan
            continue
        endif
        tmp=min(abs(zm[i]-mk10_zm),j)
        h1[i]=INTERPOL(mk10_grid[*,2,j],mk10_grid[*,1,j],h2[i])
    endfor
endif

if  model eq 'mk10ph1' then begin
    h1=h2
    for i=0,n_elements(zm)-1 do begin
        if  h2[i] le 0.0 then begin
            h1[i]=0.0
            continue
        endif
        if  h2[i] ne h2[i] then begin
            h1[i]=!values.f_nan
            continue
        endif
        tmp=min(abs(zm[i]-mk10_zm),j)
        h1[i]=INTERPOL(mk10ph1_grid[*,2,j],mk10ph1_grid[*,1,j],h2[i])
    endfor
endif

if  model eq 'mk10ph10' then begin
    h1=h2
    for i=0,n_elements(zm)-1 do begin
        if  h2[i] le 0.0 then begin
            h1[i]=0.0
            continue
        endif
        if  h2[i] ne h2[i] then begin
            h1[i]=!values.f_nan
            continue
        endif
        tmp=min(abs(zm[i]-mk10_zm),j)
        h1[i]=INTERPOL(mk10ph10_grid[*,2,j],mk10ph10_grid[*,1,j],h2[i])
    endfor
endif

if  model eq 's14comp' then begin
    h1=h2
    for i=0,n_elements(zm)-1 do begin
        if  h2[i] le 0.0 then begin
            h1[i]=0.0
            continue
        endif
        if  h2[i] ne h2[i] then begin
            h1[i]=!values.f_nan
            continue
        endif
        tmp=min(abs(zm[i]-s14_zm),j)
        h1[i]=INTERPOL(s14comp_grid[*,2,j],s14comp_grid[*,1,j],h2[i],/spline)
    endfor
endif


if  model eq 's14slab' then begin
    h1=h2
    for i=0,n_elements(zm)-1 do begin
        if  h2[i] le 0.0 then begin
            h1[i]=0.0
            continue
        endif
        if  h2[i] ne h2[i] then begin
            h1[i]=!values.f_nan
            continue
        endif
        tmp=min(abs(zm[i]-s14_zm),j)
        h1[i]=INTERPOL(s14slab_grid[*,2,j],s14slab_grid[*,1,j],h2[i],/spline)
    endfor
endif


if  model eq 'br06' then begin
    h1=h2
    for i=0,n_elements(zm)-1 do begin
        if  h2[i] le 0.0 then begin
            h1[i]=0.0
            continue
        endif
        if  h2[i] ne h2[i] then begin
            h1[i]=!values.f_nan
            continue
        endif
        tmp=min(abs(zm[i]-br06_sigs),j)
        h1[i]=INTERPOL(br06_grid[*,2,j],br06_grid[*,1,j],h2[i],/spline)
    endfor
endif


if  model eq 'gd14' then begin
    h1=h2
    for i=0,n_elements(zm)-1 do begin
        if  h2[i] le 0.0 then begin
            h1[i]=0.0
            continue
        endif
        if  h2[i] ne h2[i] then begin
            h1[i]=!values.f_nan
            continue
        endif
        tmp=min(abs(zm[i]-gd14_zm),j)
        h1[i]=INTERPOL(gd14_grid[*,2,j],gd14_grid[*,1,j],h2[i],/spline)
    endfor
endif

if  model eq 'gd14x' then begin
    h1=h2
    for i=0,n_elements(zm)-1 do begin
        if  h2[i] le 0.0 then begin
            h1[i]=0.0
            continue
        endif
        if  h2[i] ne h2[i] then begin
            h1[i]=!values.f_nan
            continue
        endif
        tmp=min(abs(zm[i]-gd14_zm),j)
        h1[i]=INTERPOL(gd14x_grid[*,2,j],gd14x_grid[*,1,j],h2[i],/spline)
    endfor
endif

return,h1

END




