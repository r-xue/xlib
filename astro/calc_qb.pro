FUNCTION CALC_QB,filter,mode=mode,$
    wave=wave,flux=flux,$               ;   mode='sed'
    beta=beta,zigm=zigm                 ;   mode='cont'
;+
;   all wave are in the obs frame
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
    w=ft.wave
    g=(ft.tran>0.0)
    qb=g/w
    qb=qb*(w/wave)^(2.+beta)
    if  keyword_set(zigm) then qb=qb*exp(-LM_IGMTAU(w,zigm))
    qb=tsum(w,qb)
    qb=qb/tsum(w,g/w)
endif

return,qb

END

    
    
    
    