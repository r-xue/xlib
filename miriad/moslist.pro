FUNCTION MOSLIST,mir,vis=vis
;+
;   return the mosaicing information as a structure from miriad-vis/mostab 
;-

if  keyword_set(vis) then begin

    print,replicate('+',30)
    cmd='uvindex vis='+mir+' log='+mir+'.moslist.log'
    print,'run miriad: '+cmd
    if  ~file_test(mir+'.moslist.log') then spawn,cmd
    print,replicate('+',30)

    log=mir+'.moslist.log'

    nlines = FILE_LINES(log)
    sarr = STRARR(nlines)
    OPENR, unit, log,/GET_LUN
    READF, unit, sarr
    FREE_LUN, unit
    tag1=where(sarr eq 'The input data-set contains the following pointings:')
    tag2=where(sarr eq '------------------------------------------------')
    ll=where(tag2 gt tag1[0]) 
    tag2=(tag2[ll])[0]

    readcol,log,source,ra,dec,dra0,ddec0,format='a,a,a,f,f',skipline=tag1,numline=tag2-tag1,/silent
    print,'no. of source',n_elements(ra)
    print,replicate('+',30)
    print,source,ra,dec
    print,replicate('+',30)
    readcol,log,dra,ddec,format='f,f',skipline=tag1,numline=tag2-tag1,/silent
    if  n_elements(dra) eq 0 then begin
        dra=[]
        ddec=[]
    endif
    print,'no. of pointing',n_elements(dra)+1

    dra=[dra0,dra]
    ddec=[ddec0,ddec]
    ra=tenv(ra)*15.
    dec=tenv(dec)
    mostable={source:source,ra:ra,dec:dec,dra:dra,ddec:ddec}

endif else begin

    source=''
    print,replicate('+',30)
    cmd="imlist in="+mir+" options=mosaic >"+mir+'.moslist.log'
    print,'run miriad: '+cmd
    spawn,cmd
    print,replicate('+',30)

    readcol,mir+'.moslist.log',id,nx,ny,ra,dec,array,rms,format='f,f,f,a,a,a,f'
    radec=ra+dec
    p_ra=tenv(ra)*15.
    p_dec=tenv(dec)

    im=readmir(mir,hd)
    SXADDPAR,hd,'NAXIS',2
    SXDELPAR,hd,'NAXIS3'
    SXDELPAR,hd,'NAXIS4'
    xc=sxpar(hd,'CRPIX1')-1
    yc=sxpar(hd,'CRPIX2')-1
    ra=sxpar(hd,'CRVAL1')
    dec=sxpar(hd,'CRVAL2')
    adxy,hd,p_ra,p_dec,xp,yp

    getrot,hd,rotang,cdelt
    psize=abs(cdelt[0]*60.*60.)
    dra=-(xp-xc)*psize
    ddec=(yp-yc)*psize

    mostable={source:source,ra:ra,dec:dec,dra:dra,ddec:ddec}

endelse

return,mostable

END


PRO MOSLIST,mir

cmd="imlist in="+mir+" options=mosaic >"+mir+'.moslist.log'
print,replicate('+',30)
print,'run miriad: '+cmd
spawn,cmd
print,replicate('+',30)

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
getrot,hd,rotang,cdelt
psize=abs(cdelt[0]*60.*60.)

imcontour,im[*,*,0],hd,/nodata

im=1/im[*,*,10]
im=im/max(im,/nan)
;;cgloadct,1
;;cgimage,im[*,*,10],pos=[0.1,0.1,0.9,0.9]
;;cgloadct,0
;cgcontour,im,levels=[0.2,0.4,0.6,0.8]
;

plots,xp,yp,psym=symcat(16),symsize=0.2;,xrange=[xc+0.02,xc-0.02],yrange=[yc-0.02,yc+0.02]xstyle=1,ystyle=1,
tvcircle,30./psize,xp,yp,/data
;cgtext,xp,yp,string(z,format='(f0.2)'),/data,ali=0.5
;cgcontour,z,x,y,/irr,/overplot,nlevels=10,/noe

device,/close
set_plot,'x'

END




PRO TEST_MOSLIST

    ;    x=[]
    ;    y=[]
    ;    z=[]
    ;    for i=0,n_elements(uniq)-1 do begin
    ;        print,i,radec[uniq[i]]
    ;        tag=where(radec eq radec[uniq[i]])
    ;        rms0=sqrt(total(rms[tag]^2.0))
    ;        print,ra[uniq[i]],dec[uniq[i]],rms0
    ;        x=[x,ra[uniq[i]]]
    ;        y=[y,dec[uniq[i]]]
    ;        z=[z,rms0]
    ;    endfor
    ;
    ;    z=(1/z)
    ;    z=z/max(z)
    ;    xc=median(x)
    ;    yc=median(y)

gallist=file_search('/Volumes/Scratch/raw/co10/n????')
gallist=repstr(gallist,'/Volumes/Scratch/raw/co10/n','')


foreach gal,gallist do begin



set_plot,'ps'
device,filename='n'+gal+'_moslist.eps',bits=8,$
    xsize=4.0,ysize=4.0,$
    /inches,/encapsulated,/color
!p.thick=1.0
!x.thick = 1.0
!y.thick = 1.0
!z.thick = 1.0
!p.charsize=0.7
!p.charthick=1.0
!x.gridstyle = 0
!y.gridstyle = 0
xyouts,'!6'

plot,[0],[0],xstyle=1,ystyle=1,/nodata,$
    xrange=[150,-150],yrange=[-150,150],$
    xtitle=textoidl('\delta R.A.'),$
    ytitle=textoidl('\delta Dec.')

vispath1='/Volumes/Scratch/raw/co10/n'+gal+'/vis/'
vispath2='/Volumes/Scratch/raw/co10/bima/n'+gal+'/n'+gal+'*/*/'

print,'search '+vispath1+'/*.co.cal'
vislist1=file_search(vispath1+'/*.co.cal')
print,'search '+vispath2+'/n*.usb'
vislist2=file_search(vispath2+'/n*.usb')
vislist=[vislist1,vislist2]
tt=where(vislist ne '')
vislist=vislist[tt]
print,'+'
for i=0,n_elements(vislist)-1 do begin
    print,vislist[i]
    mostab=moslist(vislist[i],/vis)
    psym=6
    color='red'
    thick=10
    if  strmatch(vislist[i],'*_C*',/f) then psym=9
    if  strmatch(vislist[i],'*_D*',/f) then psym=5
    if  strmatch(vislist[i],'*_E*',/f) then psym=6
    if  strmatch(vislist[i],'*bima*',/f) then psym=6
    if  strmatch(vislist[i],'*_C*',/f) then color='red'
    if  strmatch(vislist[i],'*_D*',/f) then color='green'
    if  strmatch(vislist[i],'*_E*',/f) then color='blue'
    if  strmatch(vislist[i],'*bima*',/f) then color='cyan'
    if  strmatch(vislist[i],'*_C*',/f) then thick=10
    if  strmatch(vislist[i],'*_D*',/f) then thick=5
    if  strmatch(vislist[i],'*_E*',/f) then thick=1
    if  strmatch(vislist[i],'*bima*',/f) then thick=1
    if  strmatch(vislist[i],'*_C*',/f) then dr=30
    if  strmatch(vislist[i],'*_D*',/f) then dr=30
    if  strmatch(vislist[i],'*_E*',/f) then dr=30
    if  strmatch(vislist[i],'*bima*',/f) then dr=45
    oplot,mostab.dra,mostab.ddec,psym=cgsymcat(psym),color=cgcolor(color)
    for j=0,n_elements(mostab.dra)-1 do begin
        tvellipse,dr,dr,(mostab.dra)[j],(mostab.ddec)[j],0,/data,color=color,$
            thick=thick,linestyle=0,noclip=0
    endfor
endfor
al_legend,'NGC'+gal,/right,/top,box=0
device,/close
set_plot,'x'

endforeach
;plot,mostab.dra,mostab.ddec,psym=symcat(16)
;mostab=moslist('ngc6951.co.cm')
;print,mostab
;oplot,mostab.dra,mostab.ddec,psym=3

END