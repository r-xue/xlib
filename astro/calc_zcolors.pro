FUNCTION CALC_ZCOLORS,band,$
    z=z,beta=beta,ew=ew,$
    doplot=doplot,verbose=verbose,$
    sed=sed,igmtau_scale=igmtau_scale
;+
;   simulated high-z galaxy optical (rest-frame UV) colors (M-M_1700)
;   the simulated galaxy SED includes:
;       *   UV flam~lambda^beta (default: beta=-2)
;       *   IGMtau (Madau 1995)
;       *   lyalpha line near the rest-frame 1216AA (defined by the rest-frame EW)
;-

;   IM_FILTERMAG()
;


if  n_elements(ew) eq 0 then ew=0.0
if  n_elements(beta) eq 0 then beta=-2.0
if  n_elements(z) eq 0 then z=2.78

ew_obs=ew*(1.+z)
ft=get_filter(band)



w=ft.wave       ;   ft.wave in angstrom
x=3e18/w
y=ft.tran>0.0   ;   signal per photons

w_lya=1216.*(1+z)
tag=where((w-w_lya) le +10.0+w_lya*(10.0)/3e5 and (w-w_lya) gt w_lya*(10.0)/3e5)
w_lya=min(w[tag])
tag_lya=where(w_lya eq w)

w_1700=1700.*(1.+z)
w_1220=1220.*(1.+z)
flam_ab=(w/w_1700)^(-2.)
flam=(w/w_1700)^(beta)
fnu_1700=1.0*w_1700^2.0/(3.0e18)
fnu_1220=(w_1220/w_1700)^(beta)*w_1220^2.0/(3.0e18)
flam_1700=1.0
flam_1220=(w_1220/w_1700)^(beta)


flux_lya=flam[tag_lya]*ew_obs
if  tag[0] ne -1 then begin
    flam[tag_lya]=flam[tag_lya]+flux_lya/(abs(w[tag_lya-1]-w[tag_lya+1])/2.0)
endif

if  n_elements(igmtau_scale) eq 0 then igmtau_scale=1.0
igmtau_scale=igmtau_scale>0.0
flam=flam*exp(-calc_igmtau(w,z,model='I14')*igmtau_scale)

sed={   flam_1220:flam_1220,$               ;   erg s^-1 cm^-2 AA-1
        flam_1700:flam_1700,$               ;   erg s^-1 cm^-2 AA-1        
        fnu_1700:fnu_1700,$                 ;   erg s^-1 cm^-2 Hz-1
        fnu_1220:fnu_1220,$                 ;   erg s^-1 cm^-2 Hz-1
        flux_lya:flux_lya,$                 ;   erg s^-1 cm^-2
        flam:flam,$                         ;   erg s^-1 cm^-2 AA-1
        wave:w}                             ;   AA

clam=flam/(1.0/w)
clam_ab=flam_ab/(1.0/w)

; don't use int_tabulated here..

r=TSUM(ft.wave,y*clam)/TSUM(ft.wave,y*clam_ab)

color=-2.5*alog10(r)

if  keyword_set(doplot) then begin

    plot,w,w-w,yrange=[0,5.0],/nodata,xstyle=1,ystyle=1
    w_temp=findgen(10000)+1000
    flam_ab_temp=(w_temp/w_1700)^(-2)
    oplot,w_temp,flam_ab_temp,color=cgcolor('red'),thick=5
    oplot,w,flam_ab,color=cgcolor('red')
    oplot,w,y/max(y),psym=10
    oplot,w,flam,color=cgcolor('blue'),thick=2
    oplot,w_1700*[1,1],[-1,10],color=cgcolor('yellow'),linestyle=2
    oplot,[0,10000],[1,1],color=cgcolor('yellow'),linestyle=2
    

endif

return,color

END


PRO TEST_CALC_ZCOLORS

;color=CALC_ZCOLORS('subaru-ia445',z=2.65,beta=-2,ew=70,/doplot,/verbose,sed=sed)
color=CALC_ZCOLORS('kpno-mosaic-bw',z=2.65,beta=-2,ew=70,/doplot,/verbose,sed=sed)

END

