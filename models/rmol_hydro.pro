PRO RMOL_HYDRO,n1,n2,v=v,h=h,sig_s=sig_s,sig_g=sig_g
;+
;   this is emperically relation between R_mol and Hydrostatic pressured based on some observational evidence.
;-

if not keyword_set(v) then v=8.
if not keyword_set(h) then h=0.30*1000.

if  n_elements(sig_s) eq 0 or n_elements(sig_g) eq 0 then begin 
    sig_g=10.0^(findgen(1000)*0.01-2.)
    sig_s=10.0^(findgen(1000)*0.01-2.)*5.5
endif

pk=272.*sig_g*sig_s^0.5*v*h^(-0.5)
rmol=(pk/4.3e4)^0.92

sig_n2=sig_g/(rmol+1.)*rmol
sig_n1=sig_g/(rmol+1.)*1.0

n2=sig_n2*(1.67/2.3)/8.00635e-21/2.0
n1=sig_n1*(1.67/2.3)/8.00635e-21

END


PRO TEST_RMOL_HYDRO

rmol_hydro,n1,n2,v=8,h=700,$
    sig_g=10.0^(findgen(1000)*0.01-2.),$
    sig_s=10.0^(findgen(1000)*0.01-2.)*1.0
n1=n1*8.00635e-21
n2=n2*2.0*8.00635e-21
plot,(n1+n2),n1,/xlog,/ylog

END


FUNCTION BR6_MODEL_EQ,sigdif,siggbc=siggbc,sgr=sgr,vg=vg,hs=hs

eqn=272*(sigdif+siggbc)^1.5*(sgr)^0.5*vg*hs^(-0.5)
eqn=(eqn/4.3e4)^0.92
eqn=eqn-siggbc/sigdif

return, eqn

END

PRO TEST_BR6_MODEL_EQ

print,zbrent(0.01,1000,func_name='BR6_MODEL_EQ',siggbc=100,sgr=1,hs=700.0,vg=8.0)


END