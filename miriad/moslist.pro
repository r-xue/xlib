PRO MOSLIST,mir

cmd="imlist in="+mir+" options=mosaic >"+mir+'.moslist.log'
print,'run miriad: '+cmd
spawn,cmd

readcol,mir+'.moslist.log',id,nx,ny,ra,dec,array,rms,format='f,f,f,a,a,a,f'
radec=ra+dec
ra=tenv(ra)*15.
dec=tenv(dec)
uniq=rem_dup(radec)
auniq=rem_dup(array)

x=[]
y=[]
z=[]
for i=0,n_elements(uniq)-1 do begin
    print,i,radec[uniq[i]]
    tag=where(radec eq radec[uniq[i]])
    rms0=sqrt(total(rms[tag]^2.0))
    print,ra[uniq[i]],dec[uniq[i]],rms0
    x=[x,ra[uniq[i]]]
    y=[y,dec[uniq[i]]]
    z=[z,rms0]
endfor

z=(1/z)
z=z/max(z)
xc=median(x)
yc=median(y)

set_plot,'ps'
device,filename=mir+'.moslist.eps',bits=8,$
    xsize=4.5,ysize=4.5,$
    /inches,/encapsulated,/color
!p.thick=2.0
!x.thick = 2.0
!y.thick = 2.0
!z.thick = 2.0
!p.charsize=1.0
!p.charthick=2.0
!x.gridstyle = 0
!y.gridstyle = 0
xyouts,'!6'

im=readmir(mir,hd)
SXADDPAR,hd,'NAXIS',2
SXDELPAR,hd,'NAXIS3'
SXDELPAR,hd,'NAXIS4'

adxy,hd,x,y,xp,yp

imcontour,im[*,*,0],hd,/nodata

im=1/im[*,*,10]
im=im/max(im,/nan)
;;cgloadct,1
;;cgimage,im[*,*,10],pos=[0.1,0.1,0.9,0.9]
;;cgloadct,0
;cgcontour,im,levels=[0.2,0.4,0.6,0.8]
;

plots,xp,yp,psym=symcat(16),symsize=0.2;,xrange=[xc+0.02,xc-0.02],yrange=[yc-0.02,yc+0.02]xstyle=1,ystyle=1,
;cgtext,xp,yp,string(z,format='(f0.2)'),/data,ali=0.5
;cgcontour,z,x,y,/irr,/overplot,nlevels=10,/noe

device,/close
set_plot,'x'

END

PRO TEST_MOSLIST

moslist,'ngc4254.co.cm'

END