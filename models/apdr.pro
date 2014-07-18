FUNCTION APDR_FUN,nh2,b=b,sigma=sigma,nodust=nodust,sqrt=sqrt
;+
;   nodust: no h2-dust extinction term
;   sqrt:   using the sqrt function
;-
x=nh2/5d14
s=0.965/(1.+x/b)^2+0.035/(1.+x)^0.5*exp(-8.5d-4*(1.+x)^0.5)
if keyword_set(sqrt) then s=double(4.2e5/sqrt(nh2))
if not keyword_set(nodust) then s=double(s*exp(-sigma*2.*nh2))
return,s

END

PRO APDR,NH2,NH1,z=z,niuv=niuv,b=b,plot=plot,side1=side1,iso=iso,geo=geo
!except=1
; 1D slab / beamed UV field from one side / DB97 H2 self shielding function

if  not keyword_set(z) then z=1d            ; metallicity
if  not keyword_set(niuv) then niuv=10d     ; n/iuv
if  not keyword_set(b) then b=5d            ; b value
if  not keyword_set(geo) then geo='slab'    ; 'slab','spheric','complex'

b=5
r=3d-17*z
sigma=1.9d-21*z
if  keyword_set(side1) then scale=1.0 else scale=2.0
dn=5.8d-11/niuv

nh2=10d^(dindgen(2400)*0.01)
tag=where(nh2 eq 10.^25)
y=APDR_FUN(nh2,b=b,sigma=sigma)
int=nh2*0.0
for i=1,n_elements(nh2)-1 do begin
    s=tsum(nh2,y,0,i)
    int[i]=s
endfor
ag=int*dn/r*sigma
nh1=alog(ag*0.5+1.0)/sigma*scale
if  keyword_set(iso) then begin
    ; eqvilent with increasing sigma by 1.25 and decrease D/n by 0.5
    mu=0.8
    nh1=alog(0.5*0.5*ag/mu+1.0)/(sigma)*mu*scale
endif

if  keyword_set(plot) then begin
    window,0,xsize=500,ysize=500
    plot,nh1,nh2,/xlog,/ylog,thick=5,yrange=[10.^13,10.^23],ystyle=1,xrange=[10.^19,10.^23]
endif

;   optically thick cases....
nht=2.0*nh2+nh1
y=nht/nh1
if  geo eq 'spheric' then begin
    fh2s=1.-1.5/(y+0.5*y^(-1.8))    ; Equation 100
    nh1=nht*(1-fh2s)
    nh2=nht*fh2s/2.0
endif
if  geo eq 'complex' then begin
    fh2c=1.-1.5/(y+0.5)             ; Equation 102
    nh1=nht*(1-fh2c)
    nh2=nht*fh2c/2.0
endif

END


PRO TEST_APDR

apdr,nh2f,nh1f,niuv=30,geo='slab'
apdr,nh2fz,nh1fz,niuv=30,geo='slab',z=0.2
apdr,nh2c,nh1c,niuv=30,geo='complex'
apdr,nh2s,nh1s,niuv=30,geo='spheric'
plot,[1],[1],/xlog,/ylog,thick=5,yrange=[10.^13,10.^23],ystyle=1,xrange=[10.^19,10.^23]
oplot,nh1f,nh2f,thick=5,color=cgcolor('blue')
oplot,nh1fz,nh2fz,thick=5,color=cgcolor('blue'),linestyle=1
oplot,nh1c,nh2c,thick=5,color=cgcolor('green')
oplot,nh1s,nh2s,thick=5,color=cgcolor('red')
END




