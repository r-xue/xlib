PRO MAP_FITS,IM,$
    HD=HD,radec=radec,arcmin=arcmin,$
    largemap=largemap,$
    xc=xc,yc=yc,zc=zc,$
    noplot=noplot,$
    _extra=extra
    
;+
; NAME:
;   map_fits
;
; PURPOSE:
;   plot a fits image in a specified region
;   Each pixel is plotted as a polygon with the vertices position calculate in the astronomical fame.
;
; INPUTS:
;   IM          data image
;   HD          data hd
;   RADEC       projection center of the mapping region
;   ARCMIN      units for dx-dy mapping 
;   NOPLOT position   plott position
;   _EXTRA      any keywords for cgimgscl
;
; OUTPUTS:
;   xc          pixel center position
;   xc          pixel center position
;   zc          pixel values
;   
; KEYWORD:
;   largemap    if the map is large enough, we use cgcolorfill to reduce the file size
;   noplot      for testing
;
; OUTPUTS:
;   SUBRANGE    [xmin,xmax,ymin,ymax]
;               index range (defined in IM) of the smallest rectangle covering
;               the plotted region
;   SUBIM       a cutoff from IM just large enough to cover the plotted region
;   DUMMY       a template from refhd
;
; HISTORY:
;
;   20120701  RX  introduced
;   20131019  RX  performace enhancement
;                 rename it to disp_fits.pro
;   20150419  RX  performace enhancement
;                 fix the "no-overlap" conditon
;                 don't plot blank pixels
;                 rename it to map_fits.pro

sim=cgimgscl(im,_extra=extra)
nxy=size(sim,/d)
nn=nxy[0]*nxy[1]
make_2d,findgen(nxy[0]),findgen(nxy[1]),xx,yy
xx=reform(xx,nn,/over)
yy=reform(yy,nn,/over)
tag=where(im eq im)

if  tag[0] ne -1 then begin
    nn=n_elements(tag)
    xx=xx[tag]
    yy=yy[tag]
    sim=sim[tag]
    zc=im[tag]
    
    if  n_elements(hd) ne 0 then begin
        map_ad,hd,$
            bx,by,$
            x=[[xx-0.5],[xx+0.5],[xx+0.5],[xx-0.5]],$
            y=[[yy-0.5],[yy-0.5],[yy+0.5],[yy+0.5]],$
            radec=radec,arcmin=arcmin,_extra=extra
    endif else begin
        bx=xx
        by=yy
    endelse
    
    for i=0,nn-1 do begin
        if  keyword_set(noplot) then continue
        tempx=[(bx[i,*])[*],bx[i,0]]
        tempy=[(by[i,*])[*],by[i,0]]
        if  keyword_set(largemap) then begin
            cgcolorfill,tempx,tempy,color=sim[i],noclip=0
        endif else begin
            cgpolygon,tempx,tempy,color=sim[i],noclip=0,/fill
        endelse
    endfor
    print,replicate('-',25)
    print,'image size:     ',size(im,/d)
    print,'pixel number:   ',nn
    print,replicate('-',25)
endif

END


PRO TEST_MAP_FITS_LMC_PATCH
    
im=readfits('/Users/Rui/Workspace/magclouds/magmap/lmc_v9.co.vbin.sgm.mom0_roi14.fits',hd)
ra=85.61
dec=-71.34
;ra=0.0
;dec=0.0

set_plot, 'ps'
device, filename='test.eps', $
    bits_per_pixel=8,/encapsulated,$
    xsize=10,ysize=7,/inches,/col,xoffset=0,yoffset=0,/cmyk
!p.thick=2.0
!x.thick = 2.0
!y.thick = 2.0
!z.thick = 2.0
!p.charsize=1.0
!p.charthick=2.0

pos=[0.2,0.2,0.8,0.8]

cgloadct,0
plot,[0],[0],xrange=[300,-300]/60.0,yrange=[-400,400]/60.0,xstyle=1,ystyle=1,/nodata,pos=pos

cgloadct,3,/rev
map_fits,im,hd=hd,radec=[ra,dec],stretch=5,/arcmin,xc=xc,yc=yc,zc=zc,minvalue=-1
map_boundary,(im eq im),hd=hd,color=cgcolor('gray'),thick=5,outline=1,edge=1,$
    radec=[ra,dec],/arcmin,linestyle=0,noclip=1
map_ad,hd,xc,yc,radec=[ra,dec],/arcmin
cgcontour,im,xc,yc,/overplot,/IRREGULAR,label=0,fill=0,cell=0,resolution=[50,50],outline=1
cgcontour,im,xc,yc,lev=[-10.],/irreg,/over

cgloadct,0
plot,[0],[0],xrange=[300,-300]/60.0,yrange=[-400,400]/60.0,xstyle=1,ystyle=1,/nodata,pos=pos,/noe

device, /close
set_plot,'X'
cgps2pdf,'test.eps', delete_ps=0,unix_convert_cmd='epstopdf'

;    oROI=OBJ_NEW('IDLanROI', TYPE=2)
;    oROI->AppendData,bxs,bys
;    draw_roi,oroi,color=sim[i],noclip=0
;    obj_destroy,oroi
;obj_roi=obj_new('IDLanROI',xbox,ybox)
;tag_roi=obj_roi->containspoints(bx[*,0],by[*,0])+$
;        obj_roi->containspoints(bx[*,1],by[*,1])+$
;        obj_roi->containspoints(bx[*,2],by[*,2])+$
;        obj_roi->containspoints(bx[*,3],by[*,3])
;obj_destroy,obj_roi
;tag_roi=where(tag_roi ne 0)

END

PRO TEST_MAP_FITS_SMALL

set_plot, 'ps'
device, filename='test.eps', $
    bits_per_pixel=8,/encapsulated,$
    xsize=2,ysize=2,/inches,/col,xoffset=0,yoffset=0
!p.thick=2.0
!x.thick = 2.0
!y.thick = 2.0
!z.thick = 2.0
!p.charsize=1.0
!p.charthick=2.0

plot,[0],[0],/nodata,xstyle=1,ystyle=1,$
    pos=[0.1,0.1,0.9,0.9],$
    xrange=[5,-5],yrange=[-5.,5.],/noe

;plot,[218,217],[32,33],/nodata,xstyle=1,ystyle=1,$
;    pos=[0.1,0.1,0.9,0.9]    
im=readfits('/Users/Rui/Workspace/highz/products/mosaic/stack_I_all.fits',hd)
x=tenv('14:31:06.041')*15.
y=tenv('32:30:11.12')
hextractx,im,hd,subim,subhd,[5.,-5.],[-5.,5.],radec=[x,y]
map_fits,subim,hd=subhd,stretch=5,radec=[x,y]

plot,[0],[0],/nodata,xstyle=1,ystyle=1,$
    pos=[0.1,0.1,0.9,0.9],$
    xrange=[5,-5],yrange=[-5.,5.],/noe
    
device, /close
set_plot,'X'
cgps2pdf,'test.eps', delete_ps=0,unix_convert_cmd='epstopdf'

END

PRO TEST_MAP_FITS_LMC

im=readfits('/Users/Rui/Workspace/magclouds/gasmap/lmc.co_magma_hiref.cm.sm.mom0.fits',hd)

set_plot, 'ps'
device, filename='test.eps', $
    bits_per_pixel=8,/encapsulated,$
    xsize=10,ysize=7,/inches,/col,xoffset=0,yoffset=0,/cmyk
!p.thick=2.0
!x.thick = 2.0
!y.thick = 2.0
!z.thick = 2.0
!p.charsize=1.0
!p.charthick=2.0


pos=[0.2,0.2,0.8,0.8]
xrange=[91,65]
yrange=[-72,-64]
cgloadct,0
plot,[0],[0],xrange=xrange,yrange=yrange,xstyle=1,ystyle=1,/nodata,pos=pos,/noe
cgloadct,3,/rev
hextractx,im,hd,subim,subhd,xrange,yrange
map_fits,subim,hd=subhd,stretch=5,minvalue=-1,/largemap
cgloadct,0
plot,[0],[0],xrange=xrange,yrange=yrange,xstyle=1,ystyle=1,/nodata,pos=pos,/noe
device, /close
set_plot,'X'

cgps2pdf,'test.eps', /delete_ps,unix_convert_cmd='epstopdf'

END

PRO TEST_MAP_FITS_LMC2

im=readfits('/Users/Rui/Workspace/magclouds/gasmap/lmc.co_magma_hiref.cm.sm.mom0.fits',hd)

set_plot, 'ps'
device, filename='test.eps', $
    bits_per_pixel=8,/encapsulated,$
    xsize=4,ysize=8,/inches,/col,xoffset=0,yoffset=0,/cmyk
!p.thick=2.0
!x.thick = 2.0
!y.thick = 2.0
!z.thick = 2.0
!p.charsize=1.0
!p.charthick=2.0

subim=im
subhd=hd

xrange=[91,65]
yrange=[-72,-64]

xrange=[70,90]
yrange=[-80,-60]
position = [0.1, 0.52, 0.9, 0.9]

cgMap_Set,-69,80, /Azimuthal, /NoErase, NoBorder=0, /Reverse, $
    Scale=8e6,Position=position;,/grid
cgloadct,0
cgloadct,3,/rev
map_fits,subim,hd=subhd,stretch=5,minvalue=-1
cgloadct,0
cgMAP_GRIDX,LABEL=1,box=1
cgMap_Set,-69,80, /Azimuthal, /NoErase, NoBorder=0, /Reverse, $
    Scale=8e6,Position=position;,/grid


;latmin = Min(yrange, MAX=latmax)
;lonmin = Min(xrange, MAX=lonmax)
;centerLat = (latmax - latmin) / 2.0 + latmin
;centerLon = (lonmax - lonmin) / 2.0 + lonmin
;limit = [latmin, lonmin, latmax, lonmax]
;    
;position = [0.1, 0.02, 0.9, 0.50]
;map=obj_new('cgMap','Hammer',CENTER_LATITUDE=-70, CENTER_LONGITUDE=75,grid=1,label=1)
;bx=[xrange[0],xrange[1],xrange[0],xrange[1]]
;by=[yrange[1],yrange[0],yrange[0],yrange[1]]
;uv=map->forward(bx,by)
;print,uv
;print,'--'
;print,uv[[0,2]]
;print,uv[[1,3]]
;xrange=[min([uv[0,1],uv[0,2]]),max([uv[0,1],uv[0,2]])]
;yrange=[min([uv[1,0],uv[1,1]]),max([uv[1,0],uv[1,1]])]
;print,xrange,yrange
;map->SetProperty, XRANGE=xrange, YRANGE=yrange,POSITION=posistion
;map->draw
;cgplots,75,-70,map=map,psym=symcat(16)
;cgmap_gridx,label=1,color=0,box=0,map=map

device, /close
set_plot,'X'


END


