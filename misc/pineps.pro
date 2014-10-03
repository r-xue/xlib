PRO PINEPS, pdfname, epslist, clean=clean, print=print,$
    latex=latex,width=width
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
;   20141001  RX  add the latex option  
;-

fulllist=epslist+'.eps'
if  not keyword_set(latex) then begin

    psfiles=strjoin(fulllist,' ')
    cmd="gs -sDEVICE=pdfwrite -sOutputFile="
    cmd=cmd+pdfname+'.pdf'
    cmd=cmd+' -dNOPAUSE -dBATCH -q -dEPSCrop -c "<</Orientation 0>> setpagedevice " -f '
    cmd=cmd+psfiles
    if  keyword_set(print) then begin
        print,replicate('>',10)
        print,cmd
        print,replicate('>',10)
    endif
    spawn,cmd
    
    cmd="rm -rf "+psfiles
    if keyword_set(clean) then spawn,cmd

endif else begin
    
    if  keyword_set(width) then width=string(latex_width,format='(f4.2)') else width='0.99'
    openw, lun, pdfname+'.tex', /get_lun, width=400

    printf,lun,'\documentclass[12pt]{article}'
    printf,lun,'\usepackage{graphicx}'
    printf,lun,'\usepackage[top=0.5in, bottom=0.5in, left=0.5in, right=0.5in,paper=letterpaper]{geometry}'
    printf,lun,'\usepackage[belowskip=0pt,aboveskip=0pt]{caption}'
    printf,lun,'\setlength{\floatsep}{0pt plus 0pt minus 0pt}'
    
    printf,lun,'\begin{document}'
    
    for i=0,n_elements(fulllist)-1 do begin
        if  i eq n_elements(fulllist)-1 then begin
            printf,lun,'\noindent\includegraphics[width='+width+'\linewidth]{'+fulllist[i]+'}'
        endif else begin
            printf,lun,'\noindent\includegraphics[width='+width+'\linewidth]{'+fulllist[i]+'}\\'
        endelse
    endfor
    printf,lun,'\end{document}'
    close, lun
    free_lun, lun
    
    spawn,'latex '+pdfname+'.tex'
    spawn,'dvips '+pdfname+'.dvi -o'
    if keyword_set(clean) then spawn,'rm '+pdfname+'.dvi '+pdfname+'.aux '+pdfname+'.log '+pdfname+'.tex '
    
endelse

END

PRO TEST0_PINEPS
list=file_search("?mc/??????.eps")
list=repstr(list,'.eps','')
pineps.csh
END

PRO TEST1_PINEPS
list=file_search("*/*mom*.eps")
list=repstr(list,'.eps','')
pineps,'sting_msc_momx',list
END

PRO TEST2_PINEPS
list=file_search("*.eps")
list=repstr(list,'.eps','')
pineps,'hello',list,/latex
END