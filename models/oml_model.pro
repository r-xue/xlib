; This function will calculation the predicted molecular fraction
; for a given pair of metalicity z' and total H column density
; 
; KM's Z' definition:
;   log Z′ = [log(O/H) + 12] − 8.76.
; 
;

; u= 1.27 or 1.39 (2.34/1.67372) being the mean molecular weight per particle

FUNCTION oml_model_eq,sigdif,siggas=siggas,rhosd=rhosd,z=z

alpha=5.
sig0=10.
sigsfr0=2.5e-9
fw=0.5


tdep=2e9
sigsfr=(siggas-sigdif)/tdep
y=4.*sigsfr/sigsfr0*(1.0)/(1.0+3.1*(siggas*z/sig0)^0.365)
siggbc=siggas-sigdif
eqn=9.5*alpha*y/(0.11*siggbc+(0.011*siggbc^2.0+alpha*y+100.*alpha*fw*rhosd)^0.5)-sigdif

return,eqn

END

FUNCTION OML_MODEL,siggas,rhosd=rhosd,z=z


if  n_elements(rhosd) eq 0 then rhosd=siggas*5.5/700.
if  n_elements(z) eq 0 then z=replicate(1.0,n_elements(siggas))
if  n_elements(z) eq 1 then z=replicate(z,n_elements(siggas))
if  n_elements(rhosd) eq 1 then rhosd=replicate(rhosd,n_elements(siggas))
siggas=siggas*1.36

sigdif=[]
for i=0,n_elements(siggas)-1 do begin
    ;print,i
    sigdif=[sigdif,zbrent(0.00,siggas[i],func_name='oml_model_eq',$
        siggas=siggas[i],rhosd=rhosd[i],z=z[i])]
endfor

sigdif=sigdif/1.36

return,sigdif

END

PRO TEST_OML_MODEL_PLOT

siggas=10.^(findgen(500)*0.01-2.0)
rhosd=replicate(10,1000)
sigdif=oml_model(siggas,rhosd=rhosd,z=1.0)

plot,siggas,sigdif,/xlog,/ylog,$
    xrange=[1,900],xstyle=1,$
    yrange=[1,100],ystyle=1,/nodata

rhosd=replicate(10,1000)
sigdif=oml_model(siggas,rhosd=10.0,z=1.0)
oplot,siggas,sigdif,color=cgcolor('red'),linestyle=2
sigdif=oml_model(siggas,rhosd=1.0,z=1.0)
oplot,siggas,sigdif,color=cgcolor('blue'),linestyle=2
sigdif=oml_model(siggas,rhosd=10.0,z=0.2)
oplot,siggas,sigdif,color=cgcolor('red')
sigdif=oml_model(siggas,rhosd=1.0,z=0.2)
oplot,siggas,sigdif,color=cgcolor('blue')


END


PRO TEST_OML_MODEL
siggas=100
rhosd=20
z=1.0
sigdif=oml_model(siggas,rhosd=rhosd,z=1.0)
print,((siggas-sigdif)/siggas)[0]
;plot,siggas,(siggas-sigdif)/siggas,/xlog

siggas=100
rhosd=200
z=1.0
sigdif=oml_model(siggas,rhosd=rhosd,z=1.0)
print,((siggas-sigdif)/siggas)[0]
;oplot,siggas,(siggas-sigdif)/siggas,color=cgcolor('red')
;print,((siggas-sigdif)/siggas)[0]

END