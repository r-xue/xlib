.com apdr_cal_nr_error
.com apdr_cal_nriuv_error
.com apdr_cal_iuv_error

; HD 34078
nhi=21.43
nh2=20.82
n0=20.51
n4=17.85
r=3e-17

; HD 96675
;nhi=20.64
;nh2=20.83
;n0=20.69
;n4=15.15
;r=3e-17

; HD 108927
;nhi=20.82
;nh2=20.50
;n0=20.30
;n4=15.16
;r=3e-17

; HD 46056
;nhi=21.38
;nh2=20.68
;n0=20.40
;n4=15.75
;r=3e-17

; HD 147888
;nhi=21.41
;nh2=20.78
;n0=20.49
;n4=15.65
;
;
; HD 102065 PDR OUTPUT
;nhi=20.49
;nh2=20.53
;n0=21.30
;n4=15.78
;
;; HD 147888 PDR OUTPUT 
;nhi=20.18
;nh2=21.44
;n0=21.30
;n4=15.59

; HD 46056 PDR OUTPUT
;fh2=0.901
;nhi=alog10(3.4e21*(1-fh2))
;nh2=alog10(3.4e21*(fh2)/2.0)
;nh0=20.90
;nh4=15.38

; 102065
nhi=20.49
nh2=20.53
n0=21.30
n4=16.26

iuv=APDR_CAL_IUV(NH2,NHI,N4,N0)
nr=APDR_CAL_NR(NH2,NHI,N4,N0)
niuv=APDR_CAL_NRIUV(NH2,NHI)/r
print,iuv
print,nr
print,nr/r

;print,4.3e4*r*n*sqrt((10.^nhi+10.^nh2*2)/fh2)
;print,'--'
;print,iuv,n,niuv,1./niuv
