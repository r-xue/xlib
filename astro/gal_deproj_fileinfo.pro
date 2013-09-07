FUNCTION GAL_DEPROJ_FILEINFO, proj

; A WRAP SCRIPT FOR DIFFERENT FILEINFO OF VARIOUS PROJECTS

forward_function pah_fileinfo
forward_function st_fileinfo
forward_function things_fileinfo
forward_function coma_fileinfo

; FOR PAH PROPOSAL
if proj eq 'CGP' then begin
  fileinfo=pah_fileinfo()
endif

; FOR STING
if proj eq 'SGP' then begin
  fileinfo=st_fileinfo()
endif

if proj eq 'TGP' then begin
  fileinfo=things_fileinfo()
endif

if proj eq 'Coma' or proj eq 'Coma0' then begin
  fileinfo=coma_fileinfo()
endif

if proj eq 'MGP' then begin
  fileinfo=mcs_fileinfo()
endif

return,fileinfo

END