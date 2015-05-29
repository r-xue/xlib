PRO TEST_PADDING


test=reform(findgen(long(10000)*10000),10000,10000)

; faster using make_array
delvarx,test1,test2
tic
test2=make_array(60000,30000,/float)
toc
tic
test1=fltarr(60000,30000)
toc

delvarx,testpad1
tic
testpad1=make_array(30000,30000,/float)
testpad1[10000,10000]=test
toc

delvarx,testpad2
tic
testpad2=make_array(30000,30000,/float)
testpad2[10000:19999,10000:19999]=test
toc

delvarx,testpad3
tic
testpad3=extrac(test,-10000,-10000,30000,30000)
toc

print,total(testpad1 eq testpad3),n_elements(testpad1)


test=reform(findgen(long(1000)*1000*100),1000,1000,100)

; not signifcantly different
delvarx,test1,test2
tic
test1=fltarr(3000,3000,300)
toc
tic
test2=make_array(3000,3000,300,/float)
toc


delvarx,testpad1
tic
testpad1=make_array(3000,3000,300,/float)
testpad1[1000,1000,100]=test
toc
delvarx,testpad2
tic
testpad2=make_array(3000,3000,300,/float)
testpad2[1000:1999,1000:1999,100:199]=test
toc
print,total(testpad1 eq testpad2),n_elements(testpad1)

;    im='n4254co.sgm.mom0.fits'
;    im=readfits(im,hd)
;    newhd=hd
;
;    newrx=1000
;    newry=1000
;    newnx=2000
;    newny=2000
;
;    rx=SXPAR(hd,'crpix1')
;    ry=SXPAR(hd,'crpix2')
;    nx=SXPAR(hd,'naxis1')
;    ny=SXPAR(hd,'naxis2')
;    sxaddpar,newhd,'naxis1',newnx
;    sxaddpar,newhd,'naxis2',newny
;    newim=fltarr(newnx,newny)
;    newim[*,*]=!values.f_nan
;    sxaddpar,newhd,'CRPIX1',newrx
;    sxaddpar,newhd,'CRPIX2',newry
;    newim[newrx-rx:newrx-rx+nx-1,newry-ry:newry-ry+ny-1]=im
;    writefits,'test.fits',newim,newhd



END