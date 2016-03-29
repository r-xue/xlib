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
    ;   * The coefficients for the Lyman series were provided by e-mail from P.Madau
    ;   * They differ slightly from Madau (1995)
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


if  strmatch(model,'I14',/f) then begin
    
    ;+
    ;   this is table 2 of Inoue et al. 2014....
    ;-
    i14tb2=[[2,1215.67,1.690e-02,2.354e-03,1.026e-04,1.617e-04,5.390e-05],$
        [3,1025.72,4.692e-03,6.536e-04,2.849e-05,1.545e-04,5.151e-05],$
        [4,972.537,2.239e-03,3.119e-04,1.360e-05,1.498e-04,4.992e-05],$
        [5,949.743,1.319e-03,1.837e-04,8.010e-06,1.460e-04,4.868e-05],$
        [6,937.803,8.707e-04,1.213e-04,5.287e-06,1.429e-04,4.763e-05],$
        [7,930.748,6.178e-04,8.606e-05,3.752e-06,1.402e-04,4.672e-05],$
        [8,926.226,4.609e-04,6.421e-05,2.799e-06,1.377e-04,4.590e-05],$
        [9,923.150,3.569e-04,4.971e-05,2.167e-06,1.355e-04,4.516e-05],$
        [10,920.963,2.843e-04,3.960e-05,1.726e-06,1.335e-04,4.448e-05],$
        [11,919.352,2.318e-04,3.229e-05,1.407e-06,1.316e-04,4.385e-05],$
        [12,918.129,1.923e-04,2.679e-05,1.168e-06,1.298e-04,4.326e-05],$
        [13,917.181,1.622e-04,2.259e-05,9.847e-07,1.281e-04,4.271e-05],$
        [14,916.429,1.385e-04,1.929e-05,8.410e-07,1.265e-04,4.218e-05],$
        [15,915.824,1.196e-04,1.666e-05,7.263e-07,1.250e-04,4.168e-05],$
        [16,915.329,1.043e-04,1.453e-05,6.334e-07,1.236e-04,4.120e-05],$
        [17,914.919,9.174e-05,1.278e-05,5.571e-07,1.222e-04,4.075e-05],$
        [18,914.576,8.128e-05,1.132e-05,4.936e-07,1.209e-04,4.031e-05],$
        [19,914.286,7.251e-05,1.010e-05,4.403e-07,1.197e-04,3.989e-05],$
        [20,914.039,6.505e-05,9.062e-06,3.950e-07,1.185e-04,3.949e-05],$
        [21,913.826,5.868e-05,8.174e-06,3.563e-07,1.173e-04,3.910e-05],$
        [22,913.641,5.319e-05,7.409e-06,3.230e-07,1.162e-04,3.872e-05],$
        [23,913.480,4.843e-05,6.746e-06,2.941e-07,1.151e-04,3.836e-05],$
        [24,913.339,4.427e-05,6.167e-06,2.689e-07,1.140e-04,3.800e-05],$
        [25,913.215,4.063e-05,5.660e-06,2.467e-07,1.130e-04,3.766e-05],$
        [26,913.104,3.738e-05,5.207e-06,2.270e-07,1.120e-04,3.732e-05],$
        [27,913.006,3.454e-05,4.811e-06,2.097e-07,1.110e-04,3.700e-05],$
        [28,912.918,3.199e-05,4.456e-06,1.943e-07,1.101e-04,3.668e-05],$
        [29,912.839,2.971e-05,4.139e-06,1.804e-07,1.091e-04,3.637e-05],$
        [30,912.768,2.766e-05,3.853e-06,1.680e-07,1.082e-04,3.607e-05],$
        [31,912.703,2.582e-05,3.596e-06,1.568e-07,1.073e-04,3.578e-05],$
        [32,912.645,2.415e-05,3.364e-06,1.466e-07,1.065e-04,3.549e-05],$
        [33,912.592,2.263e-05,3.153e-06,1.375e-07,1.056e-04,3.521e-05],$
        [34,912.543,2.126e-05,2.961e-06,1.291e-07,1.048e-04,3.493e-05],$
        [35,912.499,2.000e-05,2.785e-06,1.214e-07,1.040e-04,3.466e-05],$
        [36,912.458,1.885e-05,2.625e-06,1.145e-07,1.032e-04,3.440e-05],$
        [37,912.420,1.779e-05,2.479e-06,1.080e-07,1.024e-04,3.414e-05],$
        [38,912.385,1.682e-05,2.343e-06,1.022e-07,1.017e-04,3.389e-05],$
        [39,912.353,1.593e-05,2.219e-06,9.673e-08,1.009e-04,3.364e-05],$
        [40,912.324,1.510e-05,2.103e-06,9.169e-08,1.002e-04,3.339e-05]]
    i14coeff={  j:i14tb2[0,*],$
                lambda:i14tb2[1,*],$
                lafj1:i14tb2[2,*],$
                lafj2:i14tb2[3,*],$
                lafj3:i14tb2[4,*],$
                dlaj1:i14tb2[5,*],$
                dlaj2:i14tb2[6,*]}

    tau_laf_ls=wv_obs*0.0
    for i=0,n_elements(i14coeff.j)-1 do begin
        ;   eq 21 in I14 
        lsinrange=(wv_obs gt i14coeff.lambda[i] and wv_obs lt i14coeff.lambda[i]*(1.+z))
        tag=where(lsinrange and wv_obs lt 2.2*i14coeff.lambda[i])
        if  tag[0] ne -1 then begin
            tau_laf_ls[tag]=tau_laf_ls[tag]+i14coeff.lafj1[i]*(wv_obs[tag]/i14coeff.lambda[i])^1.2
        endif
        tag=where(lsinrange and wv_obs ge 2.2*i14coeff.lambda[i] and wv_obs lt 5.7*i14coeff.lambda[i])
        if  tag[0] ne -1 then begin
            tau_laf_ls[tag]=tau_laf_ls[tag]+i14coeff.lafj2[i]*(wv_obs[tag]/i14coeff.lambda[i])^3.7
        endif
        tag=where(lsinrange and wv_obs ge 5.7*i14coeff.lambda[i])
        if  tag[0] ne -1 then begin
            tau_laf_ls[tag]=tau_laf_ls[tag]+i14coeff.lafj3[i]*(wv_obs[tag]/i14coeff.lambda[i])^5.5
        endif
    endfor
    
    tau_dla_ls=wv_obs*0.0
    for i=0,n_elements(i14coeff.j)-1 do begin
        lsinrange=(wv_obs gt i14coeff.lambda[i] and wv_obs lt i14coeff.lambda[i]*(1.+z))
        tag=where(lsinrange and wv_obs lt 3.0*i14coeff.lambda[i])
        if  tag[0] ne -1 then begin
            tau_dla_ls[tag]=tau_dla_ls[tag]+i14coeff.dlaj1[i]*(wv_obs[tag]/i14coeff.lambda[i])^2.0
        endif
        tag=where(lsinrange and wv_obs ge 3.0*i14coeff.lambda[i])
        if  tag[0] ne -1 then begin
            tau_dla_ls[tag]=tau_dla_ls[tag]+i14coeff.dlaj2[i]*(wv_obs[tag]/i14coeff.lambda[i])^3.0
        endif
    endfor
    
    lambda_lim=911.8
    
    tau_laf_lc=wv_obs*0.0
    if  z lt 1.2 then begin
        tag=where(wv_obs lt lambda_lim*(1.+z) and wv_obs gt 0.0)
        if  tag[0] ne -1 then begin
            tau_laf_lc[tag]=tau_laf_lc[tag]+0.325*( (wv_obs[tag]/lambda_lim)^1.2-(1.+z)^(-0.9)*(wv_obs[tag]/lambda_lim)^2.1 )
        endif
    endif
    if  z ge 1.2 and z lt 4.7 then begin
        tag=where(wv_obs gt 0.0 and wv_obs lt 2.2*lambda_lim)
        if  tag[0] ne -1 then begin
            tau_laf_lc[tag]=2.55e-2*(1.+z)^1.6*(wv_obs[tag]/lambda_lim)^2.1+0.325*(wv_obs[tag]/lambda_lim)^1.2-0.25*(wv_obs[tag]/lambda_lim)^2.1
        endif
        tag=where(wv_obs ge 2.2*lambda_lim and wv_obs lt lambda_lim*(1.+z))
        if  tag[0] ne -1 then begin
            tau_laf_lc[tag]=2.55e-2*( (1.+z)^1.6*(wv_obs[tag]/lambda_lim)^2.1-(wv_obs[tag]/lambda_lim)^3.7 )
        endif
    endif
    if  z ge 4.7 then begin
        tag=where(wv_obs gt 0.0 and wv_obs lt 2.2*lambda_lim)
        if  tag[0] ne -1 then begin
            tau_laf_lc[tag]=5.22e-4*(1.+z)^3.4*(wv_obs[tag]/lambda_lim)^2.1+0.325*(wv_obs[tag]/lambda_lim)^1.2-3.14e-2*(wv_obs[tag]/lambda_lim)^2.1
        endif
        tag=where(wv_obs ge 2.2*lambda_lim and wv_obs lt 5.7*lambda_lim)
        if  tag[0] ne -1 then begin
            tau_laf_lc[tag]=5.22e-4*(1.+z)^3.4*(wv_obs[tag]/lambda_lim)^2.1+0.218*(wv_obs[tag]/lambda_lim)^2.1-2.55e-2*(wv_obs[tag]/lambda_lim)^3.7
        endif
        tag=where(wv_obs ge 5.7*lambda_lim and wv_obs lt lambda_lim*(1.+z))
        if  tag[0] ne -1 then begin
            tau_laf_lc[tag]=5.22e-4*( (1.+z)^3.4*(wv_obs[tag]/lambda_lim)^2.1-(wv_obs[tag]/lambda_lim)^5.5 )
        endif
    endif
    
    tau_dla_lc=wv_obs*0.0
    if  z lt 2.0 then begin
        tag=where(wv_obs gt 0.0 and wv_obs lt lambda_lim*(1.+z))
        if  tag[0] ne -1 then begin
            tau_dla_lc[tag]=0.211*(1.+z)^2.0-7.66e-2*(1.+z)^2.3*(wv_obs[tag]/lambda_lim)^(-0.3)-0.135*(wv_tag[tag]/lambda_lim)^2.0
        endif
    endif
    if  z ge 2.0 then begin
        tag=where(wv_obs gt 0.0 and wv_obs lt lambda_lim*3.0)
        if  tag[0] ne -1 then begin
            tau_dla_lc[tag]=0.634+4.7e-2*(1.+z)^3.0-1.78e-2*(1.+z)^3.3*(wv_obs[tag]/lambda_lim)^(-0.3)-0.135*(wv_obs[tag]/lambda_lim)^2.0-0.291*(wv_obs[tag]/lambda_lim)^(-0.3)
        endif
        tag=where(wv_obs gt 0.0 and wv_obs ge lambda_lim*3.0 and wv_obs lt lambda_lim*(1.+z))
        if  tag[0] ne -1 then begin
            tau_dla_lc[tag]=4.7e-2*(1.+z)^3.0-1.78e-2*(1.+z)^3.3*(wv_obs[tag]/lambda_lim)^(-0.3)-2.92e-2*(wv_obs[tag]/lambda_lim)^3.
        endif
    endif
    
    igmtau=tau_dla_lc+tau_laf_lc+tau_dla_ls+tau_laf_ls

endif


return,igmtau

END

PRO TEST_CALC_IGMTAU

wave=findgen(1200)+600
zz=3.0
tau_m95=calc_igmtau(wave*(1.+zz),zz,model='M95')
tau_m95lm=calc_igmtau(wave*(1.+zz),zz,model='M95LM')
tau_m06=calc_igmtau(wave*(1.+zz),zz,model='M06')
tau_i14=calc_igmtau(wave*(1.+zz),zz,model='I14')

plot,wave*(1.+zz),wave*0.0,yrange=[0,1.2],/nodata,xrange=[3000,6000]
oplot,[912,912]*(1.+zz),[0,2]
oplot,[650,650]*(1.+zz),[0,2]
oplot,[610,610]*(1.+zz),[0,2]
oplot,wave*(1.+zz),exp(-tau_m95),color=cgcolor('red')
oplot,wave*(1.+zz),exp(-tau_m95lm),color=cgcolor('yellow')
oplot,wave*(1.+zz),exp(-tau_m06),color=cgcolor('blue')
oplot,wave*(1.+zz),exp(-tau_i14),color=cgcolor('white')

al_legend,['M95','M95LM','M06','I14'],textc=['red','yellow','blue','white'],linestyle=replicate(0,4),color=['red','yellow','blue','white'],/bot,/right,box=0


END