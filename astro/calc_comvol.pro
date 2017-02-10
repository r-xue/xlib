function redvol,z

red,omega0=0.27,omegalambda=0.73,h100=0.7
forward_function dvcomoving
return,dvcomoving(z,/Mpc)

end

FUNCTION CALC_COMVOL,z1,z2,AREA

;com_vol in 10^6 h_70^-3 mpc^3
;area in degree^2.0
    
red,omega0=0.27,omegalambda=0.73,h100=0.7
forward_function dvcomoving


deg2sr    = (180.d0/!dpi)^2 ; deg^2/sr
com_vol=area/deg2sr*qromb('redvol',z1,z2,/double)/1e6

;com_los=dcomovinglos(z2)/1e6-dcomovinglos(z1)/1e6
;dps=DCOMOVINGTRANSVERSE((z1+z2)/2.0)*!dpi/(180.*60*60)
;com_area=(dps*60.*60./1e6)^2.0*area
;com_vol=com_area*com_los/1e6
;com_vol=nvol(3.06,3.12)*0.20*3600./1e6 

return,com_vol

END



FUNCTION WV2Z_LYA,cw,dw,area

z=[cw+dw*0.5,cw-dw*0.5]/1216.0-1.
zdz=[(z[0]+z[1])/2.0,(z[0]-z[1])]
print,zdz
print,calc_comvol(zdz[0]-zdz[1]*0.5,zdz[0]+zdz[1]*0.5,area)


END
