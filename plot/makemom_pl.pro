PRO MAKEMOM_PL,prefix,scale=scale
;+
; NAME:
;   MAKEMOM_PL
;
; PURPOSE:
;   summary plot for mom0 and mom1 maps
;
; INPUTS:
;   PREFIX    -- prefix for maps
;                e.g.'yourpath/n4254co.gm'
;   
; OUTPUTS:
;   prefix.momx.eps
;
; HISTORY:
;
;   20130214  RX  introduced
;   20130910  RX  changed to absolute coordinate
;
;-

set_plot, 'ps'
device, filename=prefix+'.momx.eps', $
bits_per_pixel=8,/encapsulated,$
xsize=10,ysize=7,/inches,/col,xoffset=0,yoffset=0,/cmyk

!p.thick=2.0
!x.thick = 2.0
!y.thick = 2.0
!z.thick = 2.0
!p.charsize=1.5
!p.charthick=1.5

for i=0,1 do begin
  
  im=prefix+'.mom'+strtrim(i,2)+'.fits'
  im=readfits(im,imhd)
  if n_elements(scale) ne 0 and i eq 0 then im=im*scale 
  
  pos=pos_mp(i,[2,1],[0.025,0.025],[0.06,0.05,0.04,0.2])
  pos=pos.position

  if i eq 0 then begin
    cgloadct,13
    minvalue=min(im,/nan)
    maxvalue=max(im,/nan)
    if  minvalue eq maxvalue then begin
        minvalue=-1 & maxvalue=1
    endif
    cgimage,im,pos=pos,stretch=1,/noe,/KEEP_ASPECT_RATIO,minvalue=minvalue,maxvalue=maxvalue

  endif
  if i eq 1 then begin
    cgloadct,13
    cgimage,im,pos=pos,stretch=1,/noe,/KEEP_ASPECT_RATIO
  endif
  
  rd_hd,imhd,s=s
  psize=abs(s.cdelt[0])*3600
  sz=size(im,/d)
  ;print,s.bmaj/2.0/psize
  tvellipse,s.bmaj/2.0/psize,s.bmin/2.0/psize,$
      sz[0]/10.0,sz[1]/10.0,$
      s.bpa,$
      /data,noclip=0,color=cgcolor('cyan'),/fill
  tvellipse,s.bmaj/2.0/psize,s.bmin/2.0/psize,$
      sz[0]/10.0,sz[1]/10.0,$
      s.bpa,$
      /data,noclip=0,color=cgcolor('black')
  
  cgloadct,0
  ;if (where(im eq im and im ne 0.0))[0] ne -1 then begin
    ;imcontour_rdgrid,im,imhd,nlevels=7,$
    ;/noe,pos=pos,$
    ;/nodata,title=dataid,/overlay,/type,$
    ;xtitle='Right Ascension (J2000)',ytitle='Declination (J2000)',subtitle=' '
    xtitle=!null
    ytitle=!null
    if i eq 1 then ytitle=''
    print,size(im,/dim)
    tmp=im & tmp[1]=0 & tmp[0]=1. 
    imcontour_rdgrid,tmp,imhd,$
        /noe,pos=pos,$
        /nodata,title=dataid,/overlay,$
        xtitle=xtitle,ytitle=ytitle,subtitle=' ',$
        color='red',AXISCOLOR='red'
  ;endif
;  tmp=im
;  tmp=(tmp eq tmp)
;  imcontour_rdgrid,float(tmp),imhd,levels=[0.5],$
;  /noe,pos=pos,c_lab=0,c_linestyle=2,$
;  title=dataid,/overlay,/type, $
;  xtitle='Right Ascension (J2000)',ytitle='Declination (J2000)',subtitle=' '
  
  pos=[pos[0],pos[3],pos[2],pos[3]]+[0.0,0.05,0.0,0.10]
  if i eq 0 then begin
    cgloadct,13;3,/rev
    title='Intensity ['+strtrim(sxpar(imhd,'BUNIT'),2)+']'
  endif
  if i eq 1 then begin
    cgloadct,13
    title='Velocity Field ['+strtrim(sxpar(imhd,'BUNIT'),2)+']'
  endif
  crange=[min(im,/nan),max(im,/nan)]
  if crange[0] eq crange[1] or (where(im eq im))[0] eq -1 then crange=[-1.,1.]
  print, crange
  cgCOLORBAR, range=crange, $
  POSITION=pos,title=title,tlocation='TOP'
  cgloadct,0
  

  
endfor



device, /close
set_plot,'X'


END