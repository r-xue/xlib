PRO VIS3D_OBJ,filename


    ; load the cube with a stretched density scale
    cube=readfits(filename,hd)
    print, min(cube), max(cube)
    
    ; convert to the original density in Fabian's file
    cube=cube>0.0
    cube=cube*10/max(cube)
    
    win = OBJ_NEW('IDLgrWindow', DIMENSIONS=[600, 600])
    view = OBJ_NEW('IDLgrView', VIEWPLANE_RECT=[-1, -1, 2, 2], $
        ZCLIP=[2.0, -2.0], COLOR=[200,200,0])
    model = OBJ_NEW('IDLgrModel')
    
    vol= OBJ_NEW('IDLgrVolume', cube)
    vol -> SetProperty, ZERO_OPACITY_SKIP=1
    vol -> SetProperty, ZBUFFER=1
    cc = [-0.5, 1.0/float(256)]
    vol -> SetProperty, XCOORD_CONV=cc, YCOORD_CONV=cc, ZCOORD_CONV=cc*20
    
    loadct,11
    TVLCT, savedR, savedG, savedB, /GET
    colorTable = [[savedR],[savedG],[savedB]]
    vol -> SetProperty, RGB_TABLE0=colorTable
    
    ;cb = Obj_New('VColorBar'color=,$
    ;           range=[min(cube),max(cube)])
    ;cb -> SetProperty, color=11
    
    model -> Add, vol
    model -> Rotate, [1, 1, 1], 45
    
    view -> Add, model
    ;view -> Add, cb
    win -> Draw,view
    
    ; an alternative way to view the IDLgrVolume object
    xobjview,model
    
END


PRO VIS3D1

cube=readfits('smc.hi.cm.fits',hd)
print, min(cube), max(cube)
abs=readfits('smc.hiabs.cm.fits',hd)
; convert to the original density in Fabian's file

abs=abs>0
abs[where(abs ne abs)]=0.0
print,min(abs,/nan),max(abs,/nan)
cube=fix(cube/max(cube,/nan)*10.)
cube[where(cube le 1)]=0

nxyz=size(cube,/d)
rd_hd,hd,str=str
x=findgen(nxyz[0])
y=findgen(nxyz[0])
z=str.v

graphic=volume(cube,$
    HINTS = 3, /AUTO_RENDER, $
    RGB_TABLE0=15,$
    RENDER_QUALITY=2,$
    COMPOSITE_FUNCTION=1,$
    ztitle='VHEL',$
    xtitle='d R.A.',$
    ytitle='d Dec.')

    graphic=volume(abs,$
        HINTS = 3, /AUTO_RENDER, $
        RGB_TABLE0=13,$
        RENDER_QUALITY=2,$
        COMPOSITE_FUNCTION=1,/overplot)
        
END


PRO VIS3D2,filename

    ; load the cube with a stretched density scale
    cube=readfits(filename,hd)
    print, min(cube), max(cube)
    cube=cube>0
    ; convert to the original density in Fabian's file
    cube=0.3+(cube-1.0)*(300.-0.3)/4999.
    
    ivolume,cube,$
        INSERT_COLORBAR=[[-0.5,-1],[0,-2]],$
        RGB_TABLE0=11,$
        xtitle='x',$
        ytitle='y',$
        ztitle='z',$
        /auto_render,$
        render_quality=2,$
        composite_function=0,$
        dimensions=[600,600]
        
END