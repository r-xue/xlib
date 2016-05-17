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
