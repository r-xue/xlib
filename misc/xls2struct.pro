PRO XLS2STRUCT,xlsfile,tab,hdr,silent=silent,refresh=refresh

;+
; NAME:
;   XLS2STRUCT
;
; PURPOSE:
;   read a spreadsheet and load data into an IDL structure
;
; INPUTS:
;   xlsfile     xlsfile name (actually can be almost any spreadsheet format, e.g. odt) 
;               by default, the xlsx file will be convert into csv,
;               then read by IDL
;
; OUTPUTS:
;   tab         table content
;   hdr         table header
; 
; KEYWORDS:
;   SILENT      no verbose log
;   REFRESH     don't use unoconv to refresh the csv file from .xlsx
;   
; REQURIEMENT:
;   unoconv     https://github.com/dagwieers/unoconv
;   libreoffice http://www.libreoffice.org
; 
; NOTE:
;   
;   unoconv+libreoffice may occasionally hang.
;   using them in the listenser mode can solve this problem:
;   >unoconv --listener&
;   
;   A csv file with the same root name will be created in your spreasheet directory 
;   
; HISTORY:
;
;   20130410  RX  modified from h2line_struct_build.pro
;
;-

rootname=cgrootname(xlsfile,dir=dir,ext=ext)
csvfile=xlsfile
if  ext ne 'csv' then begin
    csvfile=dir+rootname+'.csv'
    if keyword_set(refresh) then begin
        cmd='unoconv -f csv -o '+csvfile+' '+xlsfile
        spawn,cmd
    endif
endif

tab=READ_CSV(csvfile,header=hdr)

if not keyword_set(silent) then begin
    print,'header--->'
    for i=0,n_elements(hdr)-1 do begin
        print,"<"+hdr[i]+">",size(tab[0].(i),/tn),format='(a-50,a-50)'
    endfor
    print,'column: ', n_elements(hdr)
    print,'rows:   ', n_elements(tab.(0))
endif

END