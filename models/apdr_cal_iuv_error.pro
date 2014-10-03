FUNCTION APDR_CAL_SSFUN,nh2,b=b,sigma=sigma,nodust=nodust

x=nh2/5d14
s=0.965/(1.+x/b)^2+0.035/(1.+x)^0.5*exp(-8.5d-4*(1.+x)^0.5)
if not keyword_set(nodust) then s=double(s*exp(-sigma*2.*nh2))
return,s
    
END

FUNCTION APDR_CAL_IUV,NH2org,NHIorg,N4org,N0org,sigma=sigma

if  not keyword_set(sigma) then sigma=1.9d-21

dorg=findgen(n_elements(nh2org))*!values.f_nan
tt=where(nh2org eq nh2org and nhiorg eq nhiorg and n4org eq n4org and n0org eq n0org)

if tt[0] ne -1 then begin
    
    n4=n4org[tt]
    n0=n0org[tt]
    nhi=nhiorg[tt]
    nh2=nh2org[tt]

rn=2.75e-9*10.^(n4-nhi)/(2.36*10.^(n0-nh2)+0.19)
left=rn*(exp(sigma*10.^NHI)-1.0)/sigma

x=10d^(dindgen(2400)*0.01)
y=APDR_CAL_SSFUN(x,b=5.0,sigma=sigma)

d=nh2*0.0
for i=0,n_elements(nh2)-1 do begin
    tmp=min(abs(alog10(x)-nh2[i]),tag)
    if  tag[0] ne 0 then begin
        z=tsum(x,y,0,tag)
        d[i]=left[i]/z/5.8e-11
    endif else begin
        d[i]=0.0
    endelse
endfor

dorg[tt]=d
endif

return,dorg
END


FUNCTION APDR_CAL_IUV_ERROR,nh2m,nhim,n4m,n0m,sigma=sigma,z0=z0,pt=pt
;+
;   use nh2/nhi/n4/n0 to derive iuv
;-
;nh2m=[19.83,0.1]
;nhim=[21.81,0.1]
;n4m=[14.58,0.2]
;n0m=[19.7,0.1]
if not keyword_set(sigma) then sigma=1.9d-21

nsamp=1000
nh2v=nh2m.value+randomn(seed,nsamp)*nh2m.limits[0]
nhiv=nhim.value+randomn(seed,nsamp)*nhim.limits[0]
n4v=n4m.value+randomn(seed,nsamp)*n4m.limits[0]
n0v=n0m.value+randomn(seed,nsamp)*n0m.limits[0]

z=apdr_cal_iuv(nh2v,nhiv,n4v,n0v,sigma=sigma)
z0=apdr_cal_iuv(nh2m.value,nhim.value,n4m.value,n0m.value,sigma=sigma)

ms={value:!values.f_nan,limited:!values.f_nan,limits:[!values.f_nan,!values.f_nan]}
pt=cgpercentiles(z,percentiles=[0.159,0.5,0.841])
ms.limits=[z0-pt[0],pt[2]-z0]
ms.value=z0
return,ms
;print,z0
;print,pt

;h=HISTOGRAM(z, BINSIZE=0.2, LOCATIONS=hlocs)
;plot,hlocs,h,psym=10
;oplot,[z0,z0],[0,1000],color=cgcolor('red')
;oplot,[1,1]*pt[0],[0,1000],color=cgcolor('yellow')
;oplot,[1,1]*pt[1],[0,1000],color=cgcolor('yellow')
;oplot,[1,1]*pt[2],[0,1000],color=cgcolor('yellow')


END


