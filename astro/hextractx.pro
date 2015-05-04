PRO HEXTRACTX,IM,HD,subim,subhd,xrange,yrange,$
    radec=radec,$
    arcmin=arcmin
;+
; NAME:
;   HEXTRACT_BOX
;
; PURPOSE:
;   similar with hextract, however the box is defined in the 
;   astronomical system (or the offset system)
;   the result will be a small patch of the orginal image just covering
;   the astronomical box
;
; INPUTS:
;   IM          data image
;   HD          data hd
;   REFHD       header specifying the region to be plotted
;               note: refhd pixel size doesn't really matter here.
;   position   plott position
;   _EXTRA      any keywords for cgimgscl
;
; KEYWORD:
;   noplot      don't plot, just for testing, or deriving subrange/subim
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
;
;-

xbox=[min(xrange),max(xrange)]
xbox=[xbox[0],xbox[1],xbox[1],xbox[0]]
ybox=[min(yrange),max(yrange)]
ybox=[ybox[0],ybox[0],ybox[1],xbox[1]]

if  n_elements(radec) eq 2 then begin
    u2d=3600
    if  keyword_set(arcmin) then u2d=60.0
    xbox=radec[0]+xbox/u2d/cos(!const.DtoR*radec[1])
    ybox=radec[1]+ybox/u2d
endif
adxy,hd,xbox,ybox,xx,yy

nxy=size(im,/d)
xmin=floor(min(xx)-2)>0
xmax=ceil(max(xx)+2)<nxy[0]-1
ymin=floor(min(yy)-2)>0
ymax=ceil(max(yy)+2)<nxy[1]-1

if  xmin le nxy[0]-1 and xmax ge 0 and ymin le nxy[1]-1 and ymax ge 0 then begin
    hextract,im,hd,subim,subhd,xmin,xmax,ymin,ymax   
endif

END
