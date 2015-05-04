PRO MAP_BOUNDARY,IM,HD=HD,$
    RADEC=RADEC,ARCMIN=ARCMIN,$
    _extra=extra,$
    outline=outline,edge=edge
;+
; NAME:
;   MAP_BOUNDARY
;
; PURPOSE:
;   PLOT ROI BOUNDARY
;
; INPUTS:
;   IM          2d array (1: ROI, 0:blank) 
;   HD          data hd for sky mapping
;               if no HD is provided, we wil use pixel coordinates
;   RADEC       projection center of the mapping region
;   ARCMIN      units for dx-dy mapping
;   _EXTRA      any keyword for xyad.pro
;               any keyword for cgpolygon
;
; OPTIONS:
;   outline     find_boundary.pro doesn't include boundary corner. 
;               /outline will fix it.
;   edge        By default, the polygon will use the boundary pixel centers
;               /edge= will use pixel edge.
;   In most cases, outline=1/edge=1 is the best.
;   
; HISTORY:
;
;   20150420  RX  split from map_fits.pro
;-

bim=im
if  keyword_set(edge) then begin
    bim=fltarr(size(im,/d)+1)
    bim[0,0]=im
    bim[0,1]=bim[0:-2,1:-1]+im
    bim[1,1]=bim[1:-1,1:-1]+im
    bim[1,0]=bim[1:-1,0:-2]+im
endif

blobs=Obj_New('Blob_Analyzer',bim)
blobs->ReportStats
nb=blobs->numberofblobs()
nxy=size(bim,/d)

for i=0,nb-1 do begin
    
    bs=blobs->GetStats(i)
    bb=bs.PERIMETER_PTS
    
    ;   THIS IS INDEX; NOT SKY POSITIONS; NOT PIXEL POSITIONS   
    xp=bb[0,*]
    yp=bb[1,*]
 
    if  keyword_set(outline) then begin
        bs=shift(bb,0,-1)
        tag=where(total(abs(bs-bb),1) eq 2)
        obj_roi=obj_new('IDLanROI',bb[0,*],bb[1,*])
        ip=0

        foreach itag,tag do begin
            p1=bb[*,itag]
            p2=bs[*,itag]
            tpx=[bb[0,itag],bs[0,itag]]
            tpy=[bs[1,itag],bb[1,itag]]
            for j=0,1 do begin
                if  ~(obj_roi->containspoints(tpx[j],tpy[j])) then continue
                if  n_elements(xp) eq itag+1+ip then begin
                    xp=[xp[0:itag+ip],tpx[j]]
                    yp=[yp[0:itag+ip],tpy[j]]
                endif else begin
                    xp=[xp[0:itag+ip],tpx[j],xp[itag+1+ip:*]]
                    yp=[yp[0:itag+ip],tpy[j],yp[itag+1+ip:*]]                
                endelse
                ip=ip+1
            endfor
        endforeach
    endif
    
    ;   IF EDGE=1, WE NEED TO CONVERT CONERS TO POSITIONS in PIXEL COORD,
    ;   IN WHICH, THE FIRST PIXEL CENTER IS [0,0]
    if  keyword_set(edge) then begin
        xp=xp-0.5
        yp=yp-0.5
    endif
    
    ;   MAPPING PIXEL POSITIONS TO SKY POSITIONS
    if  n_elements(hd) ne 0 then begin
        map_ad,hd,xx,yy,x=xp,y=yp,radec=radec,arcmin=arcmin,_extra=extra
    endif else begin
        xx=xp
        yy=yp
    endelse
    
    cgpolygon,[xx[*],xx[0]],[yy[*],yy[0]],_extra=extra
    
endfor

END
