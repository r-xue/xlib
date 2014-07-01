FUNCTION APDR_CAL_NR,NH2,NHI,N4,N0

rn=2.75e-9*10.^(n4-nhi)/(2.36*10.^(n0-nh2)+0.19)
return,rn

END

PRO APDR_CAL_NR_ERROR,nh2m,nhim,n4m,n0m,z0=z0,pt=pt
;+
;   use nh2/nhi/n4/n0 to derive iuv
;-

nsamp=1000
nh2=nh2m[0]
nh2v=nh2+randomn(seed,nsamp)*nh2m[1]
nhi=nhim[0]
nhiv=nhi+randomn(seed,nsamp)*nhim[1]
n4=n4m[0]
n4v=n4+randomn(seed,nsamp)*n4m[1]
n0=n0m[0]
n0v=n0+randomn(seed,nsamp)*n0m[1]

z=apdr_cal_nr(nh2v,nhiv,n4v,n0v)
z0=apdr_cal_nr(nh2,nhi,n4,n0)


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

