FUNCTION QUERY_REFOBJ,image,flag=flag,$
    catalog=catalog,CONSTRAINT=CONSTRAINT,$
    sat=sat,nan=nan,iso=iso,$
    outname=outname,$
    outcat=outcat
;+
; NAME:
;   star_picker
;
; PURPOSE:
;   query reference objects in a fits image from online catalogues
;
; INPUTS:
;   image           fits image
;   [flag]          flag image
;   [catalog]       catalogue name (http://vizier.u-strasbg.fr/vizier/cats/U.htx)
;   [constatraint]  catalogue constraint (check queryvizier.pro)
;   [outname]       output csv/reg file name
;
; OUTOUTS:
;   cat             a catalog structure containing all stars meeting the selection constraints.
;
; KEYWORDS:
;   nan             remove objects in blanking regions
;   sat             remove objects in saturation regions (=50000.0)
;   iso             remove objects in crowded regions (no neigbour within <iso>arcsec)

; EXAMPLE:
;
;   pick iosolated stars in good regions of the image: 
;       cat=query_refobj('../images/R_NDWFS1.fits',flag='../images/R_NDWFS1_flag.fits',$
;               catalog='SDSS-DR7',constraint='us=1,gs=1,rs=1,is=1,zs=1',$
;               sat=50000.0,/nan,ios=10.,outname='test')
;
;   pick guide stars in GSC2.3.2:
;       cat=query_refobj('../images/R_NDWFS1.fits',catalog='GSC2.3',constraint='Class=0',$
;               sat=50000.0,/nan,ios=10.)
; 
; HISTORY:
;   20150812    R.Xue   add comments
;   20150821    R.Xue   catch exceptions
;-


if  n_elements(flag) eq 0 then flag=''
if  n_elements(catalog) eq 0 then catalog='SDSS-DR7'
if  n_elements(constraint) eq 0 then constraint=''

im=readfits(image,hd)
if  flag ne '' then mk=readfits(flag,mkhd)

;   QUERY CATS
getrot,hd,rotang,cdelt
psize=abs(cdelt[0]*60.*60.)
sz=size(im)
xc=fix(sz[1]/2.)
yc=fix(sz[2]/2.)
xyad,hd,xc,yc,ac,dc
xs=psize*sz[1]/60.
ys=psize*sz[2]/60.

cat = queryvizier(catalog,[ac,dc],max([xs,ys]),/all,cons=constraint)


if  size(cat,/tn) eq size({tmp:''},/tn) then begin 

    print,replicate('--',30)
    print,'query '+catalog+' using image :'+image
    print,'catalogue header:'
    print,tag_names(cat)
    print,replicate('--',30)
    ;   FIND OBJECTS ON THE IMAGE
    cat=cat[where(check_point(hd,cat.RAJ2000,cat.DEJ2000) eq 1,/null)]
    print,'n_objs:          ',n_elements(cat)
    
    ;   FIND OBJECTS ISOLATED (no nearby objects within 10 sec)
    if  n_elements(iso) then begin
        result=matchall_sph(cat.RAJ2000,cat.DEJ2000,cat.RAJ2000,cat.DEJ2000,1.0/60./60.*iso,nwithin)
        cat=cat[where(nwithin eq 1,/null)]
        print,'n_objs(isolated):  ',n_elements(cat)
    endif
    
    ;   FIND OBJECTS AWAY FROM BAD PIXELS
    txc=cat.RAJ2000
    tyc=cat.DEJ2000
    adxy,hd,txc,tyc,xc,yc
    fg=xc*0.0
    
    if  keyword_set(nan) then fg=fg+float(im[xc,yc] ne im[xc,yc])
    if  n_elements(sat) then fg=fg+float(im[xc,yc] eq sat)
    if  flag ne '' then begin
        adxy,mkhd,txc,tyc,xc,yc
        fg=fg+float(mk[xc,yc] ne 0)
    endif
    cat=cat[where(fg eq 0,/null)]
    print,'n_objs(output):',n_elements(cat)
    
    temp = {ds9reg, $
        shape:'circle', $         ;- shape of the region
        x:0., $             ;- center x position
        y:0., $             ;- center y position
        radius:10., $        ;- radius (if circle). Assumed to be arcsec
        angle:0., $         ;- angle, if relevant. Degrees.
        text:'', $          ;- text label
        color:'red', $         ;- region color
        width:10., $         ;- width (if relevant)
        height:10., $        ;- height (if relevant)
        font:'', $          ;- font for label
        select:1B, $        ;- is selected?
        fixed:0B, $         ;- is fixed?
        edit:1B, $          ;- is editable?
        move:1B, $          ;- is moveable?
        rotate:0B, $        ;- can be rotated?
        delete:1B}          ;- can be deleted?
    
    st=replicate(temp,n_elements(cat))
    st.x=cat.RAJ2000
    st.y=cat.DEJ2000
    
    st1=st
    st2=st
    st2.radius=1.0
    st=[st1,st2]
    
    if  n_elements(outname) ne 0 then begin
        write_ds9reg,outname+'.reg',st,'FK5'
        write_csv,outname+'.csv',double((cat.RAJ2000)),double((cat.DEJ2000))
    endif

endif else begin
    
    cat=-1

endelse

if  n_elements(outcat) ne 0 then save,cat,filename=outcat+'_refobj.xdr'
return,cat
END
