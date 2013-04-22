FUNCTION BINOMIAL_LIKELIHOOD,x,n,p,normal=normal
;+
; return the binomial_liklihood function
; make sure 
; p->[0,1]
; n>0
; /normal to avoid
;-

; value in loge is truncated beyond [-50,50]
; 

loglf=total(alog(dindgen(n>1)+1))
loglf=loglf-total(alog(dindgen(x>1)+1))
loglf=loglf-total(alog(dindgen(n-x>1)+1))
out=p-p+loglf

tag=where(p gt 0 and p lt 1.0, /null)
out[tag]=out[tag]+alog(p[tag])*x+(n-x)*alog(1-p[tag])
out=out-max(out)
out=out>(-50.0)
out=exp(out)

;tag=where(p eq 0., /null)
;if x ne 0 then out[tag]=
;tag=where(p eq 1., /null)
;if x ne n then out[tag]=-50.0
;
;print,min(out),max(out)

return,out

END


PRO TEST_BINOMIAL_LIKELIHOOD

r=0.001*findgen(999)+0.001
p=binomial_likelihood(117,264,r)
plot,r,p,xrange=[-1.0,2.0],xstyle=1
;oplot,r,p,color=cgcolor('yellow')
;p=binomial_likelihood(4,30,r)
;oplot,r,p,color=cgcolor('blue'),thick=6
;
;v=4
;n=30
;cdf_ge_v=binomial(v,n,r,/double)
;cdf_gt_v=binomial(v+1,n,r,/double)
;cdf_v=cdf_ge_v-cdf_gt_v
;cdf_lt_v=1.0-cdf_ge_v
;oplot,r,cdf_v,color=cgcolor('red'),thick=3
;
;x=factorial(n)/factorial(n-v)/factorial(v)*r^v*(1-r)^(n-v)
;oplot,r,x,color=cgcolor('yellow')

END