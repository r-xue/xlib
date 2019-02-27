PRO SAMPLE_GRID,$
    ctr,spacing,ratio=ratio,ang=ang,$
    r_limit=r_limit,$
    x_limit=x_limit,$
    y_limit=y_limit,$
    r=r,$
    radec=radec,$
    hex=hex,$
    xout=xout,yout=yout
;+
; NAME:
;   SAMPLE_GRID
;
; PURPOSE:
;   generate x/y-positions of sampling points based on a squard or hex grid
;   (replacing hex_grid.pro, written by A. Leroy)
;   useful to pick up independent pixels from an oversampling image... 
;
; INPUTS:
;   CTR         grid center position
;   SPACING     grid sampling spacing, in units of CTR values
;               (=cell size for squard gridding, =center offset for hex gridding)
;   
;   [ratio]     we compress the X-AXIS coordinate by this ratio (before rotation)
;   [ang]       CCW degree; rotate the sampling point grid (after x-axis compression)
;               by combing [ang]/[ratio], an iregular hexgon sampling can be achieved. 
;
;   [r_limit]   radius limit for the sampling grid, in units of CTR values
;               radius limit >= distance from a sampling to the grid center
;   [x_limit]   2-element vector, x position limit, x_limit[0]<=xout<=x_limit[1], in units of CTR values
;   [y_limit]   2-element vector, y position limit, y_limit[0]<=yout<=y_limit[1], in units of CTR values
;   [r]         initialized grid size (in number of data points), usually a large number
;               default: 1000
;   
; KEYWORDS:
;   RADEC       x&y positions are in RA/DEC, so d(RA)=d(offset)/cos(DEC)
;   HEX         hex gridding (default: squard gridding)                   
;   
; OUTPUTS:
;   xout        X positions of sampling points
;   yout        y positions of sampling points 
;
;
; HISTORY:
;
;   20130409  RX  introduced

if n_elements(r) eq 0 then r=200.0

; MAKE THE SAMPLING GRID CENTERED AT [0,0] 
if keyword_set(hex) then begin
  xvec=findgen(2*r+1)-r
  yvec=findgen(2*r+1)-r
  make_2d,xvec,yvec,xout,yout
  xout=(xout+0.5*(abs(yout) mod 2))*spacing
  yout=yout*spacing*sin(!dtor*60)
endif else begin
  xyvec=(findgen(2*r+1)-r)*spacing
  make_2d,xyvec,xyvec,xout,yout
endelse

keep=xout-xout+1.0

if n_elements(r_limit) ne 0 then begin
  dist=(xout^2.+yout^2.)^0.5
  keep[where(dist gt r_limit,/null)]=0.0
endif

if  n_elements(ratio) eq 1 then xout=xout/ratio



if  n_elements(ang) eq 1 then begin
    rotate_xy,xout,yout,ang,0.0,0.0,xout1,yout1,/degree
    xout=xout1
    yout=yout1
endif

yout=yout+ctr[1]
if keyword_set(radec) then $
  xout=xout/cos(!dtor*yout)+ctr[0] $
else $
  xout=xout+ctr[0]

if n_elements(x_limit) eq 2 then keep[where(xout lt x_limit[0] or xout gt x_limit[1],/null)]=0.0
if n_elements(y_limit) eq 2 then keep[where(yout lt y_limit[0] or yout gt y_limit[1],/null)]=0.0

xout=xout[where(keep eq 1.0,/null)]
yout=yout[where(keep eq 1.0,/null)]


END

PRO TEST_SAMPLE_GRID

    xl=[-3.0,3.0]
    yl=[-3.0,3.0]
    ang=60.0
    sample_grid,[mean(xl),mean(yl)],0.5*sqrt(3.),xout=xout,yout=yout,/hex,$
        r_limit=40,ratio=1.0/0.6,ang=ang
    window,1,xsize=600,ysize=600

    plot,xout,yout,psym=3,$
        xrange=xl,$
        yrange=yl,$
        xstyle=1,ystyle=1,/nodata


    oplot,xout,yout,psym=3
    for i=0,n_elements(xout)-1 do begin
        tvellipse,0.5*sqrt(3)/2.0*0.6,0.5*sqrt(3)/2.0,xout[i],yout[i],ang,/data,color=cgcolor('red')
    endfor

END


PRO TEST4_SAMPLE_GRID

ctr=[60,45]
sample_grid,ctr,10.0,xout=xout,yout=yout,/hex,$
 r_limit=40,/radec
 ;x_limit=[-49,49],y_limit=[-49,49],
window,1,xsize=600,ysize=600
plot,xout,yout,psym=3,$
  xrange=[ctr[0]-160,ctr[0]+160],$
  yrange=[ctr[1]-160,ctr[1]+160],$
  xstyle=1,ystyle=1
oplot,[ctr[0]],[ctr[1]],psym=2
;oplot,[ctr[0],ctr[0]],[ctr[1]-160,ctr[1]+160],linestyle=2
;oplot,[ctr[1]-160,ctr[1]+160],[ctr[1],ctr[1]],linestyle=2

hex_grid,ctr_x=ctr[0],ctr_y=ctr[1],spacing=10.0,xout=xout,yout=yout,r_limit=40,/radec
oplot,xout,yout,psym=symcat(9),symsize=2.0

END

PRO TEST2_SAMPLE_GRID


xl=[219,215]
yl=[32,36]
ctr=[60,45]
sample_grid,[mean(xl),mean(yl)],0.5*sqrt(3.),xout=xout,yout=yout,/hex,$
    r_limit=40
;x_limit=[-49,49],y_limit=[-49,49],
window,1,xsize=600,ysize=600
rotate_xy, xout, yout, 30, mean(xl), mean(yl), x2, y2
plot,x2,y2,psym=3,$
    xrange=xl,$
    yrange=yl,$
    xstyle=1,ystyle=1
tvcircle,0.5,x2,y2,/data
oplot,[ctr[0]],[ctr[1]],psym=2
oplot,[ctr[0],ctr[0]],[ctr[1]-160,ctr[1]+160],linestyle=2
oplot,[ctr[1]-160,ctr[1]+160],[ctr[1],ctr[1]],linestyle=2

;hex_grid,ctr_x=ctr[0],ctr_y=ctr[1],spacing=10.0,xout=xout,yout=yout,r_limit=40,/radec
;oplot,xout,yout,psym=symcat(9),symsize=2.0

END




PRO TESTTMP_SAMPLE_GRID

xl=[-3.0,3.0]
yl=[-3.0,3.0]
sample_grid,[mean(xl),mean(yl)],0.5*sqrt(3.),xout=xout,yout=yout,/hex,$
     r_limit=40
    ;x_limit=[-49,49],y_limit=[-49,49],
    window,1,xsize=600,ysize=600
    
    rotate_xy, xout, yout, 15, 0, 0, xout1, yout1,/degree
    xout=xout1
    yout=yout1
    
    xout=xout*0.6
    yout=yout
    rotate_xy, xout, yout, 30, 0, 0, x2, y2,/degree
    ;x2=xout
    ;y2=yout
    plot,x2,y2,psym=3,$
        xrange=xl,$
        yrange=yl,$
        xstyle=1,ystyle=1,/nodata
    ;tvcircle,0.5,x2,y2,/data,color=cgcolor('red')
    ;tvcircle,0.5*sqrt(3)/2.0,x2,y2,/data,color=cgcolor('red')
    
    oplot,x2,y2,psym=3
    for i=0,n_elements(x2)-1 do begin
        tvellipse,0.5*sqrt(3)/2.0*0.6,0.5*sqrt(3)/2.0,x2[i],y2[i],30,/data,color=cgcolor('red')
    endfor
    ;
    ;for i=0,n_elements(x2)-1 do begin
    ;    tvellipse,0.5*sqrt(4)/2.0*0.2,0.5*sqrt(4)/2.0,x2[i]*0.2,y2[i],0,/data,color=cgcolor('red')
    ;endfor    
    
    ;oplot,[ctr[0]],[ctr[1]],psym=2
    ;oplot,[ctr[0],ctr[0]],[ctr[1]-160,ctr[1]+160],linestyle=2
    ;oplot,[ctr[1]-160,ctr[1]+160],[ctr[1],ctr[1]],linestyle=2

    ;hex_grid,ctr_x=ctr[0],ctr_y=ctr[1],spacing=10.0,xout=xout,yout=yout,r_limit=40,/radec
    ;oplot,xout,yout,psym=symcat(9),symsize=2.0

END

    
