PRO VIS3D_MOV_DEMO

fig=strlowcase(cgWhoAmI())

ra = RandomU(seed, 32)-0.5
dec = RandomU(seed, 32)-0.5
z = Exp(-3 * ((ra - 0.5)^2 + (dec - 0.5)^2))+3.75

;ra->x-axis
;dec->z-axis
;z->y-axis

; 3d scatter plot
s=plot3d(ra,z,dec,' o',$
    xrange=0.5*[1,-1],yrange=[2.75,+4.75],zrange=0.5*[-1,1],/buffer,$
    SYM_OBJECT=ORB(),/SYM_FILLED,$
    AXIS_STYLE=2,perspective=0,$
    ;MARGIN=[0.1, 0.1, 0.1, 0.1],$
    ;ASPECT_RATIO=1.,ASPECT_Z=1.,$
    XMINOR=0, YMINOR=0, ZMINOR=0,$
    xtitle='d(RA)',ytitle='Spec-Z',ztitle='d(Dec)',position=[0.25,0.25,0.75,0.75],$
    XY_SHADOW=0,$
    dimensions=[1024,1024])

; 3d points projected on the sky 
!null=plot3d(ra,z*0.0+2.75,dec,' o',$
    SYM_OBJECT=ORB(),LINESTYLE="none",/SYM_FILLED,$
    xrange=0.5*[1,-1],yrange=[2.75,+4.75],zrange=0.5*[-1,1],$
    dimensions=[1024,1024],$
    /overplot,SYM_COLOR='deep_sky_blue')        
; 2d text
t = text(0.5, 0.9, 'protocluster@z=?', alignment=0.5, font_size=15)

video_file = fig+'.mp4'
video = idlffvideowrite(video_file)
framerate=20.0
wdims = s.window.dimensions
stream = video.addvideostream(wdims[0], wdims[1], framerate)

;s.rotate,-30,/zaxis
nframes = 180
for i=0, nframes-1 do begin
    s.rotate, 2.0, /zaxis               ; degrees
    timestamp = video.put(stream, s.copywindow())
endfor
s.close
video.cleanup
print, 'Write '+video_file


END