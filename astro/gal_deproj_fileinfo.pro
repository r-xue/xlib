FUNCTION GAL_DEPROJ_FILEINFO, proj

; A WRAP SCRIPT FOR DIFFERENT FILEINFO OF VARIOUS PROJECTS

; FOR PAH PROPOSAL
if proj eq 'CGP' then begin
  fileinfo=pah_fileinfo()
endif

; FOR STING
if proj eq 'SGP' then begin
  fileinfo=st_fileinfo()
endif

return,fileinfo

END