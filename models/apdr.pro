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

PRO APDR,NH2,NH1,z=z,niuv=niuv,b=b,plot=plot
!except=1
; 1D slab / beamed UV field from one side / DB97 H2 self shielding function

if  not keyword_set(z) then z=1d            ; metallicity
if  not keyword_set(niuv) then niuv=10d     ; n/iuv
if  not keyword_set(b) then b=5d            ; b value

b=5
r=3d-17*z
sigma=1.9d-21*z
dn=5.8d-11/niuv

nh2=10d^(dindgen(2400)*0.01)
tag=where(nh2 eq 10.^25)
y=APDR_FUN(nh2,b=b,sigma=sigma)
int=nh2*0.0
for i=1,n_elements(nh2)-1 do begin
    s=tsum(nh2,y,0,i)
    int[i]=s
endfor
nh1=alog(int*dn/r*sigma+1.0)/sigma

if  keyword_set(plot) then begin
    window,0,xsize=500,ysize=500
    plot,nh1,nh2,/xlog,/ylog,thick=5,yrange=[10.^13,10.^23],ystyle=1,xrange=[10.^19,10.^23]
endif

END


PRO TEST_APDR

apdr,nh2,nh1,/plot,niuv=30

END




