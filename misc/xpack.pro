PRO XPACK,indir,outfile,$
    include_path=include_path,$
    exclude_path=exclude_path
;+
; NAME:
;   XPACK
;
; PURPOSE:
;   check dependencies and create an all-in-one tar file 
;   for a software package
;   (exclude any IDL astronomy library files by default) 
;
; INPUTS:
;   indir         --  path of the software package
;   outfile       --  output tar file name
;   include_path  --  dependency path(s) to be included
;                     (overridden by exclude_path)
;   exclude_path  --  dependency path(s) to be excluded
;   
; OUTPUTS:
;   <outfile>.tar.gz
;
; HISTORY:
;   20120740  RX  initial version
;
; DEPENDENCE:
;   IDLdep
;-

if n_elements(include_path) eq 0 then $
  include_path=['/Users/Rui/Dropbox/Worklib/idl/resource']
if n_elements(exclude_path) eq 0 then $
  exclude_path=['/Users/Rui/Dropbox/Worklib/idl/resource/astron']
include_path=[include_path,indir]


filelist=File_Search(indir+'/*.pro')
src=[]
for i=0,n_elements(filelist)-1 do begin
  dep = finddep_all(filelist[i], /only_source, /no_builtin)
  src = [src,dep.source]
endfor
src = src[uniq(src, sort(src))]
copy_tag=fltarr(n_elements(src))

; include_path
if n_elements(include_path) ne 0 then begin
  for i=0,n_elements(include_path)-1 do begin
    copy_tag[where(strpos(src,include_path[i]) ne -1)]=1
  endfor
endif

; exclude_path
if n_elements(exclude_path) ne 0 then begin
  for i=0,n_elements(exclude_path)-1 do begin
    copy_tag[where(strpos(src,exclude_path[i]) ne -1,/null)]=0
  endfor
endif

src=src[where(copy_tag,/null)] 

outdir=(strsplit(outfile,'.',/ext))[0]      
if ~file_test(outdir) then file_mkdir, outdir
file_copy, src, outdir, /over
cmd='tar czvf '+outfile+' '+outdir+'/*'
spawn,cmd

END


PRO TEST_XPACK
;+
;   create a standalone working package for idl-moments
;   (exclude IDL astronomy library dependences)
;-

indir='/Users/Rui/Dropbox/Worklib/idl/resource/moments'
include_path=['/Users/Rui/Dropbox/Worklib/idl/resource/cprops',$
              '/Users/Rui/Dropbox/Worklib/idl/resource/idl-low-sky']
exclude_path=['/Users/Rui/Dropbox/Worklib/idl/resource/astron']

xpack,indir,'idl-moments.tar.gz',include_path=include_path,$
  exclude_path=exclude_path
  
    
END
