FUNCTION err2str,afit,asig,op=op,format=format,det=det
;+
;   format error into three strings 
;-
if  n_elements(op) eq 0 then op='lin2log'
if  n_elements(format) eq 0 then format='(f+7.2)'
if  n_elements(det) eq 0 then det=1

pformat=repstr(format,'+','')
st=['','','']

alo=afit-asig
ahi=afit+asig
th=1.0*asig

if  op eq 'lin2log' then begin
    if  afit gt 1.0*th or det eq 0 then begin
        st[0]=string(alog10(afit),format=pformat)
        st[1]=string(alog10(ahi)-alog10(afit),format=format)
        st[2]=string(alog10(alo)-alog10(afit),format=format)
    endif else begin
        tmp=string(alog10(3.0*asig),format=pformat)
        pos=strpos(tmp,' ',/REVERSE_SEARCH)
        strput,tmp,'<',pos
        st[0]=tmp
    endelse
endif

if  op eq 'lin2lin' then begin
    if  afit gt 1.0*th or det eq 0 then begin
        st[0]=string(afit,format=pformat)
        st[1]=string(ahi-afit,format=format)
        st[2]=string(alo-afit,format=format)
    endif else begin
        tmp=string(th,format=pformat)
        pos=strpos(tmp,' ',/REVERSE_SEARCH)
        strput,tmp,'<',pos
        st[0]=tmp
    endelse
endif


return,st
END


PRO TEST_ERR2STR

out=err2str(1.09e18,1.05e17)
print,out
out=err2str( 2.49e+13,  2.37e+13)
print,out
END