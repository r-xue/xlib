PRO GNEDIN,u=u,dgr_mw=dgr_mw,l=l,sig_h2=sig_h2,sig_h1=sig_h1
;+
;   R_modl prediction from Gnedin & Draine 2014
;   
;   they get the 3D model with n-N relation built in
;   then add a fix UV and field and derive R_mol
;   This is different from Krumholz with is assuming G/n is constant.
;   but it's the same stratgegy:
;       we need G/n,N to solve R_modl, to reduce the parameter, we have to implement G/n (from Wolfire) or n-N relations (from simulations)
;-

if  not keyword_set(u) then u=1.0
if  not keyword_set(dgr_mw) then dgr_mw=1.0
if  not keyword_set(l) then l=1000.0


s=l/100.

d_star=0.17*(2.+s^5)/(1.+s^5)
g=(dgr_mw^2.0+d_star^2.0)^0.5
sig_r1=50./g*(0.01+u)^0.5/(1.+0.69*(0.01+u)^0.5)
alpha=0.5+1.0/(1.0+sqrt(u*dgr_mw^2.0/600))

sig_tt=findgen(100000)*0.1+0.0
r_mol=(sig_tt/sig_r1)^alpha

sig_h1=sig_tt*1./(1.+r_mol)
sig_h2=sig_tt*r_mol/(1.+r_mol)

if keyword_set(plot) then plot,sig_h1,sig_h2


END

PRO TEST_GNEDIN

window,1,xsize=500,ysize=500
plot,[0.1,100],[0.1,1000],/xlog,/ylog,xstyle=1,ystyle=1

GNEDIN,l=500,sig_h2=sig_h2,sig_h1=sig_h1
oplot,sig_h1,sig_h2
GNEDIN,l=500,sig_h2=sig_h2,sig_h1=sig_h1,dgr_mw=0.5
oplot,sig_h1,sig_h2,color=cgcolor('blue')
GNEDIN,l=500,sig_h2=sig_h2,sig_h1=sig_h1,u=1000
oplot,sig_h1,sig_h2,color=cgcolor('red')

END