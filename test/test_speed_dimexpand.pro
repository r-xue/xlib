PRO TEST_SPEED_DIMEXPAND


nmax=long(120000)
nmin=long(1227)
nmax=long(10000)
nmin=long(1000)

print,'>>>'
print,"test1[*,i]=test"
ndim1=long(10000)
ndim2=long(10000)
test=findgen(ndim1)
print,[ndim1,ndim2]

;   this one is slow..because the program has to add each y-level one by one?

delvar,test1
tic
test1=rebin(test,[ndim1,ndim2], /SAMPLE)
toc

delvar,test1
tic
test1=cmreplicate(test,ndim1)
toc

delvar,test1
tic
test1=fltarr(ndim1,ndim2,/nozero)
for i=0,ndim1-1 do begin
    replicate_inplace,test1,test[i],2,[i,0]
endfor
toc

delvar,test1
tic
test1=fltarr(ndim1,ndim2,/nozero)
for i=0,ndim2-1 do begin
    test1[i*ndim1]=test
endfor
toc

print,'>>>'
print,"test1[*,i]=test"
ndim1=nmax
ndim2=nmin
test=findgen(ndim1)
print,[ndim1,ndim2]

;   this one is slow..because the program has to add each y-level one by one?

delvar,test1
tic
test1=rebin(test,[ndim1,ndim2], /SAMPLE)
toc

delvar,test1
tic
test1=cmreplicate(test,ndim2)
toc

delvar,test1
tic
test1=fltarr(ndim1,ndim2,/nozero)
for i=0,ndim1-1 do begin
    replicate_inplace,test1,test[i],2,[i,0]
endfor
toc

delvar,test1
tic
test1=fltarr(ndim1,ndim2,/nozero)
for i=0,ndim2-1 do begin
    test1[i*ndim1]=test
endfor
toc


print,'>>>'
print,"test1[*,i]=test"
ndim1=nmin
ndim2=nmax
test=findgen(ndim1)
print,[ndim1,ndim2]

;   this one is slow..because the program has to add each y-level one by one?

delvar,test1
tic
test1=rebin(test,[ndim1,ndim2], /SAMPLE)
toc

delvar,test1
tic
test1=cmreplicate(test,ndim2)
toc

delvar,test1
tic
test1=fltarr(ndim1,ndim2,/nozero)
for i=0,ndim1-1 do begin
    replicate_inplace,test1,test[i],2,[i,0]
endfor
toc

delvar,test1
tic
test1=fltarr(ndim1,ndim2,/nozero)
for i=0,ndim2-1 do begin
    test1[i*ndim1]=test
endfor
toc


print,'>>>'
print,"test1[i,*]=test"
ndim1=long(10000)
ndim2=long(10000)
test=findgen(ndim2)
print,[ndim1,ndim2]

;   this one is much faster because the expandsion is done in x-axis
delvar,test1
tic
test1=rebin(reform(test,1, ndim2),[ndim1,ndim2], /SAMPLE)
toc

delvar,test1
tic
test1=fltarr(ndim1,ndim2,/nozero)
for i=0,ndim2-1 do begin
    replicate_inplace,test1,test[i],1,[0,i]
endfor
toc

delvar,test1
tic
test1=fltarr(ndim1,ndim2,/nozero)
for i=0,ndim2-1 do begin
    test1[i*ndim1]=replicate(test[i],ndim1)
endfor
toc



print,'>>>'
print,"test1[i,*]=test"
ndim1=long(nmax)
ndim2=long(nmin)
test=findgen(ndim2)
print,[ndim1,ndim2]

;   this one is much faster because the expandsion is done in x-axis
delvar,test1
tic
test1=rebin(reform(test,1, ndim2),[ndim1,ndim2], /SAMPLE)
toc

delvar,test1
tic
test1=fltarr(ndim1,ndim2,/nozero)
for i=0,ndim2-1 do begin
    replicate_inplace,test1,test[i],1,[0,i]
endfor
toc

delvar,test1
tic
test1=fltarr(ndim1,ndim2,/nozero)
for i=0,ndim2-1 do begin
    test1[i*ndim1]=replicate(test[i],ndim1)
endfor
toc

print,'>>>'
print,"test1[i,*]=test"
ndim1=long(nmin)
ndim2=long(nmax)
test=findgen(ndim2)
print,[ndim1,ndim2]

;   this one is much faster because the expandsion is done in x-axis
delvar,test1
tic
test1=rebin(reform(test,1, ndim2,/over),[ndim1,ndim2], /SAMPLE)
toc

delvar,test1
tic
test1=fltarr(ndim1,ndim2,/nozero)
for i=0,ndim2-1 do begin
    replicate_inplace,test1,test[i],1,[0,i]
endfor
toc

delvar,test1
tic
test1=fltarr(ndim1,ndim2,/nozero)
for i=0,ndim2-1 do begin
    test1[i*ndim1]=replicate(test[i],ndim1)
endfor
toc


; depending on the dmimensions 

;speed test[*,i]=test
;index append>rebin+reform(expand x)>replicate_inplace
;speed test[i,*]=test
;rebin+reform(expand x)>=index append>=replicate_inplace


END

PRO TEST_SPEED_DIMEXPAND1

ecube=randomu(seed,100,100)
tic
ecube1=rebin(ecube,[100,100,1000])
toc
print,size(ecube1)

tic
ecube2=cmreplicate(ecube,1000)
toc
print,size(ecube2)

tic
ecube3=make_array(100,100,1000)
for i=0,9 do begin
    ecube3[0,0,i]=ecube
endfor
toc
print,size(ecube3)

print,total(long(ecube1 eq ecube2 and ecube1 eq ecube3))
print,n_elements(ecube1)

END