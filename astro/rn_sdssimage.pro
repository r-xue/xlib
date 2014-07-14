PRO RN_SDSSIMAGE
;+
;   rename SDSS image fits file (usuall from http://dr10.sdss3.org/bulkFields/names
;-

readcol,'sdss_rn.txt',galaxy,runid,format='a,a'

i=0
foreach id,runid do begin
    flist=file_search("*"+id+"*.fits",count=count)
    if  count ne 0 then begin
        foreach oldfile,flist do begin
            basename=galaxy[i]+'.'+strmid(oldfile,0,7)+'.fits'
            cmd='cp -rf '+oldfile+' '+basename
            spawn,cmd
        endforeach
    endif
i=i+1
endforeach

END