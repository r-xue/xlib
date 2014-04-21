PRO MAKEMOMPV_PL,prefix


im=prefix+'.mom0.fits'
imxv=prefix+'.mom0xv.fits'
imvy=prefix+'.mom0vy.fits'

im=readfits(im,imhd)
imxv=readfits(imxv,imxvhd)
imvy=readfits(imvy,imvyhd)
nvec=(size(imvy))[1]
vec=(sxpar(imvyhd,'CRVAL1')+(findgen(nvec)+1-sxpar(imvyhd,'CRPIX1'))*sxpar(imvyhd,'CDELT1'))/1000.0

set_plot, 'ps'
device, filename=prefix+'.mom0pv.eps', $
    bits_per_pixel=8,/encapsulated,$
    xsize=10,ysize=10,/inches,/col,xoffset=0,yoffset=0,/cmyk

    !p.thick=2.0
    !x.thick = 2.0
    !y.thick = 2.0
    !z.thick = 2.0
    !p.charsize=1.5
    !p.charthick=1.5
    
pos=[0.1,0.1,0.7,0.7]
cgloadct,0,/rev
cgloadct,13
cgimage,im,pos=pos,stretch=1,/noe,/keep
cgloadct,0
cgloadct,11,/rev
tmp=im & tmp[1]=0 & tmp[0]=1. 
imcontour_rdgrid,tmp,imhd,nlevels=4,c_lab=0,$
    /noe,pos=pos,/nodata,axes=axes,color='red',AXISCOLOR='red'

subpos=[pos[0],pos[3]+0.01,pos[2],pos[3]+0.26]    
cgloadct,0,/rev
cgloadct,13
cgimage,imxv,pos=subpos,stretch=1,/noe,minvalue=0.0
cgloadct,0
cgloadct,11,/rev
plot,axes.xrange,[min(vec),max(vec)],/nodata,/noe,pos=subpos,$
    xtickformat='notickname',xstyle=1,ystyle=1,$
    xticks=axes.xticks,xtickv=axes.xtickv,xtickname=axes.xtickname,xminor=axes.xminor,$
    ytitle='Velocity [km/s]'

subpos=[pos[2]+0.01,pos[1],pos[2]+0.26,pos[3]] 
cgloadct,0,/rev
cgloadct,13
cgimage,imvy,pos=subpos,stretch=1,/noe,minvalue=0.0
cgloadct,0
cgloadct,11,/rev
plot,[min(vec),max(vec)],axes.yrange,/nodata,/noe,pos=subpos,$
    ytickformat='notickname',xstyle=1,ystyle=1,$
    yticks=axes.yticks,ytickv=axes.ytickv,ytickname=axes.ytickname,yminor=axes.yminor,$
    xtickformat='(A1)',xtick_get=tickvalues
    numticks=n_elements(tickvalues)


ypos=replicate(!Y.Window[0]-0.04, numticks)
xpos=convert_coord(tickvalues,replicate(0,numticks),/data,/to_normal)
xpos=xpos[0,*];-!D.Y_CH_SIZE
xyouts,0,0,' ',width=stw1
for j=0,numTicks-1 DO $
xyouts,xpos[j]-stw1/2.0, ypos[j], string(tickvalues[j],format='(i0)'), ali=0.5, ori=-90, /Normal,$
width=stw
;print,stw
xyouts,(!x.window(0)+!x.window(1))/2,ypos[0]-stw,'Velocity [km/s]',ali=0.5,/normal
device, /close
set_plot,'X'
    
    
END