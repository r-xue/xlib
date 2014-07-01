FUNCTION APDR_CAL_SSFUN,nh2,b=b,sigma=sigma,nodust=nodust

x=nh2/5d14
s=0.965/(1.+x/b)^2+0.035/(1.+x)^0.5*exp(-8.5d-4*(1.+x)^0.5)
if not keyword_set(nodust) then s=double(s*exp(-sigma*2.*nh2))
return,s
    
END

FUNCTION APDR_CAL_NRIUV,NH2,NHI,sigma=sigma

if  not keyword_set(sigma) then sigma=1.9d-21


left=(exp(sigma*10.^NHI)-1.0)/sigma

x=10d^(dindgen(2400)*0.01)
y=APDR_CAL_SSFUN(x,b=5.0,sigma=sigma)

d=nh2*0.0
for i=0,n_elements(nh2)-1 do begin
    tmp=min(abs(alog10(x)-nh2[i]),tag)
    if  tag[0] ne 0 then begin
        z=tsum(x,y,0,tag)
        d[i]=z*5.8e-11/left[i]
    endif else begin
        d[i]=0.0
    endelse
endfor

return,d
END


PRO APDR_CAL_NRIUV_ERROR,nh2m,nhim,sigma=sigma,z0=z0,pt=pt
;+
;   use nh2/nhi/n4/n0 to derive iuv
;-


if not keyword_set(sigma) then sigma=1.9d-21

nsamp=1000
nh2=nh2m[0]
nh2v=nh2+randomn(seed,nsamp)*nh2m[1]
nhi=nhim[0]
nhiv=nhi+randomn(seed,nsamp)*nhim[1]


z=apdr_cal_nriuv(nh2v,nhiv,sigma=sigma)
z0=apdr_cal_nriuv(nh2,nhi,sigma=sigma)

pt=cgpercentiles(z,percentiles=[0.159,0.5,0.841])
;print,z0
;print,pt

;h=HISTOGRAM(z, BINSIZE=0.2, LOCATIONS=hlocs)
;plot,hlocs,h,psym=10
;oplot,[z0,z0],[0,1000],color=cgcolor('red')
;oplot,[1,1]*pt[0],[0,1000],color=cgcolor('yellow')
;oplot,[1,1]*pt[1],[0,1000],color=cgcolor('yellow')
;oplot,[1,1]*pt[2],[0,1000],color=cgcolor('yellow')

END


