FUNCTION WV_FILTER,im,hd,s,mim=mim
;+
;   scale in armin
;   return a wavelet filtered power spectrum + image
;-

imf=fft(im,/center)

; normalized power spectrum images
imps=abs(imf)^2
impslog=ALOG10(imps)
impslog=impslog-max(impslog)
tmp=max(impslog,pmax)
pmax=ARRAY_INDICES(impslog,pmax)


getrot,hd,rot,cdelt
psize=abs(cdelt[0])*60.*60.
a=s*60.
nxy=size(impslog,/d)
dist_ellipse,dist,nxy,pmax[0],pmax[1],/double,$
    nxy[0]/nxy[1],90.
dist=dist*(1./(psize*nxy[0]))

; wavelet filter in the UV domain
flt=1.065*a/psize*(cos(!dpi/2.*alog10(2.*dist*a)/alog10(2.)))^2.0
flt[where(dist gt 1./a or dist le 1./4./a,/null)]=0.0
mimf=imf*flt
mim= REAL_PART(FFT(mimf, $
    /INVERSE, /CENTER))
ma=total(abs(mim)^2.0)
return,ma

;imflt=fft(flt,/inverse)
;
;window,0,xsize=800,ysize=800
;cgloadct,13
;vmin=min(im,/nan) & vmax=max(im,/nan)
;pos=pos_mp(0,[2,2],[0.01,0.01],[0.1,0.1])
;cgimage,im,stretch=5,position=pos.position,$
;    minvalue=vmin,maxvalue=vmax
;
;pos=pos_mp(1,[2,2],[0.01,0.01],[0.1,0.1])
;cgimage,alog10(abs(imf)^2.0),position=pos.position,/noe
;
;pos=pos_mp(3,[2,2],[0.01,0.01],[0.1,0.1])
;cgimage,flt,position=pos.position,/noe
;
;pos=pos_mp(2,[2,2],[0.01,0.01],[0.1,0.1])
;cgimage,mim,stretch=5,position=pos.position,/noe,$
;    minvalue=vmin,maxvalue=vmax

;ph=cos(!dpi/2.*ALOG(2*()) / ALOG(2))


END


PRO TEST_WV_FILTER

;+
;   calculate filtered images for each scale at certain band. 
;-

ns=30
x=0.1*findgen(ns)+2.0
x=10.^x/60.

im1=readfits('LMC.hi.cm.sm.mom0_smo60.fits',hd1)
im1=padding(im1,500)
mim={   filename:'',$
        mim:cmreplicate(im1,ns),$
        scale:x,$
        ps:x*0.0}
nb=6
st_mim=replicate(mim,nb)
st_mim.filename=[ 'LMC.hi.cm.sm.mom0_smo60.fits',$
                'LMC_IRAC8.0_GAUSS41_res_smo60.fits',$
                'LMC_v9.co.vbin.sgm.mom0_smo60.fits',$
                'LMC_MIPS24_GAUSS41_smo60.fits',$
                'lmc_sfr_smo60.fits',$
                'LMC.fl_smo60.fits']


for i=0,nb-1 do begin
    im=readfits(st_mim[i].filename,hd)
    im[where(im ne im,/null)]=0.0 
    im=padding(im,500)
    ps=x*0.0
    print,st_mim[i].filename
    for j=0,n_elements(x)-1 do begin
        ps=wv_filter(im,hd,x[j],mim=mim)
        st_mim[i].mim[*,*,j]=mim
        st_mim[i].ps[j]=ps
        print,st_mim[i].scale[j]
    endfor
endfor

save,st_mim,filename='test.dat'

END

PRO TEST_WV_FILTER_CROSS,band1,band2,outname

;+
;   calculate the corss-correlation coeffecient for mutiple-band
;-

restore,'test.dat',/v

band1_list=[1,3,4,1,1]
band2_list=[2,2,2,0,20]
ccname=['8micron-CO','24-CO','SFR-CO','8micron-HI','8micron-N(H)']

for k=0,4 do begin

band1=band1_list[k]
band2=band2_list[k]

x=alog10(st_mim[0].scale*60)
r=x*0.0
print,r
for i=0,n_elements(x)-1 do begin
    mim1=st_mim[band1].mim[*,*,i]
    
    if  band2 ne 20 then begin
        mim2=st_mim[band2].mim[*,*,i]
        y1=st_mim[band1].ps[i]
        y2=st_mim[band2].ps[i]
    endif
    if  band2 eq 20 then begin
        a=200*2.0
        b=1.823
        mim2=a*(st_mim[2].mim[*,*,i])+b*(st_mim[0].mim[*,*,i])
        y1=st_mim[band1].ps[i]
        y2=(sqrt(st_mim[2].ps[i])*a+sqrt(st_mim[0].ps[i])*b)^2.0
    endif
    
    r[i]=total(mim1*mim2)/sqrt(y1*y2)
    print,i,r[i]
endfor
save,x,r,filename=ccname[k]+'.dat'

endfor

END


PRO TEST_WV_FILTER_PLOT

;+
;   plot cross-correlation coefficient as a function of the physical scale (a)
;-

set_plot,'ps'
device, file='wv_filter.eps', /color, bits=8, $
    /cmyk, /encapsulated,$
    xsize=8,ysize=6,/inches
    
!p.thick=2.0
!x.thick = 2.0
!y.thick = 2.0
!z.thick = 2.0
!p.charsize=1.4
!p.charthick=2.0

restore,'8micron-CO.dat',/v
plot,x,r,xrange=[1.5,4.5],yrange=[-0.2,1.2],$
    xstyle=1,ystyle=1,$
    xtitle='log(scale/[arcsec])',$
    ytitle='cross-correlation coefficient'

ccname=['8micron-CO','24-CO','SFR-CO','8micron-HI','8micron-N(H)']
cc=['red','red','red','blue','green']
linestyle=[0,1,2,0,0]
for k=0,4 do begin
    restore,ccname[k]+'.dat',/v
    
    oplot,x,r,psym=4,color=cgcolor(cc[k])
    oplot,x,r,linestyle=linestyle[k],color=cgcolor(cc[k]),thick=7
    oplot,[1.5,4.5],[0.,0.]
endfor
al_legend,ccname,linestyle=linestyle,color=cc,thick=7


device, /close
set_plot,'X'

END