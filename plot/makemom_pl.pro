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
!p.charsize=1.0
!p.charthick=1.0

for i=0,1 do begin
  
  im=prefix+'.mom'+strtrim(i,2)+'.fits'
  im=readfits(im,imhd)
  if n_elements(scale) eq 0 then scale=1.0
  im=im*scale
  
  pos=pos_mp(i,[2,1],[0.05,0.05],[0.05,0.05,0.05,0.2])
  pos=pos.position

  if i eq 0 then begin
    cgloadct,3,/rev
    cgimage,im,pos=pos,stretch=1,/noe,minvalue=0.0,/KEEP_ASPECT_RATIO
  endif
  if i eq 1 then begin
    cgloadct,13
    cgimage,im,pos=pos,stretch=1,/noe,/KEEP_ASPECT_RATIO
  endif
  
  cgloadct,0
  if (where(im eq im))[0] ne -1 then begin
    imcontour_rdgrid,im,imhd,nlevels=7,$
    /noe,pos=pos,$
    /nodata,title=dataid,/overlay,/type,$
    xtitle='Right Ascension (J2000)',ytitle='Declination (J2000)',subtitle=' '
  endif
;  tmp=im
;  tmp=(tmp eq tmp)
;  imcontour_rdgrid,float(tmp),imhd,levels=[0.5],$
;  /noe,pos=pos,c_lab=0,c_linestyle=2,$
;  title=dataid,/overlay,/type, $
;  xtitle='Right Ascension (J2000)',ytitle='Declination (J2000)',subtitle=' '
  
  pos=[pos[0],pos[3],pos[2],pos[3]]+[0.0,0.05,0.0,0.10]
  if i eq 0 then cgloadct,3,/rev
  if i eq 1 then cgloadct,13
  cgCOLORBAR, range=[min(im,/nan),max(im,/nan)], $
  POSITION=pos
  cgloadct,0
  
  rd_hd,imhd,s=s
  psize=abs(s.cdelt[0])*3600
  print,psize
  sz=size(im,/d)
  print,s.bmaj/60.0
  print,s.bmin/60.0
  tvellipse,s.bmaj/2.0/psize,s.bmin/2.0/psize,$
            sz[0]/10.0,sz[1]/10.0,$
            s.bpa,$
            /data,noclip=0,color=cgcolor('cyan'),/fill
  tvellipse,s.bmaj/2.0/psize,s.bmin/2.0/psize,$
            sz[0]/10.0,sz[1]/10.0,$
            s.bpa,$
            /data,noclip=0,color=cgcolor('black')
  
endfor



device, /close
set_plot,'X'


END