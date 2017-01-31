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
;   objs:       check <make_objects.pro> for the defination of this structure
;               it could be a scale or vector of the predefined structure.
;               
; KEYWORDS:
;   export_method:      'mef'       default: muti-extension fits
;                                   the last extention is the cutout index;
;                                   the 1->n-1-th extenstions are cutout stamps (im,hd);
;                                   note:   this option is usually fast then export_method='list' and more 
;                                           flexiable for none-IDL software.
;                                   only export_mthod='mef' will work with make_charts.pro
;                       'list'      idl variable (list type)
;                       'stamps'    save individual cutout images in FITS, named after objs.imout+'.fits'
;
;   extract_method:     'hextractx'         using hextractx.pro (hextract.pro-based)
;                       'hextractx-fast'    using hextractx.pro (fxreadx.pro-based,memory saver)
;                       'hastrom'           using hastrom.pro
;                       'hextract'          using hextract.pro
; OUTOUTS:
;   output      file name for the MEF or fits catalog (export_method='mef'/'stamps')
;               or
;               idl-xdr file holding cutouts data (export_method='list')
;                       
;
; EXAMPLE:
;   see TEST_MAKE_CHARTS
;
; NOTE:
; 
;   This procedure has been optimzed for large image sets and memory usages, and should scale up well
;   for large catalogs. It will load input imges one by one: for each image, requested stamps inside will
;   be produced using the specified extracting/sampling methods (extract_method)
;
;   The output file (export_method='mef') could be used by make_charts.pro for producing finding chats. 
;   This new version will do the job with two steps:
;
;   example:
;       make_cutouts,objs,export_method='list',output=cutouts
;       save,cutouts,filename='../cutouts/ibg_cutouts4charts.xdr'
;   
;   please note that some time you can get the cutouts images easily using webtools 
;       (e.g. http://irsa.ipac.caltech.edu/data/COSMOS/index_cutouts.html)
;
; HISTORY:
;   20160629    R.Xue   completely rewritten from the older version
;   20160702    R.Xue   use the mutiple-extension fits as the default output format
;                       
;-

print,''
print,'---------'
print,'num. of cutouts.',n_elements(objs)
print,'---------'
print,''


;   DEFAULT SETUP

if  n_elements(extract_method) eq 0 then extract_method='hextractx'
if  n_elements(export_method) eq 0 then export_method='mef'
if  n_elements(output) eq 0 then output='test'

;   FIND OUT A LIST OF UNIQ FITS/EXTENSION COMBINATIONS

imlist=strtrim(objs.image,2)+'|ext='+strtrim(round(objs.imext),2)
proclist=objs.proc
temp1=rem_dup(imlist)
temp2=where((objs.image)[temp1] ne '' and (objs.proc)[temp1] ne 0,/null)
ulist=imlist[temp1[temp2]]
print,''
print,'Hold on..Going through these files:'
print,''
foreach filename,ulist do begin
    print,'    ',filename,'  counts:',strtrim(n_elements(where(imlist eq filename)),2)
endforeach
print,''

;   LOOP THROUGH EACH FILE TO EXTRACTING STAMPS

if  strmatch(export_method,'mef',/f) or strmatch(export_method,'stamps',/f) then begin
    mkhdr,h,'',/exten
    dir=file_dirname(output,/m)
    file_mkdir,dir
    ;,/create
    ;mwrfits,'',output,/create
    writefits,output+'.fits','',h
    ;mwrfits,objs,output
;    print,''
;    print,'setup to a multi-extension fits with a dummy primary image/header'
;    print,'     ',output
;    print,''
endif

if  strmatch(export_method,'list',/f) then begin
    output=list()
endif

objs_sort=objs
cc=0
foreach filename,ulist do begin

    print,''
    print,'<<<<< reading  ',filename
    print,''

    tag=where(filename eq imlist)
    
    hd=headfits(objs[tag[0]].image,ext=objs[tag[0]].imext,/silent)
    if  strmatch(extract_method,'hextract',/f) or $
        strmatch(extract_method,'hastrom',/f) or $
        strmatch(extract_method,'hextractx',/f) $
        then begin
        im=readfits(objs[tag[0]].image,hd,ext=objs[tag[0]].imext,/silent)
    endif
    getrot,hd,rotang,cdelt
    opsize=abs(cdelt[0]*60.*60.)

    for i=0,n_elements(tag)-1 do begin

        iobj=tag[i]
        
        print,'>>>>> ',string(i+1,format='(i5)')+'/'+strtrim(n_elements(tag),2),$
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
        
        ;   SMART DIRECT EXTRACT FAST

        if  strmatch(extract_method,'hextractx-fast',/f) then begin
            hextractx,objs[tag[0]].image,hd,$
                radec=[objs[iobj].ra,objs[iobj].dec],subim,subhd,$
                (objs[iobj].bxsz)*[0.5,-0.5],$
                (objs[iobj].bxsz)*[-0.5,0.5],/silent,EXTENSION=objs[tag[0]].imext
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
            objs_sort[cc]=objs[iobj]
            cc=cc+1
        endif

        ;   EXPIRT AS MULTI-EXT FITS

        if  strmatch(export_method,'mef',/f) then begin
            key="XTENSION= 'IMAGE   '           / IMAGE extension                                "
            subhd=[key,subhd]
            writefits,output+'.fits',subim,subhd,/append
            print,'>>>>> append ',output+'.fits'
            objs_sort[cc]=objs[iobj]
            cc=cc+1
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

if  strmatch(export_method,'mef',/f) or strmatch(export_method,'stamps',/f) then begin
    print,''
    print,replicate('+',40)
    print,'write the database catalog'
    mwrfits,objs_sort,output+'.fits'
    print,replicate('+',40)
    print,''
endif

;fits_write,output,objs_sort,extname='OBJECTS',XTENSION='BINTABLE'
;fits_open,output,fcb
;next=fcb.nextend
;fits_close,fcb
;cutouts_hd=mrdfits(output,'OBJECTS')
;print_struct,cutouts_hd
;print_struct,objs_sort
;if  strmatch(export_method,'mef',/f) then begin
;    ;modfits,output,objs_sort[0:cc-1],exten_no=1
;    print,''
;    print,'>>>>> resort index ',output
;    print,cutouts_hd
;    print,''
;endif
;cutouts_hd=mrdfits(output,1)
;print,cutouts_hd.ra
;print,objs_sort[0:cc-1].ra
;print,''

END