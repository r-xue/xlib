PRO IMCOMB,images,outname,mode=mode,verbose=verbose,checkoffset=checkoffset,$
    x_shift=x_shift,y_shift=y_shift,crpix_shift=crpix_shift,$
    compress=compress
;+
; NAME:
;   imcomb
; 
; PURPOSE:
;   combine images in a simple fashion.
; 
; INPUTS:
;   images      image file list
;   
;   mode:       1 (default):    assume all tiles have the same projection (except CRPIX? values), we can just 
;                               reassemble them without touching data arrays.
;               2:              resampling and then mosaicing (not implemented)
;   [checkoffset]               check image offset in the range of [-checkoffset,+checkoffset] in image x/y.
;   x_shift
;   y_shift
;   z_shift
;   
; NOTE:
;   this is not sophisticated as: MIRAID/imcomb; CASA/linearmosaic; IRAF/imcombine
;   
; HISTORY:
; 
;   20170115    R.Xue   introduced
;   20170116    R.Xue   improve the efficiency on large files and the "checkoffset" function
;-

mode=1


;   CALCULATE THE CORNER PIXEL INDICES IF CRPIX1/2=1
xc=[]
yc=[]

for i=0,n_elements(images)-1 do begin
    hdt=headfits(images[i])
    if  keyword_set(verbose) then begin
        print,$
            images[i],sxpar(hdt,'CTYPE1'),sxpar(hdt,'CTYPE2'),$
            sxpar(hdt,'CRVAL1'),sxpar(hdt,'CRVAL2'),$
            sxpar(hdt,'CDELT1'),sxpar(hdt,'CDELT2')
    endif
    xc=[xc,1.0-sxpar(hdt,'CRPIX1')+[1.0,sxpar(hdt,'NAXIS1')]]
    yc=[yc,1.0-sxpar(hdt,'CRPIX2')+[1.0,sxpar(hdt,'NAXIS2')]]
endfor

naxis1=long64(max(xc)-min(xc)+1.0)
naxis2=long64(max(yc)-min(yc)+1.0)

print,''
print,'out image size: ',naxis1,naxis2

BITPIX=sxpar(hdt,'BITPIX')
CASE BITPIX OF
     8:    IDLTYPE = 1 ; Byte
    16:    IDLTYPE = 2 ; Integer*2
    32:    IDLTYPE = 3 ; Integer*4
   -32:    IDLTYPE = 4 ; Real*4
   -64:    IDLTYPE = 5 ; Real*8
ENDCASE
imc=MAKE_ARRAY(DIMENSION=[naxis1,naxis2],TYPE=IDLTYPE,value=!values.f_nan)
hdc=hdt
sxaddpar,hdc,'NAXIS1',naxis1
sxaddpar,hdc,'NAXIS2',naxis2
sxaddpar,hdc,'CRPIX1',1.0-(min(xc)-1)
sxaddpar,hdc,'CRPIX2',1.0-(min(yc)-1)

for i=0,n_elements(images)-1 do begin

    j_best=0
    k_best=0
    
    print,replicate('-',40)    
    print,'>>> loading: ',images[i]
    imt=readfits(images[i],/silent)
    
    ;++
    ;   a better solution (maybe slower) would be using CORREL_OPTIMIZ.PRO
    ;   we avoid it here
    ;--
    
    if  n_elements(x_shift) eq 0 and n_elements(y_shift) eq 0 then begin
        
        if  keyword_set(checkoffset) and i eq 0 then print,'<<< first image no offset:                    ',j_best,k_best
        if  keyword_set(checkoffset) and i ne 0 then begin
            nmatch=[]
            ncompr=[]
            jlist=[]
            klist=[]
            for k=-checkoffset,checkoffset do begin
                for j=-checkoffset,checkoffset do begin
                    imc_xyrange=[xc[i*2]-min(xc)+checkoffset,xc[i*2+1]-min(xc)-checkoffset,yc[i*2]-min(yc)+checkoffset,yc[i*2+1]-min(yc)-checkoffset]
                    imt_xyrange=[+checkoffset-j,-1-checkoffset-j,+checkoffset-k,-1-checkoffset-k]
                    ppc=[]
                    ppt=[]
                    ppc=[ppc,(imc[imc_xyrange[0]:imc_xyrange[1],imc_xyrange[2]])[*]]
                    ppt=[ppt,(imt[imt_xyrange[0]:imt_xyrange[1],imt_xyrange[2]])[*]]
                    ppc=[ppc,(imc[imc_xyrange[0]:imc_xyrange[1],imc_xyrange[3]])[*]]
                    ppt=[ppt,(imt[imt_xyrange[0]:imt_xyrange[1],imt_xyrange[3]])[*]]
                    ppc=[ppc,(imc[imc_xyrange[0],imc_xyrange[2]:imc_xyrange[3]])[*]]
                    ppt=[ppt,(imt[imt_xyrange[0],imt_xyrange[2]:imt_xyrange[3]])[*]]
                    ppc=[ppc,(imc[imc_xyrange[1],imc_xyrange[2]:imc_xyrange[3]])[*]]
                    ppt=[ppt,(imt[imt_xyrange[1],imt_xyrange[2]:imt_xyrange[3]])[*]]
                    ppd=ppt-ppc                
                    tmp=where(ppd eq 0,nmatch0)
                    tmp=where(ppd eq ppd,ncompr0)
                    nmatch=[nmatch,nmatch0]
                    ncompr=[ncompr,ncompr0]
                    jlist=[jlist,j]
                    klist=[klist,k]
                    if  keyword_set(verbose) then print,"try shift "+images[i],j,k,'  ',strtrim(nmatch[-1],2)+' / '+strtrim(ncompr[-1],2)
                endfor
            endfor
            if  max(ncompr) eq 0 then begin
                j_best=0
                k_best=0
                print,'<<< no valid pixels in overlapping regions:   ',j_best,k_best
            endif else begin
                tmp=max(1.0*nmatch/ncompr0,tag)
                j_best=jlist[tag]
                k_best=klist[tag]
                print,'<<< best guessing of x/y pixel shift:         ',j_best,k_best,'  ',strtrim(nmatch[tag],2)+'/'+strtrim(ncompr[tag],2)
            endelse
        endif
    
    endif else begin
        j_best=x_shift[i]
        k_best=y_shift[i]
        print,'    shift pixels using x/y_shift:   ',j_best,k_best
    endelse
    
    imc[xc[i*2]-min(xc)+(j_best>0),yc[i*2]-min(yc)+(k_best>0)]=imt[(-j_best>0):((-j_best-1)<(-1)),(-k_best>0):((-k_best-1)<(-1))]
    
endfor

if  n_elements(crpix_shift) eq 2 then begin
    sxaddpar,hdc,'CRPIX1',sxpar(hdc,'CRPIX1')+crpix_shift[0]
    sxaddpar,hdc,'CRPIX2',sxpar(hdc,'CRPIX2')+crpix_shift[1]
endif

print,replicate('-',40)
print,'>>> write out: ',outname+'.fits'
writefits,outname+'.fits',imc,hdc,compress=compress

END

PRO TEST_IMCOMB


;imcomb,['zc430350_Subaru-IB427_tile076.fits','zc430350_Subaru-IB427_tile064.fits'],$
;    'test',checkoffset=1
;
;imcomb,['zc430350_Subaru-IB427_tile076.fits','zc430350_Subaru-IB427_tile064.fits'],$
;    'test2',x_shift=[0,0],y_shift=[-1,0]

;imcomb,['*_Subaru-IB427_tile064.fits','*_Subaru-IB427_tile065.fits',$
;        '*_Subaru-IB427_tile076.fits','*_Subaru-IB427_tile077.fits'],$
;    'IB427',x_shift=[0,0,0,0],y_shift=[0,0,-1,-1]
;
;imcomb,['*_acs-I_tile064.fits','*_acs-I_tile065.fits',$
;    '*_acs-I_tile076.fits','*_acs-I_tile077.fits'],$
;    'acs-I',x_shift=[0,0,0,0],y_shift=[0,0,0,0]

END