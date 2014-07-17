PRO RMOL_HYDRO,sig_n1,sig_n2,v=v,h=h
;+
;   this is emperically relation between R_mol and Hydrostatic pressured based on some observational evidence.
;-

v=8.
h=0.30*1000.
sig_g=10.0^(findgen(1000)*0.01-2.)
sig_s=sig_g*5.
pk=272.*sig_g*sig_s^0.5*v*h^(-0.5)
rmol=(pk/4.3e4)^0.92

sig_n2=sig_g/(rmol+1.)*rmol
sig_n1=sig_g/(rmol+1.)*1.0

sig_n2=sig_n2*(1.67/2.3)/8.00635e-21/2.0
sig_n1=sig_n1*(1.67/2.3)/8.00635e-21


END