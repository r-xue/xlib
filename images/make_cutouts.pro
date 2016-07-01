;THIS also replace gal_deproj
;please note that some time you can get the cutouts images easily using webtools (e.g. http://irsa.ipac.caltech.edu/data/COSMOS/index_cutouts.html)
;



PRO MAKE_CUTOUTS,OBJS,$
    EXTRACT_METHOD=EXTRACT_METHOD,$
    EXPORT_METHOD=EXPORT_METHOD,$
    OUTPUT=OUTPUT
    

;+
; NAME:
;   make_charts
;
; PURPOSE:
;   make finding charts
;
; INPUTS:
;   obj:        check make_objects.pro for the detailed defination of this structure
;               it could a scale or vector of the predefined structure.
;
; OUTOUTS:
;   output      specified exfits name
;               variable (in a LIST type) holding cutouts data
;               
; KEYWORDS:
;   cross:      plot cross at center rather than bars to the left and top
;   layout:     see below (hold the input for pos_mp.pro)
;
; EXAMPLE:
;   see TEST_MAKE_CHARTS
;
; NOTE:
; 
;   The older version of make_charts.pro will load all input images at once for saving the time wasted on
;   repeating load same images for individual objects, but this doesn't scale up well if the image dataset
;   is too large for memory (like the COSMOS data in mutiple tiles/bands)
;
;   This new version will do the job in two steps:
;       1. load input image one by one; for each images, generate requried stamps and save them to memory;
;          release memory
;       2. plot stamps
;   The 1st step is actually shared with the new version of make_cutouts.pro.
;   The input structures of make_charts.pro and make_cutouts.pro can share same structure tags now.
;
;   ++++++ make_*.pro are replacing gal_deproj*pro in xlib ++++++
;   
;   The file/obejct metadata is defined as a "flat" structure now.
;
; HISTORY:
;   20160629    R.Xue   completely rewritten from the older version
;                       
;-

;   DEFAULT SETUP

if  n_elements(extract_method) eq 0 then extract_method='hextractx'
if  n_elements(export_method) eq 0 then export_method='stamps'
if  n_elements(output) eq 0 then output=''

;   FIND OUT A LIST OF UNIQ FITS/EXTENSION COMBINATIONS

imlist=strtrim(objs.image,2)+' '+strtrim(round(objs.imext),2)
proclist=objs.proc
temp1=rem_dup(imlist)
temp2=where((objs.image)[temp1] ne '' and (objs.proc)[temp1] ne 0,/null)
ulist=imlist[temp1[temp2]]
print,''
print,'Hold on..To examine these files:'
print,''
foreach filename,ulist do begin
    print,'    ',filename
endforeach
print,''

;   LOOP THROUGH EACH FILE TO EXTRACTING STAMPS

if  strmatch(export_method,'exfits',/f) then begin
    mkhdr,h,'',/exten
    dir=file_dirname(output,/m)
    file_mkdir,dir
    writefits,output,'',h
    print,''
    print,'export to a multi-extension fits with a dummy primary image/header'
    print,'     ',output
    print,''
endif

if  strmatch(export_method,'list',/f) then begin
    output=list()
endif


foreach filename,ulist do begin

    print,''
    print,'+++++ reading  ',filename
    print,''

    tag=where(filename eq imlist)


    im=readfits(objs[tag[0]].image,hd,ext=objs[tag[0]].imext,/silent)
    getrot,hd,rotang,cdelt
    opsize=abs(cdelt[0]*60.*60.)

    for i=0,n_elements(tag)-1 do begin

        iobj=tag[i]
        
        print,'<<<<<',string(i+1,format='(i5)')+'/'+strtrim(n_elements(tag),2),$
            ' obj: ', objs[iobj].id,$
            adstring(objs[iobj].ra,objs[iobj].dec,2),$
            ' band: ',objs[iobj].band

        bscale=1.0
        outname=objs[iobj].imout+'.fits'

        ;   SMART DIRECT EXTRACT

        if  strmatch(extract_method,'hextractx',/f) then begin
            hextractx,im,hd,$
                radec=[objs[iobj].ra,objs[iobj].dec],subim,subhd,$
                (objs[iobj].bxsz)*[0.5,-0.5],$
                (objs[iobj].bxsz)*[-0.5,0.5],/silent
        endif

        ;   RESAMPLE

        if  strmatch(extract_method,'hastrom',/f) then begin
            psize=objs[iobj].cell
            temphd=mk_hd([objs[iobj].ra,objs[iobj].dec],$
                fix(((objs[iobj].bxsz)/psize)/2.0)*2.0+1.0,psize)
            hastrom_nan,im,hd,subim,subhd,temphd,missing=!VALUES.F_NAN,/silent,$
                interp=0
            if  (strlowcase((objs[iobj].bunit)) eq 'counts/s') or (strlowcase((objs[iobj].bunit)) eq 'adu') then begin
                bscale=psize^2.0/opsize^2.0
            endif
        endif

        ;   DIRECT EXTRACT

        if  strmatch(extract_method,'hextract',/f) then begin
            sz=size(im,/d)
            hbx=fix((objs[iobj].bxsz)/2.0/opsize)
            adxy,hd,objs[iobj].ra,objs[iobj].dec,x,y
            xmin=fix(x)-hbx
            xmax=fix(x)+hbx
            ymin=fix(y)-hbx
            ymax=fix(y)+hbx
            if  not (xmin ge 0 and xmax lt sz[0] and ymin ge 0 and ymax lt sz[1]) then continue
            hextract,im,hd,subim,subhd,xmin,xmax,ymin,ymax
        endif

        ;   PREP STAMP

        subim=subim*bscale
        if  objs[iobj].bunit ne '' then sxaddpar,subhd,'BUNIT',(objs[iobj].bunit)
        sxaddpar, subhd, 'DATAMAX', max(subim,/nan),before='HISTORY'
        sxaddpar, subhd, 'DATAMIN', min(subim,/nan),before='HISTORY'

        ;   EXPORT AS INDIVIDUAL STAMPS

        if  strmatch(export_method,'stamps',/f) then begin
            dir=file_dirname(outname,/m)
            file_mkdir,dir
            writefits,outname,subim,subhd
            print,'>>>>> ',outname
        endif

        ;   EXPIRT AS MULTI-EXT FITS

        if  strmatch(export_method,'exfits',/f) then begin
            key="XTENSION= 'IMAGE   '           / IMAGE extension                                "
            subhd=[key,subhd]
            writefits,output,subim,subhd,/append
            print,'>>>>> append',output
        endif

        ;   EXPORT AS A IDL LIST DATA TYPE
        
        if  strmatch(export_method,'list',/f) then begin
            tmp=objs[iobj]
            tmp=create_struct(tmp,'im0',subim)
            tmp=create_struct(tmp,'hd0',subhd)
            output.add,tmp,/no_copy
        endif
        
    endfor

endforeach

print,''

END