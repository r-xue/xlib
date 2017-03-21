PRO TEST_READ_TABLE

;file='/Users/Rui/GDrive/docs/bootes.gsheet'
file='/Users/Rui/GDrive/Worklib/docs/bootes.gsheet'
tb=read_table(file,header=hd,/refresh)
;file='/Users/Rui/GDrive/docs/mcs_abs.gsheet'
;tb=read_table(file,header=hd,/refresh,/keeptags,/scalar)

set_plot,'ps'
device,filename='TEST_READ_TABLE.eps',bits=8,xsize=5,ysize=5,$
    /inches,/encapsulated,/color
!p.thick=4.0
!x.thick =4.0
!y.thick =4.0
!z.thick =4.0
!p.charsize=0.0
!p.charthick=4.0
!p.symsize=0.0

plot,tb.ra,tb.dec,xrange=[220,217],yrange=[32,35],xstyle=1,ystyle=1,psym=cgsymcat(16),$
    xtitle='R.A.',ytitle='Dec.'
device,/close
set_plot,'x'

END

PRO TEST2_READ_TABLE

tb=read_table('gsheet:test:15szWdaoOAfAyTG15i0FpE_EE1TZ5-HombuuOE9koKjg',header=hd)
window,1,xsize=500,ysize=500
plot,tb.ra,tb.dec,psym=3,xrange=[37.1,36],yrange=[-5.1,-4.0],xstyle=1,ystyle=1,/nodata

tag=where(tb.sci_cal eq 1)
oplot,tb[tag].ra,tb[tag].dec,psym=4
tag=where(tb.comments_rx eq 'ignore=3.55')
oplot,tb[tag].ra,tb[tag].dec,psym=4,color=cgcolor('blue')

END


PRO TEST3_READ_TABLE


path=cgsourceDir()
xlsfile='gsheet:test:15szWdaoOAfAyTG15i0FpE_EE1TZ5-HombuuOE9koKjg:1752870009'
abs=read_table(xlsfile,header=hd,silent=silent,/refresh,/scalar,$
    cname=cname,record_cname=0,$
    ctype=ctype,record_ctype=1,$
    cunit=cunit,record_cunit=2,$
    cnote=cnote,record_cnote=3,$
                record_start=4)


END


FUNCTION READ_TABLE,file,header=header,$
    scalar=scalar,$
    srow=srow,$
    skey=skey,$
    sval=sval,$
    slog=slog,$
    bkey=bkey,$
    silent=silent,$
    refresh=refresh,$
    keeptags=keeptags,$
    missing_value=missing_value,$
    record_start=record_start,$
    record_cname=record_cname,cname=cname,$
    record_ctype=record_ctype,ctype=ctype,$
    record_cunit=record_cunit,cunit=cunit,$
    record_cnote=record_cnote,cnote=cnote
    
    

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
;               this could be any spreadsheet format, e.g. odt,xlsx,csv,gsheet 
;
;               note:   any format supported by libreoffice will be automatically 
;                       converted to csv on demand, then be read into IDL via read_csv()
;                       if the file is gsheet, the file id will be used for downloading 
;                       spreadsheet in csv, then be read into IDL
;                       now, google doc id is supported:
;                       try something like: gsheet:../uvline:1lMJEc1xdEHIqXqVtuPwHwguJvptCzPL97Ola9FbXHXQ
;                       1st tag: gsheet
;                       2nd tag: local csv cach file name
;                       3rd tag: google id
;                       
;   srow        select rows to import (start with 0, the IDL way)
;   skey        colume names used to select content, together with sval     
;   sval        wildcard characeters used to select content, together with skey
;               e.g. skey=['project','galaxy'], sval=['msc','lmc']
;   slog        the logical opertion on treating different value-based selection (not implemented)
;   bkey        remove rows with blank values in specifiled columns
;   
; OUTPUTS:
;   table       table content
;   header      table header
;               
; KEYWORDS:
;   /silent     no verbose log
;   /refresh    if the input file is not csv, the program will look for a csv file with the same name first.
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
;               ** For large tables, the vector conversion can be slow, so you should use /scalar then. **
;   /keeptag    structure from read_csv have awkward tag names
;               READ_TABLE() will validate/rename tags using idl_validname(), but one have to ensure the converted 
;               valid tags are unique..
;               if you see "Conflicting or duplicate structure tag definition:", then you have to adjuste your table
;               header or use /keeptag to prevent renaming tag names
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
;   the google spreadsheet must be "shared" ("anyone with the link can view" option) in the online interface 
;   
;   gsheet is accessible via the drive/gsheet api:
;   e.g.
;   https://www.googleapis.com/drive/v3/files/{key}/export?mimeType=text/csv&alt=media&key={apikey}
;   or
;   https://docs.google.com/spreadsheets/d/{key}/export?format=csv&gid={gid}
;   https://docs.google.com/spreadsheets/d/{key}/gviz/tq?tqx=out:csv&sheet={sheetname}
;   
;   more details:
;   https://developers.google.com/drive/v3/web/manage-downloads
;   
;   some features require IDLv8.5 (e.g. read_csv(..types=types))
;   accpetd types: 
;       "" - An empty string indicates that IDL should automatically determine the data type for that column
;       "Byte" - Byte data
;       "Int" - 16-bit signed integer data
;       "Long" - 32-bit signed integer data
;       "Float" - 32-bit floating-point data
;       "Double" - 64-bit floating-point data
;       "Uint" - 16-bit unsigned integer data
;       "Ulong"- 32-bit unsigned integer data
;       "Long64"- 64-bit signed integer data
;       "Ulong64"- 64-bit unsigned integer data
;       "String", "Date", "Time", or "Datetime" - String data
;       ** small bugs in lib/read_csv.pro of v8.5.1:
;          -- line 36-46:   miss the "String" type, we use "datatime" for a workaround **
;          -- line 402:     read_ascii_create_strcuture() will fail if fieldnames and pdata have different lengths
;                           this could happens if some columns was rejected due to empty record cells. 
;
; HISTORY:
;
;   20130410    RX  introduced
;   20140625    RX  rewritten as a function from the procedure xls2struct.pro
;                   new features: filter table content
;                                 output structure array rather than a structure
;                                 replace the tagnames using header names
;               RX  now it can read the .gsheet file from GoogleDrive!
;   20170220    RX  support sheet selections in the google spreadsheet (using key+gid)
;                   extract datatype/units/note/name of each column using header rows
;                   fix duplicated structure tags automatically by adding "_dupX"
;                   speedup the scalar->vector conversion
;                   wrap read_csv keyword <missing_value>
;                   
;
;-

if  n_elements(record_cname) eq 0 then record_cname=0
if  n_elements(record_ctype) eq 0 then record_ctype=0
if  n_elements(record_cunit) eq 0 then record_cunit=0
if  n_elements(record_cnote) eq 0 then record_cnote=0

rootname=cgrootname(file,dir=dir,ext=ext)
csvfile=file
isid=strmatch(file,'gsheet:*',/f)
gid=''
    
if  isid then begin
    tmp=strsplit(file,':',/ext)
    rootname=tmp[1]
    id=tmp[2]
    dir=repstr(dir,'gsheet:','')
    if  n_elements(tmp) gt 3 then gid=tmp[3]
endif
if  (ext ne 'csv' and ext ne 'gsheet' and not isid) then begin
    csvfile=dir+rootname+'.csv'
    if  keyword_set(refresh) or not file_test(csvfile) then begin
        ;cmd='unoconv -f csv -o '+csvfile+' '+file
        cmd='unoconv -f csv '+file
        if  ~keyword_set(silent) then print,cmd
        spawn,cmd
    endif
endif
if  ext eq 'gsheet' or isid then begin
    csvfile=dir+rootname+'.csv'
    if  keyword_set(refresh) or not file_test(csvfile) then begin
        if  not isid then begin
            openr,lun,file,/get_lun
            id=strarr(1)
            readf,lun,id
            free_lun, lun
            id=STRSPLIT(id,":",/EXTRACT)
            id=repstr(id[-1],'"}','')
        endif
        ourl = obj_new('IDLnetURL')
        oUrl->SetProperty, url_scheme='https'
        oUrl->SetProperty, URL_HOST='docs.google.com'
        url_path='/spreadsheets/d/'+id+'/export?format=csv'
        if  gid ne '' then url_path=url_path+'&gid='+gid
        oUrl->SetProperty, URL_PATH=url_path
        if  ~keyword_set(silent) then begin
            print,replicate('-',50)
            print,'fetch: docs.google.com/'+url_path
            print,'save: ',csvfile
        endif
        tmp=oUrl->Get(filename=csvfile)
        OBJ_DESTROY, oUrl
    endif
endif

if  ~keyword_set(silent) then begin
    print,replicate('-',50)
    print,'import data from: ',csvfile
endif

;+++
;** v8.5.1 workaround
if  n_elements(types) gt 0 then types[where(strmatch(types,'string',/f),/null)]='datetime'
;---

old_except=!except
!Except = 0

if  keyword_set(record_start) then begin
    void=query_csv(csvfile,csvinfo)    
    chead=read_csv(csvfile,$
            missing_value=missing_value,$
            num_records=max([record_cname,record_ctype,record_cunit,record_cnote])+1,$
            types=replicate('datatime',csvinfo.nfields))
    num_cols=n_elements(tag_names(chead))
    cname=[]
    ctype=[]
    cunit=[]
    cnote=[]
    for i=0,num_cols-1 do begin
        cname=[cname,chead.(i)[record_cname]]
        ctype=[ctype,chead.(i)[record_ctype]]
        cunit=[cunit,chead.(i)[record_cunit]]
        cnote=[cnote,chead.(i)[record_cnote]]
    endfor
    tab=read_csv(csvfile,$
            missing_value=missing_value,$
            types=ctype,n_table_header=record_start-1)
    header=cname
endif else begin
    tab=READ_CSV(csvfile,header=header,types=types,$
            missing_value=missing_value)
    cname=header
    if  n_elements(types) eq 0 then types=''
    ctype=types
endelse

void = Check_Math() & !Except =old_except

if  keyword_set(skey) then begin
    if  n_elements(skey) eq 1 and n_elements(sval) gt 1 then skey=replicate(skey,n_elements(sval))
    okay=0
    for i=0,n_elements(skey)-1 do begin
        colv=tab.(where(header eq skey[i]))
        okay=okay+strmatch(colv,sval[i],/fold_case) 
    endfor
endif else begin
    okay=replicate(1,n_elements(tab.(0)))
endelse

if  keyword_set(bkey) then begin
    for i=0,n_elements(bkey)-1 do begin
        colv=tab.(where(header eq bkey[i]))
        okay[where(colv eq '',/null)]=0
    endfor
endif

if  keyword_set(srow) then begin
    ind=srow[where(okay[srow] ne 0,/null)]
endif else begin
    ind=where(okay ne 0)
endelse

; EXTRACT SUBARRAY
tagnames=tag_names(tab)
if  not keyword_set(keeptags) then begin
    tagnames=IDL_VALIDNAME(header,/convert_all)
    tmp=rem_dup(tagnames)
    for i=0,n_elements(tmp)-1 do begin
        tag=where(tagnames eq tagnames[tmp[i]])
        if  n_elements(tag) gt 1 then tagnames[tag]=tagnames[tag]+'_dup'+strtrim(indgen(n_elements(tag)),2)
    endfor
endif

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
    print,replicate('-',50)
    print,'column no.: ', n_elements(header)
    print,'rows   no.: ', n_elements(tab.(0))
    print,replicate('-',50)
endif

if  not keyword_set(scalar)  then begin    
    tmpst={}
    for i=0,n_elements(header)-1 do begin
        tmpst=create_struct(tmpst,tagnames[i],(tab.(i))[0])
    endfor
    tmpsts=replicate(tmpst,n_elements(tab.(0)))
    for i=0,n_elements(header)-1 do begin
        tmpsts.(i)=tab.(i)
    endfor
    tab=tmpsts
endif

return,tab

END




