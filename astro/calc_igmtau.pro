FUNCTION CALC_IGMTAU,wv_obs,z,model=model
;+
;   wv_obs:         wavelength in observer frame
;   model options:  m95/m95lm/m06
;   note: 
;                   https://heasarc.gsfc.nasa.gov/xanadu/xspec/models/zigm.html
;-


forward_function LM_IGMTAU

if  not keyword_set(model) then model='M95'

if  strmatch(model,'M95LM',/f) then begin
    ;
    ;   Madau 1995
    ;   borrow the procedure from Moustakas/IMPRO
    ;   note for lm_igmtau.pro 
    ;   **** doesnt include metal
    ;   **** only include the first 4 lyman lines.
    ;
    igmtau=lm_igmtau(wv_obs,z)
    
endif

if  strmatch(model,'M95',/f) then begin

    ;   Madau 1995
    ;   translated from zigm.f from the xspec package
    ;
    lambda_lim=911.75
    a_metal=0.0017
    
    ly_coef=[0.0036,   0.0017,   0.0011846,0.0009410,0.0007960,$
                 0.0006967,0.0006236,0.0005665,0.0005200,0.0004817,$
                 0.0004487,0.0004200,0.0003947,0.000372 ,0.000352 ,$
                   0.0003334,0.00031644]
    ly_wave=[1215.67 ,1025.72 ,972.537,949.743,937.803,$
                  930.748, 926.226,923.15 ,920.963,919.352,$
                  918.129, 917.181,916.429,915.824,915.329,$
                  914.919, 914.576]

    igmtau=wv_obs*0.0
    zfac=1.+z
    metals=1    
    lylim=1.0
    
    for i=0,n_elements(wv_obs)-1 do begin
        
        lambda_obs=wv_obs[i]
        tau_eff = 0.
     
        xc0=lambda_obs
        lambda=lambda_obs/zfac
        xc = xc0 / lambda_lim
        
        if (xc0 gt 900.0) then begin
            
            for m=1,17 do begin
                if (lambda lt ly_wave[m-1]) then begin
                    tau_eff = tau_eff + ly_coef[m-1] * (xc0 / ly_wave[m-1])^3.46
                    if (metals eq 1 and m eq 1) then tau_eff = tau_eff + a_metal *(xc0 / ly_wave[0])^1.68
                endif else begin
                    continue
                endelse
            endfor
            
            ;* Lyman continuum attenuation
            ;* This uses the approximation given in footnote 3 to the
            ;* integral in Eq. 16 of Madau (1995).
            ;* It appears to be a poor approximation for observed wavelengths
            ;* less than 912 Angstroms (xc < 1).

            if (lambda lt lambda_lim and lylim eq 1) then begin
                tau_eff = tau_eff $
                      + (0.25 * xc^3.0 * ((zfac^0.46) - (xc^0.46))) $
                      + (9.4 * xc^1.5 * ((zfac^0.18) - (xc^0.18))) $
                      - (0.7 * xc^3 * ((xc^(-1.32)) - (zfac^(-1.32)))) $
                      - (0.023 * ((zfac^1.68) - (xc^1.68)))
            endif
        endif
        
        ;* check for reasonable values of tau_eff
        if (tau_eff gt 0.) then begin
            if (tau_eff lt 100.) then fmmadau = exp(-tau_eff) else fmmadau = 0.0
        endif else begin
            fmmadau = 1.0
        endelse

        igmtau[i]=tau_eff
        
    endfor
    
endif



if  strmatch(model,'M06',/f) then begin
    
    ;   Meiksin 2006
    ;   translated from zigm.f from the xspec package
    
    nmax=31 ;maximum value for Lyman series
    mmax=10 ;maximum value for LLS summation
    lambda_lim=912.
    ;   fac contains the ratio tau_n to tau_alpha (n=2) for n=3 to 9
    fac=[0.,0.,0.348,0.179,0.109,0.0722,0.0508,0.0373,0.0283]
    zfac=1.+z
    wv=wv_obs/zfac
    igmtau=wv_obs*0.0
    lylim=1
    lls_fact=1.0
    
    for i=0,n_elements(wv_obs)-1 do begin
        
        lambda_obs=wv_obs[i]
        lambda=wv[i]
        tau_eff = 0.
        tau_igm=0.0
        tau_lls=0.0
        
        if  lambda_obs gt 900.0  then begin
            lamn = lambda_lim / 0.75
            if (lambda le lamn) then begin
                zn1 = lambda_obs / lamn
                if (zn1 le 5.0) then begin
                    ;Meiksin Eq. 2
                    tau_eff = 0.00211*((zn1)^3.7)
                endif else begin
                    ;Meiksin Eq. 3
                    tau_eff = 0.00058*((zn1)^4.5)
                endelse
                for n=3,nmax do begin
                    an=n
                    lamn = lambda_lim / (1.0 - 1.0/an/an)
                    if (lambda gt lamn) then continue
                    zn1 = lambda_obs / lamn
                    zn125 = zn1*0.25
                    if (zn1 le 5.0) then tau2 = 0.00211*((zn1)^3.7) else tau2 = 0.00058*((zn1)^4.5)
                    if (n lt 6) then begin
                        if (zn1 le 4.0) then begin
                            tau_eff = tau_eff + tau2*fac[n-1]*zn125^(1.0/3.0)
                        endif else begin
                            tau_eff = tau_eff + tau2*fac[n-1]*zn125^(1.0/6.0)
                        endelse
                    endif else begin
                        if (n lt 10) then begin
                            tau_eff = tau_eff + tau2*fac[n-1]*zn125^(1.0/3.0)
                        endif else begin
                            tau_eff = tau_eff + tau2*fac[9-1]*zn125^(1.0/3.0) * 720.0/an/(an*an -1.0)
                        endelse
                    endelse
                endfor
            endif
        
            ;   Lyman continuum attenuation
            if  (lambda lt lambda_lim and lylim eq 1) then begin
                xc = lambda * zfac / lambda_lim
                xc25 = xc^2.5
        
                ;   do IGM -- Meiksin Eq. 5
                tau_igm=0.805*xc^3 * (1.0/xc - 1.0/zfac)
            
                ;   do LLS -- Meiksin Eq. 7
                ;   term1 is gamma(0.5,1) - 1/e
                term1 = 0.2788 - 0.3679
                term2 = 0.0
                fact_n = 1.0
                for m = 0, mmax-1 do begin
                    am = m
                    if (m gt 0) then begin
                        fact_n = -fact_n * am
                    endif
                    term2 = term2 + 1.0 / (fact_n * (2.0*am - 1.0))
                endfor
                term3 = zfac * xc^1.5 - xc25
                term4 = 0.0
                fact_n = 1.0
                for m = 1, mmax do begin
                    am = m
                    fact_n = -fact_n * am
                    term4 = term4 + (1.0 / $
                                (fact_n * (2.0*am - 1.0) * (6.0*am - 5.0)) * $
                                (zfac ^ (2.5 - (3.0*am)) * xc^(3 * m) - xc25))
                endfor
            
                tau_lls = 0.25*((term1 - term2) * term3 - 2.0*term4)
                ; multiply by specified factor to be able to account for variations across the sky
                tau_lls = tau_lls * lls_fact
            endif
            tau_eff=tau_eff + tau_igm + tau_lls
    
        endif
    
        ; check for reasonable values of tau_eff
        if (tau_eff gt 0.) then begin
            if (tau_eff lt 100.) then $
                fmmeiksin = exp(-tau_eff) $
            else $
                fmmeiksin = 0.0
        endif else begin
            fmmeiksin = 1.0
        endelse
        
        igmtau[i]=tau_eff
        
    endfor
    
endif


return,igmtau

END

PRO TEST_CALC_IGMTAU

wave=findgen(1000)+800
zz=3.0
tau_m95=calc_igmtau(wave*(1.+zz),zz,model='M95')
tau_m95lm=calc_igmtau(wave*(1.+zz),zz,model='M95LM')
tau_m06=calc_igmtau(wave*(1.+zz),zz,model='M06')

plot,wave*(1.+zz),wave*0.0,yrange=[0,1.2],/nodata
oplot,[912,912]*(1.+zz),[0,2]
oplot,[650,650]*(1.+zz),[0,2]
oplot,[610,610]*(1.+zz),[0,2]
oplot,wave*(1.+zz),exp(-tau_m95),color=cgcolor('red')
oplot,wave*(1.+zz),exp(-tau_m95lm),color=cgcolor('yellow')
oplot,wave*(1.+zz),exp(-tau_m06),color=cgcolor('blue')


END