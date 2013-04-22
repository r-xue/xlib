FUNCTION BINOMIAL_ERR, v,n,round=round,cf_level=cf_level

sig=fltarr(n_elements(v),2)
if n_elements(cf_level) eq 0 then cf_level=0.1

for i=0,n_elements(v)-1 do begin
  
  if n[i] eq 0 then begin
    sig[i,*]=[0.0,0.0]
    continue
  endif
  pmean=v[i]*1d/n[i]
  
  p=0.001*findgen(999)+0.001
  lf=binomial_likelihood(v[i],n[i],p,/normal)
  cdf=total(lf,/cum,/nan)/total(lf,/nan)
;  plot,p,cdf,xrange=[-1.0,2.0],xstyle=1
;  ;oplot,p,lf,color=cgcolor('red')
  
 
  out=1.-cf_level
  
  if v[i] eq n[i] then begin
    pmax=1.0
       tag=where(cdf-out le 0.0)
    pmin=p[tag[-1]]
  endif
  if v[i] eq 0 then begin
    pmin=0.0
    tag=where(out-(1.-cdf) ge 0.0)
    pmax=p[tag[0]]
  endif
  if v[i] ne 0 and v[i] ne n[i] then begin
    tag=where(cdf-out/2. le 0.0)
    pmin=p[tag[-1]]
    tag=where(out/2.0-(1.-cdf) ge 0.0)
    pmax=p[tag[0]]
  endif
  
  if keyword_set(round) then begin
    pmin=floor(n[i]*pmin)*1d/n[i]
    pmax=ceil(n[i]*pmax)*1d/n[i]
  endif
  pmax=pmax>pmean
  pmin=pmin<pmean
  
  sig[i,*]=[pmean-pmin,pmax-pmean]
  ;print,"*",i,n[i],v[i],pmean, pmin,pmax
endfor
return,sig

END

PRO TEST_BINOMIAL_ERR

v=[3,0,160928,2,402266,140547]
n=[5,1000,161131,2, 435786,140556]
print,v*1d/n
print,''
x=binomial_err(v,n)


;print,
;print,''
;print,binomial_err(v,n,/round)
END