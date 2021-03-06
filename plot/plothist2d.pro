PRO PLOTHIST2D,x,y,xbin,ybin,$
  xmin=xmin,xmax=xmax,$
  ymin=ymin,ymax=ymax,$
  xlog=xlog,ylog=ylog,$
  ncolor=ncolor,$
  histmin=histmin,$  ; not implemented yet
  clip=clip,$
  histlog=histlog,$
  percent=percent,$
  p_color=p_color,$
  c_color=c_color,$
  pl_cont=pl_cont,$
  pl_pixel=pl_pixel,$
  wtid=wtid,$
  wtsz=wtsz
;+
;
;   plot 2D histogram z(x,y) 
;   
;   INPUTS:
;       xbin/ybin (bin size in linear/log spacing)
;       pl_pixel=1 pixel plots
;       pl_cont=1 contour plots 
;
;   HISTORY:
;
;       20120110  RX  introduced
;-

if n_elements(xmin) eq 0 then xmin=min(x,/nan)
if n_elements(xmax) eq 0 then xmax=max(x,/nan)
if n_elements(ymin) eq 0 then ymin=min(y,/nan)
if n_elements(ymax) eq 0 then ymax=max(y,/nan)
if n_elements(ncolor) eq 0 then ncolor=150
if n_elements(histmin) eq 0 then histmin=0
if n_elements(clip) eq 0 then clip=[xmin,ymin,xmax,ymax]
if n_elements(pl_pixel) eq 0 then pl_pixel=1
if n_elements(wtsz) eq 0 then wtsz=1

tag=where(x eq x and y eq y $
          and x lt xmax and x gt xmin $
          and y lt ymax and y gt ymin,/null)

if  keyword_set(xlog) then begin
    hist_x=alog10(x[tag])
    hist_xmin=alog10(xmin)
    hist_xmax=alog10(xmax) 
endif else begin
    hist_x=x[tag]
    hist_xmin=xmin
    hist_xmax=xmax
endelse
if  keyword_set(ylog) then begin 
    hist_y=alog10(y[tag])
    hist_ymin=alog10(ymin)
    hist_ymax=alog10(ymax) 
endif else begin 
    hist_y=y[tag]
    hist_ymin=ymin
    hist_ymax=ymax
endelse

hist=hist_2d(hist_x, hist_y,$
    min1=hist_xmin,max1=hist_xmax,$
    min2=hist_ymin,max2=hist_ymax,$
    bin1=xbin,$
    bin2=ybin)
  
if  keyword_set(wtid) then begin
    hist=0.0
    wtid_left=wtid[tag]
    wtsz_left=wtsz[tag]
    uq=wtid_left[rem_dup(wtid_left)]
    foreach u,uq do begin
        tmp=where(wtid_left eq u)
        ttt=hist_2d(hist_x[tmp], hist_y[tmp],$
            min1=hist_xmin,max1=hist_xmax,$
            min2=hist_ymin,max2=hist_ymax,$
            bin1=xbin,$
            bin2=ybin )
        hist=hist+ttt/float(total(ttt*mean(wtsz_left[tmp])))
    endforeach
endif
  

histlin=hist

if (not keyword_set(wtid)) and keyword_set(histlog) then hist=alog10(hist>1.0)
if keyword_set(wtid) and keyword_set(histlog) then begin
    tmp=where(hist ne 0.0)
    nf=min(hist[tmp])
    print,nf,max(hist/nf)
    hist=alog10(hist/nf>1.)
endif
hist=hist*1.0/max(hist,/nan)*ncolor

dim=size(hist,/d)
xx=hist*0.0
yy=hist*0.0
for i=0,dim[0]-1 do begin
  for j=0,dim[1]-1 do begin
    xl=hist_xmin+i*xbin
    xr=hist_xmin+(i+1.)*xbin
    xc=hist_xmin+(i+.5)*xbin
    yb=hist_ymin+j*ybin
    yu=hist_ymin+(j+1.)*ybin
    yc=hist_ymin+(j+.5)*ybin
    if keyword_set(xlog) then begin
      xl=10.0^xl
      xr=10.0^xr
      xc=10.0^xc
    endif
    if keyword_set(ylog) then begin
      yb=10.0^yb
      yu=10.0^yu
      yc=10.^yc
    endif
    xx[i,j]=xc
    yy[i,j]=yc
    if pl_pixel eq 1 then begin
    ;if hist[i,j] ge histmin then begin
      polyfill,[xl,xr,xr,xl],[yb,yb,yu,yu],$
        color=hist[i,j],noclip=0,clip=clip
    ;endif
    endif
  endfor
endfor


if keyword_set(pl_cont) then begin
    if n_elements(c_color) eq 0 then c_color='green'
    levs=min(hist)+(findgen(5)+1.)*(max(hist)-min(hist))/6.
    contour,hist,xx,yy,/overplot,c_colors=cgcolor(c_color),$
        clip=clip,noclip=0,levels=levs
endif

if n_elements(percent) ne 0 then begin
    if n_elements(p_color) eq 0 then pcolor='cyan' 
    shist=histlin[sort(histlin)]
    tol=total(shist,/cumulative)*1.0/total(shist)
    levs=percent
    for k=0,n_elements(levs)-1 do begin
        levs[k]=interpol(shist,tol,percent[k])
    endfor
    cgcontour,histlin,xx,yy,/overplot,c_colors=p_color,$
        levels=levs,clip=clip,noclip=0,c_lab=0
endif

END


PRO TEST_PLOTHIST2D

x=randomn(n,10000)
y=randomn(n,10000)

; linear-linear space
window,1,xsize=500,ysize=500

plot,[0],[0],xrange=[-10,10],yrange=[-10,10],xstyle=1,ystyle=1,/nodata
plothist2d,x,y,0.5,0.5,/pl_cont

; log-log space
window,2,xsize=500,ysize=500
x=findgen(1000)+1.0
y=(findgen(1000)+randomn(n,1000)*20)^4.0+1.0

plot,[0],[0],xrange=[1,2000],yrange=[1,2000^5.0],xstyle=1,ystyle=1,/nodata,/xlog,/ylog
cgloadct,3, /reverse
plothist2d,x,y,0.1,0.1,/xlog,/ylog,clip=[1,1,1000,1000^4.0],/pl_cont
plot,[0],[0],xrange=[1,2000],yrange=[1,2000^5.0],xstyle=1,ystyle=1,/nodata,/xlog,/ylog,/noe


END