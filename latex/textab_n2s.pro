FUNCTION textab_n2s,number,format,len,space=space,left=left,right=right
;+
;   format number to string & replace space with a placeholder
;-

if not keyword_set(left) then left=''
if not keyword_set(right) then right=''
if not keyword_set(space) then space='\phn'

s=string(number,format=format)
s=repchr(s,' ',space)

sublen=strlen(s)
if not keyword_set(len) then len=sublen
if len gt sublen then s=strjoin(replicate(space,len-sublen))+s

s=left+s+right
return,s
END