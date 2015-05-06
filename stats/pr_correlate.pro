FUNCTION PR_CORRELATE,xvec,yvec,cvec
;+
;   calculate partial rank correlation coefficient
;-


pXY = R_CORRELATE(xVec, yVec)
pxy=pxy[0]
pXC = R_CORRELATE(xVec, cVec)
pxc=pxc[0]
pYC = R_CORRELATE(yVec, cVec)
pyc=pyc[0]

result = ((pXC ne 1) and (pYC ne 1)) ? $
    (pxY - pXC*pYC)/SQRT((1. - pXC^2)*(1. - pYC^2)) : 0d

return,result


END


PRO TEST_PR_CORRELATE

x=indgen(10)+randomu(seed,10)*2.0
y=indgen(10)*0.2+randomu(seed,10)*2.0

plot,x,y,psym=symcat(16)

print,(r_correlate(x,-y))[0]
c=indgen(10)
print,(r_correlate(y,x))[0]
c=indgen(10)
print,pr_correlate(x,y,c)
c=indgen(10)*0.0+0.1*randomu(seed,10)*0.1
print,pr_correlate(x,y,c)
c=indgen(10)*randomu(seed,10)*2
print,pr_correlate(x,y,c)

END