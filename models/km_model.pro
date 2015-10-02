; This function will calculation the predicted molecular fraction
; for a given pair of metalicity z' and total H column density
; 
; KM's Z' definition:
;   log Z′ = [log(O/H) + 12] − 8.76.
; 
;

; u= 1.27 or 1.39 (2.34/1.67372) being the mean molecular weight per particle
function km_model,xmodel,metal,phi
;phi=3->10
; xmodel is the surface density of Sigma H total
  zm=metal
  tauc=0.093563*xmodel*zm
  kai=3.1/phi*3*(1+3.1*zm^0.365)/4.1
  s=alog(1.0+0.6*kai+0.01*kai^2.0)/0.6/tauc
  fh2_mckee=1.0-(3.0/4.0)*s/(1+0.25*s)
  fh2_mckee=fh2_mckee>0.0
  return, fh2_mckee
End

PRO TEST_KM_MODEL

xmodel=indgen(100000)*0.001
plot,xmodel,km_model(xmodel,1.0,3.0)

END