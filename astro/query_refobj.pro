FUNCTION QUERY_REFOBJ,$
    image,flag=flag,$
    catalog=catalog,CONSTRAINT=CONSTRAINT,$
    zero=zero,nan=nan,guard=guard,sat=sat,$
    iso=iso,$
    outname=outname,outall=outall,$
    outcat=outcat
;+
; NAME:
;   query_refobj
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
;   20160725    R.Xue   performance improvement: use valid_object.pro instead of check_point.pro
;-


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

if  n_elements(flag) eq 0 then flag=''
if  n_elements(catalog) eq 0 then catalog='SDSS-DR7'
if  n_elements(constraint) eq 0 then constraint=''

hd=headfits(image)

;   QUERY CATS
getrot,hd,rotang,cdelt
psize=abs(cdelt[0]*60.*60.)
sz=[sxpar(hd,'NAXIS1'),sxpar(hd,'NAXIS2')]

xc=fix(sz[0]/2.)
yc=fix(sz[1]/2.)
xyad,hd,xc,yc,ac,dc
xs=psize*sz[0]/60.
ys=psize*sz[1]/60.

cat = queryvizier(catalog,[ac,dc],[xs,ys]*1.1,/all,cons=constraint)

if  size(cat,/tn) eq size({tmp:''},/tn) then begin 

    print,replicate('--',30)
    print,'query '+catalog+' using image :'+image
    if  flag ne '' then print,'query '+catalog+' using flag  :'+flag
    print,'catalogue header:'
    print,tag_names(cat)
    print,replicate('--',30)
    print,string('n_objs(query):',format='(A-30)'),string(n_elements(cat),format='(i10)')
    
    
    st=replicate(temp,n_elements(cat))
    st.color='blue'
    st.x=cat.RAJ2000
    st.y=cat.DEJ2000
    st1=st
    st2=st
    st2.radius=1.0
    st=[st1,st2]
    if  n_elements(outname) ne 0 and keyword_set(outall) then begin
        write_ds9reg,outname+'_all.reg',st,'FK5'
        write_csv,outname+'_all.csv',double((cat.RAJ2000)),double((cat.DEJ2000))
    endif
    
    
    ;   FIND OBJECTS ISOLATED (no nearby objects within 10 sec)
    if  n_elements(iso) then begin
        result=matchall_sph(cat.RAJ2000,cat.DEJ2000,cat.RAJ2000,cat.DEJ2000,1.0/60./60.*iso,nwithin)
        cat=cat[where(nwithin eq 1,/null)]
        print,string('n_objs(isolated):',format='(A-30)'),string(n_elements(cat),format='(i10)')
    endif

    ;   VALID OBJECTS ON THE IMAGE    
    obj_in=valid_object(image,cat.RAJ2000,cat.DEJ2000,nan=nan,zero=zero,guard=guard,sat=sat)    
    print,string('n_objs(valid on image):',format='(A-30)'),string(total(long(obj_in)),format='(i10)')
    if  flag ne '' then begin
        obj_okay=valid_object(flag,cat.RAJ2000,cat.DEJ2000,/flag)
        obj_in=(obj_in and obj_okay)
        print,string('n_objs(valid on flag):',format='(A-30)'),string(total(long(obj_in)),format='(i10)')
    endif
    cat=cat[where(obj_in,/null)]

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
