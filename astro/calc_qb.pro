FUNCTION CALC_QB,filter,mode=mode,$
    wave=wave,flux=flux,$               ;   mode='sed'
    beta=beta,zigm=zigm,$               ;   mode='cont'
    igmtau_scale=igmtau_scale
;+
;   all wave are in the obs frame
;   mode='line':    calculate b (bandwidth)
;   mode='cont':    calculate coeff q  (q=1 if beta=-2 and no IGM)
;-

c=3e18
ft=get_filter(filter)

if  mode eq 'line' then begin
    ;   wave:   delta line wavelength
    w=ft.wave
    g=(ft.tran>0.0)
    linterp,w,g,wave,gain,missing=!values.f_nan
    qb=c*abs(tsum(w,g/w))/(gain*wave)
endif

if  mode eq 'cont' then begin
    ;   wave:   reference wavelength
    ;   zigm:   redshift for IGM absorption
    if  n_elements(beta) eq 0 then beta=-2.0
    
    w=ft.wave
    g=(ft.tran>0.0)
    qb=g/w
    ;print,qb
    qb=qb*(w/wave)^(2.+beta)
    if  keyword_set(zigm) then begin
        if  n_elements(igmtau_scale) eq 0 then igmtau_scale=1.0
        igmtau_scale=igmtau_scale>0.0
        qb=qb*exp(-calc_IGMTAU(w,zigm,model='I14')*igmtau_scale)
    endif
    qb=tsum(w,qb)
    qb=qb/tsum(w,g/w)
endif

return,qb

END

    
    
    
    