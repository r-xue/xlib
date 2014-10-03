FUNCTION RDSPEC,mc_spec,rebin=rebin,norm=norm,baserange=baserange


x=mc_spec.v
y=mc_spec.f
type=mc_spec[0].ctype

if mc_spec[0].ctype eq 'VELO-LSR' $
    or mc_spec[0].ctype eq 'VELO-LSRK' then begin
    helio2lsr,0.0,dframe,ra=mc_spec.ra,dec=mc_spec.dec,/kin
    x=x-dframe
    print,mean(dframe)
endif

if  keyword_set(rebin) then begin
    x=frebin(x,fix(n_elements(x)/rebin))
    y=frebin(y,fix(n_elements(y)/rebin))
endif
if  keyword_set(norm) then begin
    y=y/max(y,/nan)*float(norm)
endif
if  keyword_set(baserange) then begin
    tag=[]
    for i=0,n_elements(baserange)/2-1 do begin
        tag=[tag,where(x le baserange[i*2+1] and x ge baserange[i*2],/null)]
    endfor
    blevel=mean(y[tag])
    print,'base level:',blevel
    y=y-blevel
endif


return,{v:x,f:y,type:type}

END
