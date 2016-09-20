PRO HTAU_GRID_RD,PATH=PATH
;+
; NAME:
;   HTAU_GRID_RD
;
; PURPOSE:
;   load HTAU templates into memory 
;
; OUTPUTS:
;   h2tau_grid structure
;
;
; HISTORY:
;
;   20120810  RX    introduced
;   20120314  RX    also read h1tau templates now
;   20130329  RX    a temporal fix for the IDL bug of acessing of structure data
;                   https://groups.google.com/forum/#!topic/comp.lang.idl-pvwave/2S95i-IfpY8
;
;-

if  n_elements(path) eq 0 then path='.'

COMMON htau,htau_data,htau_grid

print,replicate('-',40)
print,''
print,'Reading htau database/templates....'
print,''
restore,filename=path+'/htau_templates.xdr',/v
print,''
restore,filename=path+'/htau_database.xdr',/v
print,''
print,'done!'
print,''
print,replicate('-',40)

END

