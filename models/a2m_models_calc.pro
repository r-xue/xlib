PRO TEST_A2M_MODELS_CALC

    COMMON a2m_models,$
        mk10_grid,mk10_zm,$
        mk10ph10_grid,mk10ph1_grid,$
        s14comp_grid,s14slab_grid,s14_zm,$
        br06_grid,br06_sigs,$
        gd14_grid,gd14x_grid,gd14_zm

    ;tmp=min(abs(zm[i]-mk10_zm),j)
    ;h1[i]=INTERPOL(mk10_grid[*,2,j],mk10_grid[*,1,j],h2[i])
    x=[]
    y=[]
    z=[]
    f=[]
    ;print,mk10_zm
    for i=0,n_elements(mk10_zm)-1 do begin
        x=[x,mk10_grid[*,1,i]]
        f=[f,mk10_grid[*,2,i]]
        z=[z,replicate(3.0,n_elements(mk10_grid[*,1,i]))]
        y=[y,replicate(alog10(mk10_zm[i])+8.76,n_elements(mk10_grid[*,1,i]))]
    endfor
    for i=0,n_elements(mk10_zm)-1 do begin
        x=[x,mk10ph10_grid[*,1,i]]
        f=[f,mk10ph10_grid[*,2,i]]
        z=[z,replicate(10.0,n_elements(mk10ph10_grid[*,1,i]))]
        y=[y,replicate(alog10(mk10_zm[i])+8.76,n_elements(mk10ph10_grid[*,1,i]))]
    endfor
    for i=0,n_elements(mk10_zm)-1 do begin
        x=[x,mk10ph1_grid[*,1,i]]
        f=[f,mk10ph1_grid[*,2,i]]
        z=[z,replicate(1.0,n_elements(mk10ph1_grid[*,1,i]))]
        y=[y,replicate(alog10(mk10_zm[i])+8.76,n_elements(mk10ph1_grid[*,1,i]))]
    endfor
    QHULL, x, y, z, tet, /DELAUNAY
    volume = QGRID3(x, y, z, f, tet, START=[2.,8.75,3.], DIMENSION=[2,2,2], DELTA=0.02)
    print,volume[0,0,0]
    print,a2m_models_calc(2.,oh2z(8.76),model='mk10')
    
;    TRIANGULATE, x, y, tr
;    h2=0.01
;    zm=8.502
;    coi4_interp=GRIDDATA(x, y, z,$
;        DIMENSION=[1,1],DELTA=[0,0],START=[1.0,zm],$
;        method='NaturalNeighbor',Triangles=tr)    
;    print,a2m_models_calc(h2,oh2z(zm),model='mk10')
;    print,coi4_interp    
    ;p=plot3d(x,y,z,'o',yrange=[7.0,9.5])
END


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




