PRO PINEPS, pdfname, epslist, clean=clean, verbose=verbose,$
    latex=latex,pdflatex=pdflatex,width=width,landscape=landscape,$
    nx=nx,papersize=papersize,ps=ps
;+
; NAME:
;   PINEPS
;
; PURPOSE:
;   combine eps files into a multi-page pdf
;   two options are available:
;       * gs: eps figures are put into individual pages of the output PDF file 
;       * latex: you can set up your preferred layouts using several latex-related keywords
;
; INPUTS:
;   PDFNAME     -- name of the output pdf file
;   EPSLIST     -- eps file name list
;   papersize   -- top=0.1in, bottom=0.1in, left=0.1in, right=0.1in,paperheight=7.5in,paperwidth=7in
;   width       -- for /latex   width of each panel
;   nx          -- for /latex   number of panels in each row
;
; KEYWORDS:
;   latex         use latex (or pdflatex) to combine eps
;   pdflatex      optionally use pdflatex
;   verbose       verbose ouput
;   ps            input plots are in .ps rather than .eps
;   
; HISTORY:
;
;   20110217  RX  introduced
;   20141001  RX  add the latex option  
;-

;++++++
;if  keyword_set(ps) then begin
;    for i=0,n_elements(epslist)-1 do begin
;        cmd="ps2eps -f "+epslist[i]+'.ps'
;        spawn,cmd
;    endfor
;endif
;fulllist=epslist+'.eps'
;------

if  keyword_set(ps) then fulllist=epslist+'.ps' else fulllist=epslist+'.eps'

tag=where(file_test(fulllist) ne 0)
fulllist=fulllist[tag]

if  not keyword_set(latex) then begin

    psfiles=strjoin(fulllist,' ')
    cmd="gs -sDEVICE=pdfwrite -sOutputFile="
    cmd=cmd+pdfname+'.pdf'
    if  keyword_set(landscape) then begin
        cmd=cmd+' -dNOPAUSE -dBATCH -q -dEPSCrop -c "<</Orientation 1>> setpagedevice " -f '
    endif else begin
        cmd=cmd+' -dNOPAUSE -dBATCH -q -dEPSCrop -c "<</Orientation 0>> setpagedevice " -f '
    endelse
    cmd=cmd+psfiles
    if  keyword_set(verbose) then begin
        print,replicate('>',10)
        print,cmd
        print,replicate('>',10)
    endif
    spawn,cmd
    
    cmd="rm -rf "+psfiles
    if keyword_set(clean) then spawn,cmd

endif else begin

    if  keyword_set(width) then width=string(width,format='(f4.2)') else width='0.99'
    if  not keyword_set(nx) then nx=1
    openw, lun, 'tmp_pineps.tex', /get_lun, width=400

    printf,lun,'\documentclass[12pt]{article}'
    printf,lun,'\usepackage{graphicx}'
    printf,lun,'\usepackage{epstopdf}'
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
        if  i mod nx eq nx-1 and i ne n_elements(fulllist)-1  then begin
            printf,lun,'\noindent\includegraphics[width='+width+'\linewidth]{'+fulllist[i]+'}\\'
        endif else begin
            printf,lun,'\noindent\includegraphics[width='+width+'\linewidth]{'+fulllist[i]+'}'
        endelse
    endfor
    printf,lun,'\end{document}'
    close, lun
    free_lun, lun
    
    if  keyword_set(pdflatex) then begin
        if  keyword_set(verbose) then begin
            spawn,'pdflatex -shell-escape tmp_pineps.tex'
        endif else begin
            spawn,'pdflatex -shell-escape tmp_pineps.tex',cmdlog
        endelse
    endif else begin
        if  keyword_set(verbose) then begin
            spawn,'latex tmp_pineps.tex'
            spawn,'dvipdfm tmp_pineps.dvi';spawn,'dvips '+pdfname+'.dvi -o'
        endif else begin
            spawn,'latex tmp_pineps.tex',cmdlog
            spawn,'dvipdfm tmp_pineps.dvi',cmdlog;spawn,'dvips '+pdfname+'.dvi -o'
        endelse
    endelse
    
    ;   RENAME LATEX TMP FILES
    spawn,'mv tmp_pineps.pdf '+pdfname+'.pdf'
    extlist=['.dvi','.aux','.log','.tex']
    for k=0,n_elements(extlist)-1 do begin
        if  file_test('tmp_pineps'+extlist[k]) then begin
            spawn,'mv tmp_pineps'+extlist[k]+' '+pdfname+extlist[k]
            if  keyword_set(clean) then spawn,'rm '+pdfname+extlist[k]
        endif
    endfor
    
    ;   REMOVE INDIVIDUAL EPS FILES
    if  keyword_set(clean) then begin
        psfiles=strjoin(fulllist,' ')
        cmd="rm -rf "+psfiles
        spawn,cmd
    endif
    
    ;   CLEAN UP PDFLATEX EPS STRACH
    if  keyword_set(pdflatex) then begin
        psfiles=repstr(fulllist,'.eps','-eps-converted-to.pdf')
        psfiles=strjoin(psfiles,' ')
        cmd="rm -rf "+psfiles
        spawn,cmd
    endif
    
endelse


if  keyword_set(ps) and keyword_set(clean) then begin
    psfiles=repstr(fulllist,'.eps','.ps')
    psfiles=strjoin(psfiles,' ')
    cmd="rm -rf "+psfiles
    spawn,cmd
endif

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

PRO TEST3_PINEPS

list=['xhs_stack_radprofile_gal_WRC4_pcf_lae_cluster_median.eps',$
    'xhs_stack_radprofile_gal_WRC4_pcf_lae_field_median.eps',$
    'xhs_stack_radprofile_gal_R_pcf_lae_cluster_median.eps',$
    'xhs_stack_radprofile_gal_R_pcf_lae_field_median.eps']
list=repstr(list,'.eps','')
pineps,'hello',list,/latex,width=0.48,nx=2,papersize='top=0.1in, bottom=0.1in, left=0.1in, right=0.01in,paperheight=6.0in,paperwidth=7.5in'

END