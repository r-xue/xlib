PRO PINEPS, pdfname, epslist, clean=clean
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

fulllist=epslist+'.eps'
psfiles=strjoin(fulllist,' ')
cmd="gs -sDEVICE=pdfwrite -sOutputFile="
cmd=cmd+pdfname+'.pdf'
cmd=cmd+' -dNOPAUSE -dBATCH -q -dEPSCrop -c "<</Orientation 0>> setpagedevice " -f '
cmd=cmd+psfiles
spawn,cmd

cmd="rm -rf "+psfiles
if keyword_set(clean) then spawn,cmd

END