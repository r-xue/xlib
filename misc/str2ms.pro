FUNCTION STR2MS,string,estring=estring
;+
;   convert a string to a measurement structure 
;-

;   limited=-1   upper limits
;   limited=+1   lower limits
;   limits: gives the parameter limits on the lower and upper sides

ms={value:!values.f_nan,limited:!values.f_nan,limits:[!values.f_nan,!values.f_nan]}

if  strpos(string,'<') ne -1 then begin
    value=repstr(string,'<','')
    if  valid_num(value) then ms.value=float(value)
    ms.limited=-1
endif
if  strpos(string,'>') ne -1 then begin
    value=repstr(string,'>','')
    if  valid_num(value) then ms.value=float(value)
    ms.limited=1
endif
if  valid_num(string) then begin
    ms.value=float(string)
endif

if  n_elements(estring) eq 1 then begin
    if  valid_num(estring) then ms.limits=abs([float(estring),float(estring)])
endif
if  n_elements(estring) eq 2 then begin
    if  valid_num(estring[0]) then ms.limits[0]=abs(float(estring[0]))
    if  valid_num(estring[1]) then ms.limits[1]=abs(float(estring[1]))
endif

return,ms

END