FUNCTION XGAUFIT_MAKEGAUSS,x,p
;+
;   p is a vector with a lenth of 3*n+2
;   2   for linear baseline
;   3*n for n Gaussian profile
;-
np=n_elements(p)/3
y=p[0]+p[1]*x
for i=0,np-1 do begin
    y=y+gaussian(x,p[i*3+0+2:i*3+2+2])
endfor

if check_math(0,0) eq 32 then junk = check_math(1,1)
return,y
    
END


FUNCTION XGAUFIT,x,y,yerr=yerr,$
    ncmax=ncmax,fwhm=fwhm,xres=xres,$
    method_findpeak=method_findpeak

;+
;   fit a spectral line with a combination of mutiple Gaussian profiles.
;   return a list of strcutures: each structure contains the information for one test fitting
;   with a specific number of components 
;   
;   ref: http://ifs.wikidot.com/pan
;   ***currently, we don't fit a and b***
;-
!except=1
if n_elements(yerr) eq 1 then yerror=replicate(yerr,n_elements(x))
if n_elements(yerr) eq 0 then yerror=replicate(robust_sigma(y,/zero),n_elements(x))
if n_elements(yerr) gt 1 then yerror=yerr
if n_elements(xres) eq 0 then xres=abs(x[0]-x[1])
if n_elements(ncmax) eq 0 then ncmax=5
if n_elements(fwhm) eq 0 then fwhm=2.0*xres
if n_elements(method_findpeak) eq 0 then method_findpeak=0

; method_findpeak=0: find peaks at one time from the orginal spectral
; method_findpeak=1: find peaks iteratively using residual

xp=find_npeaks(y,nfind=ncmax,width=3,minsep=0)
xp=round(xp)
npeak=n_elements(xp)
if  method_findpeak eq 0 then ncmax=npeak

; LOOP OVER FITTING WITH DIFFERENT NUMBER OF COMPONENTS
print,'++++xgaufit++++'
results=list()
start=[0.,0.]
foreach usenc,indgen(ncmax)+1 do begin

    if  method_findpeak eq 0 then begin
        start=[start,abs(y[xp[usenc-1]])/1.0>3.0*abs(yerror[xp[usenc-1]]),x[xp[usenc-1]],fwhm]
    endif
    if  method_findpeak eq 1 then begin
        if usenc eq 1 then xpres=xp[0]
        start=[start,abs(y[xpres])/1.0>3.0*median(yerror),x[xpres],fwhm]
    endif
    start=double(start)

    parinfo=replicate( { $
        parname:"",$
        value:double(0.),$
        limits:double([0.,0.]),$
        fixed:0,$
        limited:[1,1],$
        tied:'',$
        mpmaxstep:double(0.),$
        MPMINSTEP:double(0.),$
        step:double(0.),$
        relstep:double(0.),$
        scale:double(1.0),$
        mpside:2},usenc*3+2)
    parinfo.value=start
    parinfo[0].parname='a'
    parinfo[1].parname='b'
    parinfo[0].limits=[0.,0.]
    parinfo[1].limits=[0.,0.]
    parinfo[0].limited=[0.,0.]
    parinfo[1].limited=[0.,0.]
    parinfo[0].step=0.0
    parinfo[1].step=0.0
    parinfo[0].fixed=1.0
    parinfo[1].fixed=1.0        
    for k=0,usenc-1 do begin
        parinfo[k*3+0+2].parname='peak'
        parinfo[k*3+1+2].parname='center'
        parinfo[k*3+2+2].parname='sigma'
        parinfo[k*3+0+2].limits=[1.0*median(yerror),0.]
        parinfo[k*3+1+2].limits=[0.,0.]
        parinfo[k*3+2+2].limits=[xres/2.634,0.]
        parinfo[k*3+0+2].limited=[1.,0.]
        parinfo[k*3+1+2].limited=[0.,0.]
        parinfo[k*3+2+2].limited=[1.,0.]
        parinfo[k*3+0+2].step=median(yerror)
        parinfo[k*3+1+2].step=xres
        parinfo[k*3+2+2].step=xres/2.634
    endfor
;    print,parinfo.value
;    print,parinfo.limits
    par=mpfitfun('XGAUFIT_MAKEGAUSS',double(x),double(y),double(yerror),start,$
        perror=perror,dof=dof,bestnorm=chisq,parinfo=parinfo,/double,/quiet,$
        weights=1./yerror^2.0)
    pare=PERROR*SQRT(chisq/DOF)

    
    signif=!values.f_nan
    if  n_elements(results) gt 0 then begin
        signif=mpftest((results[-1].chisq/results[-1].dof)/(chisq/dof),results[-1].dof,dof,/sigma)
    endif

    print,'use initial guess peaks @:',parinfo[where(parinfo.parname eq 'center')].value
    print,'fitting with '+strtrim(usenc)+' Gaussian'
    print,dof,chisq,chisq/dof,signif
    
    ymod=fltarr(n_elements(x),usenc+2)
    xmod=x
    ymod[*,0]=par[0]+par[1]*x
    for i=1,usenc do begin
        ymod[*,i]=xgaufit_makegauss(x,[0.0,0.0,par[i*3-1:i*3+1]])
    endfor
    ymod[*,-1]=xgaufit_makegauss(x,par)
    yres=y-ymod[*,-1]
    xpres=find_npeaks(yres,nfind=1,width=3.0,minsep=0)

    result={nc:usenc,par:par,pare:pare,parinfo:parinfo,dof:dof,chisq:chisq,signif:signif,xmod:xmod,ymod:ymod}
    results.add,result
    
endforeach
print,'----xgaufit----'

return,results
END


PRO TEST_XGAUFIT

im=readfits('SMC_ATCA+PKS.fits',hd)
rd_hd,hd,s=s
im1=im
im2=im

sz=size(im,/d)
for i=0,sz[0]-1 do begin
    for j=0,sz[1]-1 do begin
        
        spec=im[i,j,*]
        plot,s.v,spec
        if  total(spec eq spec) lt n_elements(spec) or total(spec) eq 0  then continue

        results=xgaufit(s.v,spec,ncmax=3,fwhm=2.0)
        bestfit=results[0]
        foreach result,results do begin
            tt='nc='+strtrim(result.nc,2)+' improve:  '+$
                string(result.signif,format='(f7.1)')+textoidl(' \sigma')
            if result.signif gt 5.0 or result.nc eq 1  then begin
                bestfit=result
            endif else begin
                ;break
            endelse
        endforeach
        result=results[1]
        
        cc=['yellow','red','green','blue','cyan']
        prop=[]
        for nn=0,result.nc-1 do begin
            print,'comp:'+strtrim(nn+1,2),result.par[nn*3+2:nn*3+4]
            oplot,result.xmod,result.ymod[*,nn+1],color=cgcolor(cc[nn]),psym=10
            prop=[prop,result.par[nn*3+2]^2.0*result.par[nn*3+4]]
            print,'h2 prop',result.par[nn*3+2]^2.0*result.par[nn*3+4]
            if  nn eq 0 then im1[i,j,*]=result.ymod[*,nn+1]
            if  nn eq 1 then im2[i,j,*]=result.ymod[*,nn+1]
        endfor
        
    endfor
endfor

writefits,'im1.fits',im1
writefits,'im2.fits',im2


END

