FUNCTION READ_TABLE,file,header=header,$
    scalar=scalar,$
    srow=srow,$
    skey=skey,$
    sval=sval,$
    slog=slog,$
    bkey=bkey,$
    silent=silent,$
    refresh=refresh,$
    keeptags=keeptags

;+
; NAME:
;   READ_TABLE
;
; PURPOSE:
;   read the content from a table file (e.g. spreadsheet, csv) and import data into:
;       an IDL structure (just like read_csv) 
;       or, a structure array
;
; INPUTS:
;   file        table file name 
;               this could be any spreadsheet format, e.g. odt,xlsx, or csv 
;               note:   any format supported by libreoffice will be automatically 
;                       converted to csv on demand, then read into IDL via read_csv()
;   srow        select rows to import (start with 0, the IDL way)
;   skey        colume names used to select content, together with sval     
;   sval        wildcard characeters used to select content, together with skey
;               e.g. skey=['project','galaxy'], sval=['msc','lmc']
;   slog        the logical opertion on treating different value-based selection (not implemented)
;   bkey        remove row with a blank value in the specifiled colume 
;   
; OUTPUTS:
;   table       table content
;   header      table header
;               
; KEYWORDS:
;   /SILENT     no verbose log
;   /REFRESH    if the input file is not csv, the program will look for a csv file with the same name first.
;               if that file exists, the program will read that file without converting the non-csv file into csv.
;               if that file doesn't exist, the program will do the conversion, and read the fresh csv.
;               /refresh do the refresh even .csv cach file exits.
;   /scalar
;               read_csv will load table content into a structure (by default), with each tag
;               contains an array of specific data type.
;                   tab.FIELD01 = [a1,a2,a3,a4..]
;                   tab.FIELD02 = [b1,b2,b3,b4..]
;                   header=[a_header,b_header,...]
;               READ_TABLE() will automatically convert this structure to an array, with each element 
;               contains a structure:
;                   tab[0]={FIELD01:a1,FIELD02:b1,FIELD03:c1...}
;                   tab[1]={FIELD01:a2,FIELD02:b2,FIELD04:c2...}
;                   header=[a_header,b_header,...]
;               /scalar will turn off this feature.
;   /keeptag    structure from read_csv have awkward names
;               READ_TABLE() will rename tags to valid tagnames converted from header using idl_validname()
;               /keeptag will turn off this feature
;               but you have to maintain the converted valid tag is unique..  
;   
; REQURIEMENT (for non-csv files):
;   unoconv     https://github.com/dagwieers/unoconv
;   libreoffice http://www.libreoffice.org
; 
; NOTE:
;   
;   unoconv+libreoffice may occasionally hang.
;   the listenser mode of unoconv can solve this problem:
;   >unoconv --listener&
;   >sleep 20
;   >unoconv -f pdf *.odt
;   >unoconv -f doc *.odt
;   >unoconv -f html *.odt
;   >kill -15 %-
;   
;   A csv file with the same root name will be created in your spreasheet directory 
;
; HISTORY:
;
;   20130410    RX  introduced
;   20140625    RX  rewritten as a function from the procedure xls2struct.pro
;                   new features: filter table content
;                                 output structure array rather than a structure
;                                 replace the tagnames using header names
;                                 
;                                 
;
;-


rootname=cgrootname(file,dir=dir,ext=ext)
csvfile=file
if  ext ne 'csv' then begin
    csvfile=dir+rootname+'.csv'
    if keyword_set(refresh) then begin
        ;cmd='unoconv -f csv -o '+csvfile+' '+file
        cmd='unoconv -f csv '+file
        print,cmd
        spawn,cmd
    endif
endif

tab=READ_CSV(csvfile,header=header)
nrow=n_elements(tab.(0))

if  keyword_set(skey) then begin
    if  n_elements(skey) eq 1 and n_elements(sval) gt 1 then skey=replicate(skey,n_elements(sval))
    okay=0
    for i=0,n_elements(skey)-1 do begin
        colv=tab.(where(header eq skey[i]))
        okay=okay+strmatch(colv,sval[i],/fold_case) 
    endfor
endif else begin
    okay=replicate(1,nrow)
endelse

if  keyword_set(bkey) then begin
    for i=0,n_elements(bkey)-1 do begin
        colv=tab.(where(header eq bkey[i]))
        okay[where(colv eq '',/null)]=0
    endfor
endif

if  keyword_set(srow) then begin
    ind=srow[where(okay[srow] ne 0)]
endif else begin
    ind=where(okay ne 0)
endelse

; EXTRACT SUBARRAY
tagnames=tag_names(tab)
if  not keyword_set(keeptags) then tagnames=IDL_VALIDNAME(header,/convert_all)

newtab={}
for k=0,n_elements(tagnames)-1 do begin
    newtab=create_struct(newtab,(tagnames[k])[0],(tab.(k))[ind])
endfor
tab=newtab

if not keyword_set(silent) then begin
    print,replicate('-',50)
    for i=0,n_elements(header)-1 do begin
        print,"<"+header[i]+">","<"+tagnames[i]+">",size(tab[0].(i),/tn),format='(a-35,a-35,a-12)'
    endfor
    print,""
    print,replicate('-',50)
    print,'column no.: ', n_elements(header)
    print,'rows   no.: ', n_elements(tab.(0))
    print,replicate('-',50)
    print,""
endif


if  not keyword_set(scalar)  then begin
    tmpsts=[]
    for j=0,n_elements(tab.(0))-1 do begin
        tmpst={}
        for i=0,n_elements(header)-1 do begin
            tmpst=create_struct(tmpst,tagnames[i],(tab.(i))[j])
        endfor
        tmpsts=[tmpsts,tmpst]
    endfor
    tab=tmpsts
endif


return,tab
END