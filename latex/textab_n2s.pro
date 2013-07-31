FUNCTION textab_n2s,number,format,len,left=left,right=right

if not keyword_set(left) then left=''
if not keyword_set(right) then right=''
s=left+string(number,format=format)+right
sublen=strlen(s)
if len gt sublen then s=strjoin(replicate('\phn',len-sublen))+s

return,s
END