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

; READ FILEINFO FROM A CSV FILE
if proj eq 'MGP' then begin
  
  path=ProgramRootDir()
  csvfile=path+'../data/'+proj+'_fileinfo.csv'
  s=READ_CSV(csvfile,header=h)
  ; switch from a structure to a structure array
  fileinfo=[]
  for j=0,n_elements(s.(0))-1 do begin
    tmpst={}
    for i=0,n_elements(h)-1 do begin
      tmpst=create_struct(tmpst,h[i],(s.(i))[j])
    endfor
    fileinfo=[fileinfo,tmpst]
  endfor
  
endif


;if proj eq 'MGP' then begin
;  fileinfo=mcs_fileinfo()
;endif


return,fileinfo

END