PRO CONVOL_POWER2,input,output,silent=silent
;+
;   this code automatically choose the best size option for FFT
;-

if  n_elements(output) eq 0 then output=repstr(input,'.fits','_power2.fits')
p2list=2.^findgen(20)

im=readfits(input,hd,silent=silent)
dim=size(im,/d)
tag_d1=where(p2list le dim[0])
tag_d2=where(p2list le dim[1])
dim_d1=p2list[tag_d1[-1]]
dim_d2=p2list[tag_d2[-1]]

if  ~keyword_set(silent) then print,'input dim:',dim
if  ~keyword_set(silent) then print,'pick dim:',dim_d1,dim_d2

pc=round(dim/2.0)
hextract,im,hd,newim,newhd,$
    pc[0]-dim_d1/2+1,pc[0]+dim_d1/2,$
    pc[1]-dim_d2/2+1,pc[1]+dim_d2/2,silent=silent
    
writefits,output,newim,newhd


END

PRO TEST_CONVOL_POWER2

repo1='/Users/Rui/Workspace/highz/reduc/lyahalo/images/'
repo2='/Users/Rui/Workspace/highz/reduc/uvlfs/pcf1/'
flist=['wrc4_pcf1','R_pcf1','I_pcf1']
for i=0,n_elements(flist)-1 do begin
    convol_power2,repo1+flist[i]+'.fits',repo2+flist[i]+'.fits',/silent
    hd=headfits(repo2+flist[i]+'.fits',/silent)
    print,repo2+flist[i]+'.fits'
    print,sxpar(hd,'MAGZERO'),sxpar(hd,'EFFGAIN')
    convol_power2,repo1+flist[i]+'_rms.fits',repo2+flist[i]+'_rms.fits',/silent
    convol_power2,repo1+flist[i]+'_flag.fits',repo2+flist[i]+'_flag.fits',/silent
endfor

END