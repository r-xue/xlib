;+
; NAME: TEX_TABLE
; PURPOSE:
;
; print out an IDL array in LaTeX table syntax, suitable for pasting
; into your paper.
;
;
; INPUTS:
;       table   some 2d array
;       
; KEYWORDS:
;       labels      string array of labels. Goes into the first row
;       /labelrows  use labels for rows (default is columns
;       /longtable  use longtable instead of deluxetable
;       nozeros:    ... 
;       midrule:    after the <midrule>-th line, add /midrule
;       caption:    table title
;       tablehead:  tablehead in the deluxeable format
;       
; OUTPUTS:
;
; HISTORY:
;   
;   20170906    RX  introduced (heavily modified from texprint.pro of M. Perrin 
;   
; NOTES:
;   labels+lablerows will add a column or row in addition to the table content
;-

PRO tex_table, table,nozeros=nozeros,labels=labels,head=head,$
    textout=textout,longtable=longtable,caption=caption,$
    labelrows=labelrows,$
    tablehead=tablehead,$
    midrule=midrule

    if ~(keyword_set(textout)) then textout=1


    sz = size(table)
    ncol = sz[1]
    nrow = sz[2]


    textopen,'TEXPRINT',TEXTOUT=textout,SILENT=silent

    if keyword_set(head) then begin
        nc = ncol + (keyword_set(labels)*keyword_set(labelrows))
        align=strc(strc(strarr(nc)+"l",/join,delim=""))
        if ~(keyword_set(longtable)) then begin
            printf,!TEXTUNIT, "\begin{deluxetable}{"+align+"}"
            printf,!TEXTUNIT, "\tablecolumns{"+strc(nc)+"}"
            if keyword_set(caption) then  printf,!TEXTUNIT, "\tablecaption{"+caption+"}"
            
            ;   ADD \TABLEHEAD{}
            if  keyword_set(tablehead) then begin
                printf,!TEXTUNIT, "\tablehead{"
                for i=0,n_elements(tablehead)-1 do begin
                    temp='\multicolumn{1}{c}{'+tablehead[i]+'}'
                    if  i ne n_elements(tablehead)-1 then temp=temp+'&'
                    printf,!TEXTUNIT, temp
                endfor
                printf,!TEXTUNIT, "}"
            endif
            
            
            printf,!TEXTUNIT, "\startdata"
            printf,!TEXTUNIT, "\toprule"
        endif else  begin
            printf,!TEXTUNIT, "\begin{longtable}{"+align+"}"
            ;           printf,!TEXTUNIT, "\tablecolumns{"+strc(nc)+"}"
            ;           if keyword_set(caption) then  printf,!TEXTUNIT, "\tablecaption{"+caption+"}"
            printf,!TEXTUNIT, "\hline"
            printf,!TEXTUNIT, "\endhead"
            if keyword_set(caption) then  printf,!TEXTUNIT, "\caption{"+caption+"} \\"
        endelse


    endif

    ; label columns
    if keyword_set(labels) and ~keyword_set(labelrows) then begin
        for ic=0L,ncol-2 do begin
            printf,!TEXTUNIT,  labels[ic],format = '($,A," & ")'
        endfor
        printf,!TEXTUNIT,labels[ic]," \\"
    endif

    for ir=0L,nrow-1 do begin
        if keyword_set(labels) and keyword_set(labelrows) then printf,!TEXTUNIT, labels[ir],format='($,A," & ")'
        for ic=0L,ncol-2 do begin
            if keyword_set(nozeros) && table[ic,ir] eq 0 then $
                printf,!TEXTUNIT,  "      ",format='($,A," & ")' else $
                printf,!TEXTUNIT,  table[ic,ir],format = '($,A," & ")'
        endfor
        if keyword_set(nozeros) && table[ic,ir] eq 0 then printf,!TEXTUNIT,  "    \\ " else printf,!TEXTUNIT,table[ic,ir]," \\"
        if  n_elements(midrule) ne 0 then begin
            if  (where(midrule eq ir+1))[0] ne -1 then printf,!TEXTUNIT,"\midrule"
        endif
    endfor
    if keyword_set(head) then begin
        if ~(keyword_set(longtable)) then begin
            printf,!TEXTUNIT, "\bottomrule"
            printf,!TEXTUNIT, "\enddata"
            printf,!TEXTUNIT, "\end{deluxetable}"
        endif else begin
            printf,!TEXTUNIT, "\hline"
            printf,!TEXTUNIT, "\end{longtable}"
        endelse
    endif

    textclose, TEXTOUT = textout          ;Close unit opened by TEXTOPEN


end
