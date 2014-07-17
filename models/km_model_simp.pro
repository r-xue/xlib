; This function will calculation the predicted molecular fraction
; for a given pair of metalicity z' and total H column density
; 
; KM's Z' definition:
;   log Z′ = [log(O/H) + 12] − 8.76.
; 
;

; u= 1.27 or 1.39 (2.34/1.67372) being the mean molecular weight per particle
function km_model_simp,metal,phi
zm=metal
kai=3.1/phi*3*(1+3.1*zm^0.365)/4.1
hi_nodust= (8.8/metal/phi*3.*(1.0+3.1*zm^0.365)/4.1)
hi_withdust0=(alog(1.+kai)/(1./4.*kai)*hi_nodust)/2.34*1.67
hi_withdust=1.67e-3/metal*alog(1.+kai)*3.086^2./1.99*1000.0
;print, hi_nodust, hi_withdust, hi_withdust0
return,hi_withdust
End