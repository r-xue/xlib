PRO PINEPS, pdfname, epslist
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
;   20110217  RX  initial version
;-

fulllist=epslist+'.eps'
psfiles=strjoin(fulllist,' ')
cmd="gs -sDEVICE=pdfwrite -sOutputFile="
cmd=cmd+pdfname+'.pdf'
cmd=cmd+' -dNOPAUSE -dBATCH -q -dEPSCrop -c "<</Orientation 0>> setpagedevice " -f '
cmd=cmd+psfiles
spawn,cmd


END