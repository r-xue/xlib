PRO XLS2STRUCT,xlsfile,tab,hdr,silent=silent,refresh=refresh

;+
; NAME:
;   XLS2STRUCT ***(replaced by read_table.pro)***
;
; PURPOSE:
;   read a spreadsheet and load data into an IDL structure
;
; INPUTS:
;   xlsfile     xlsfile name (could be any spreadsheet format, e.g. odt) 
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
;   20130410  RX  introduced
;
;-

tab=read_table(xlsfile,header=hdr,silent=silent,refresh=refresh)

END

