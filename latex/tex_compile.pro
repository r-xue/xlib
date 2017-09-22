PRO TEX_COMPILE,outname,$
    class=class,$
    template=template,$
    maintext=maintext,$
    nocompile=nocompile,$
    pdflatex=pdflatex,clean=clean,verbose=verbose

    
;+
; NAME:
;   TEX_COMPILE
; 
; PURPOSE:
;   IDL wraper for compiling latex
;   
; INPUT:
;   outname:        output file name
;   template:       latex template file name
;   maintext:       latex file having tex content
;                   final tex file = template + maintex
;   str_maintext:   maintext
;   str_head:       go before maintext
;   str_tail:       go after maintex
;   
;-

th=[]       ;   tex header
tt=[]       ;   tex tail....
tc=[]       ;   tex content
if  n_elements(class) eq 0 then class='aastex61'

if  n_elements(template) eq 0 then begin
    th=[th,'\documentclass[12pt]{'+class+'}']
    th=[th,'\usepackage{booktabs}']
    th=[th,'\begin{document}']
    th=[th,'\title{template}']
    tt=[tt,'\end{document}']
endif

if  n_elements(outname) eq 0 then begin
    outname='tex_compile_example'
endif

if  n_elements(maintext) ne 0 then begin
    for i=0,n_elements(maintext)-1 do begin
        readfmt,maintext[i],'(A0)',temp
        tc=[tc,temp]
    endfor
endif
if  n_elements(tc) eq 0 then tc=['just a test!']

ta=[th,$
    strjoin(replicate('%',50)),$
    strjoin(replicate('%',50)),$
    tc,$
    strjoin(replicate('%',50)),$
    strjoin(replicate('%',50)),$
    tt]   ; all tex info
forprint,ta,textout=outname+'.tex',/silent,/NOCOMMENT

if  ~keyword_set(nocompile) then begin
    
    if  keyword_set(pdflatex) then begin
        if  keyword_set(verbose) then begin
            spawn,'pdflatex -shell-escape '+outname+'.tex'
        endif else begin
            spawn,'pdflatex -shell-escape '+outname+'.tex',cmdlog
        endelse
    endif else begin
        if  keyword_set(verbose) then begin
            spawn,'latex '+outname+'.tex'
            spawn,'dvipdfm '+outname+'.dvi';spawn,'dvips '+pdfname+'.dvi -o'
        endif else begin
            spawn,'latex '+outname+'.tex',cmdlog
            spawn,'dvipdfm '+outname+'.dvi',cmdlog;spawn,'dvips '+pdfname+'.dvi -o'
        endelse
    endelse
    
    if  keyword_set(clean) then begin
        extlist=['.dvi','.aux','.log','Notes.bib']
        for i=0,n_elements(extlist)-1 do begin
            if  file_test(outname+extlist[i]) then spawn,'rm '+outname+extlist[i]
        endfor
    endif

endif


END
