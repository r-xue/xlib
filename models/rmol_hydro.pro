PRO RMOL_HYDRO,n1,n2,v=v,h=h,sigs=sigs
;+
;   this is emperically relation between R_mol and Hydrostatic pressured based on some observational evidence.
;-

if not keyword_set(v) then v=8.
if not keyword_set(h) then h=0.30*1000.
sig_g=10.0^(findgen(1000)*0.01-2.)
if  keyword_set(sigs) then begin
    sig_s=sigs
endif else begin
    sig_s=sig_g*5.
endelse

pk=272.*sig_g*sig_s^0.5*v*h^(-0.5)
rmol=(pk/4.3e4)^0.92

sig_n2=sig_g/(rmol+1.)*rmol
sig_n1=sig_g/(rmol+1.)*1.0

n2=sig_n2*(1.67/2.3)/8.00635e-21/2.0
n1=sig_n1*(1.67/2.3)/8.00635e-21


END