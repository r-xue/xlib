FUNCTION APDR_CAL_NR,NH2,NHI,N4,N0

rn=2.75e-9*10.^(n4-nhi)/(2.36*10.^(n0-nh2)+0.19)
return,rn

END

FUNCTION APDR_CAL_NR_ERROR,nh2m,nhim,n4m,n0m,z0=z0,pt=pt
;+
;   use nh2/nhi/n4/n0 to derive iuv
;-

nsamp=1000
nh2v=nh2m.value+randomn(seed,nsamp)*nh2m.limits[0]
nhiv=nhim.value+randomn(seed,nsamp)*nhim.limits[0]

n4v=n4m.value+randomn(seed,nsamp)*n4m.limits[0]
n0v=n0m.value+randomn(seed,nsamp)*n0m.limits[0]


z=apdr_cal_nr(nh2v,nhiv,n4v,n0v)
z0=apdr_cal_nr(nh2m.value,nhim.value,n4m.value,n0m.value)
ms={value:!values.f_nan,limited:!values.f_nan,limits:[!values.f_nan,!values.f_nan]}
pt=cgpercentiles(z,percentiles=[0.159,0.5,0.841])
ms.limits=[z0-pt[0],pt[2]-z0]
ms.value=z0
;print,'->',ms.value,ms.limits
;print,z0
;print,pt
;h=HISTOGRAM(z, BINSIZE=0.2, LOCATIONS=hlocs)
;plot,hlocs,h,psym=10
;oplot,[z0,z0],[0,1000],color=cgcolor('red')
;oplot,[1,1]*pt[0],[0,1000],color=cgcolor('yellow')
;oplot,[1,1]*pt[1],[0,1000],color=cgcolor('yellow')
;oplot,[1,1]*pt[2],[0,1000],color=cgcolor('yellow')
   
return,ms
END

