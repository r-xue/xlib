FUNCTION BR6_MODEL_EQ,sigdif,siggbc=siggbc,sgr=sgr,vg=vg,hs=hs

eqn=272*(sigdif+siggbc)^1.5*(sgr)^0.5*vg*hs^(-0.5)
eqn=(eqn/4.3e4)^0.92
eqn=eqn-siggbc/sigdif

return, eqn

END

FUNCTION BR6_MODEL,siggbc,sgr=sgr,hs=hs,vg=vg

if  n_elements(vg) eq 0 then vg=8.0
if  n_elements(hs) eq 0 then hs=700

sigdif=[]
for i=0,n_elements(siggbc)-1 do begin
    sigdif=[sigdif,zbrent(0.01,10000,func_name='BR6_MODEL_EQ',$
        siggbc=siggbc[i],sgr=sgr[i],hs=hs,vg=vg)]
endfor
return,sigdif

END

PRO TEST_BR6_MODEL

x=10.^[findgen(39)*0.1-1]
y=br6_model(replicate(200,39),sgr=x,hs=700,vg=8)
y1=br6_model(replicate(3,39),sgr=x,hs=700,vg=8)
plot,x,y,/xlog,/ylog
oplot,x,y1

END