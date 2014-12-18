PRO PINEPS, pdfname, epslist, clean=clean, print=print,$
    latex=latex,width=width,landscape=landscape,$
    nx=nx,papersize=papersize
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
;   papersize: top=0.1in, bottom=0.1in, left=0.1in, right=0.1in,paperheight=7.5in,paperwidth=7in
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
    
    psfiles=strjoin(fulllist,' ')
    if  keyword_set(width) then width=string(width,format='(f4.2)') else width='0.99'
    if  not keyword_set(nx) then nx=1
    openw, lun, pdfname+'.tex', /get_lun, width=400



    printf,lun,'\documentclass[12pt]{article}'
    printf,lun,'\usepackage{graphicx}'
    if  not keyword_set(papersize) then begin
        if  not keyword_set(landscape) $
            then printf,lun,'\usepackage[top=0.5in, bottom=0.5in, left=0.5in, right=0.5in,paper=letterpaper]{geometry}' $
            else printf,lun,'\usepackage[landscape,top=0.5in, bottom=0.5in, left=0.5in, right=0.5in,paper=letterpaper]{geometry}'
    endif else begin
        printf,lun,'\usepackage['+papersize+']{geometry}'
    endelse
    printf,lun,'\usepackage[belowskip=0pt,aboveskip=0pt]{caption}'
    printf,lun,'\setlength{\floatsep}{0pt plus 0pt minus 0pt}'
    
    printf,lun,'\begin{document}'
    printf,lun,'\pagenumbering{gobble}'
    for i=0,n_elements(fulllist)-1 do begin
        if  i mod nx eq nx-1 then begin
            printf,lun,'\noindent\includegraphics[width='+width+'\linewidth]{'+fulllist[i]+'}\\'
        endif else begin
            
            printf,lun,'\noindent\includegraphics[width='+width+'\linewidth]{'+fulllist[i]+'}'
        endelse
    endfor
    printf,lun,'\end{document}'
    close, lun
    free_lun, lun
    
    spawn,'latex '+pdfname+'.tex'
    ;spawn,'dvips '+pdfname+'.dvi -o'
    spawn,'dvipdfm '+pdfname+'.dvi'
    if keyword_set(clean) then spawn,'rm '+pdfname+'.dvi '+pdfname+'.aux '+pdfname+'.log '+pdfname+'.tex '
    cmd="rm -rf "+psfiles
    if keyword_set(clean) then spawn,cmd
    
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