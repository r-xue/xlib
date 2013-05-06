PRO GAL_STRUCT_BUILD, proj, s, h, silent=silent
;+
; build a structure vector from a csv file
; sting:  structure from the cvs file
; header: table header
; proj: SGP (STING), RGP (REF GALXY), & CGP (CANON)
;-


path=ProgramRootDir()
csvfile=path+'data/'+proj+'.csv'
  
s=READ_CSV(csvfile,header=h)

if not keyword_set(silent) then begin
  print,'header--->'
  for i=0,n_elements(header)-1 do begin
  print,"<"+header[i]+">",size(s[0].(i),/tn),format='(a-50,a-50)'
  endfor
endif

END
