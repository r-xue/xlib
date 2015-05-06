PRO TEST_PLOTIMAGE
;+
;   pg_plotimage (PG) works better than plotimage.pro (CM)
;   but neither methods offer pixel rotation / stretch.
;-
fig='test_plotimage'
set_plot, 'ps'
device, filename=fig+'.eps', $
    bits_per_pixel=8,/encapsulated,$
    xsize=10,ysize=3,/inches,/col,xoffset=0,yoffset=0,/cmyk

loadct,5

im=cgimgscl(randomu(seed,10,10),str=1.0)
x=findgen(10)
y=findgen(10)
pos=pos_mp(0,[3,1],[0.01,0.01],[0.1,0.1])
cgloadct,0
pg_plotimage,im,x,y,xrange=[0,9],yrange=[0,9],/xstyle,/ystyle,$
    fulledges=0,pos=pos.position,color='black',$
    axiscolor='black'

; PLOTIMAGE IS GOOD FOR PLOTTING IM SMALLER THAN COORDS
; IF IM LARGER THAN COORDS, BETTWER USE WITHOUT XRANGE YRANGE
; PLOTIMAGE IS NOT GOOD FOR PLOTTING HALF PIXEL
pos=pos_mp(1,[3,1],[0.01,0.01],[0.1,0.1])
cgloadct,0
plotimage,BYTSCL(im),$
    imgx=[-0.5,9.5],imgy=[-0.5,9.5],$
    xrange=[0.0,9],yrange=[0.0,9],$
    /xstyle,/ystyle,$
    pos=pos.position,/noe,$
    min_dpi=100.0

pos=pos_mp(2,[3,1],[0.01,0.01],[0.1,0.1])
cgloadct,0
plotimage,BYTSCL(im),$
    imgx=[-0.5,9.5],imgy=[-0.5,9.5],$
    ;xrange=[0.0,9],yrange=[0.0,9],$
    /xstyle,/ystyle,$
    pos=pos.position,/noe
    
device, /close
set_plot,'X'

END

