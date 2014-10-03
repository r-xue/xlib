PRO LATEXEPS, pdfname, epslist, clean=clean, print=print
;+
; NAME:
;   PINEPS
;
; PURPOSE:
;   combine eps files into a multi-page pdf
;
; INPUTS:
;   PDFNAME   -- name of the output pdf file
;   EPSLIST   -- eps file name list
;
; HISTORY:
;
;   20110217  RX  introduced
;-
openw, lun2, 'filename, /get_lun, width=400

END


PRO TEST_PINEPS

list=file_search("*/*mom*.eps")
list=repstr(list,'.eps','')
pineps,'sting_msc_momx',list


END


PRO MC_PINEPS

list=file_search("?mc/??????.eps")
list=repstr(list,'.eps','')
pineps.csh


END