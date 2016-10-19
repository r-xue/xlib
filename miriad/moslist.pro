FUNCTION MOSLIST,mir,vis=vis
;+
;   return the mosaicing information as a structure from miriad-vis/mostab 
;-

if  keyword_set(vis) then begin

    print,replicate('+',30)
    cmd='uvindex vis='+mir+' log='+mir+'.moslist.log'
    print,'run miriad: '+cmd
    if  ~file_test(mir+'.moslist.log') then spawn,cmd
    print,replicate('+',30)

    log=mir+'.moslist.log'

    nlines = FILE_LINES(log)
    sarr = STRARR(nlines)
    OPENR, unit, log,/GET_LUN
    READF, unit, sarr
    FREE_LUN, unit
    tag1=where(sarr eq 'The input data-set contains the following pointings:')
    tag2=where(sarr eq '------------------------------------------------')
    ll=where(tag2 gt tag1[0]) 
    tag2=(tag2[ll])[0]

    readcol,log,source,ra,dec,dra0,ddec0,format='a,a,a,f,f',skipline=tag1,numline=tag2-tag1,/silent
    print,'no. of source',n_elements(ra)
    print,replicate('+',30)
    print,source,ra,dec
    print,replicate('+',30)
    readcol,log,dra,ddec,format='f,f',skipline=tag1,numline=tag2-tag1,/silent
    if  n_elements(dra) eq 0 then begin
        dra=[]
        ddec=[]
    endif
    print,'no. of pointing',n_elements(dra)+1

    dra=[dra0,dra]
    ddec=[ddec0,ddec]
    ra=tenv(ra)*15.
    dec=tenv(dec)
    mostable={source:source,ra:ra,dec:dec,dra:dra,ddec:ddec}

endif else begin

    source=''
    print,replicate('+',30)
    cmd="imlist in="+mir+" options=mosaic >"+mir+'.moslist.log'
    print,'run miriad: '+cmd
    spawn,cmd
    print,replicate('+',30)

    readcol,mir+'.moslist.log',id,nx,ny,ra,dec,array,rms,format='f,f,f,a,a,a,f'
    radec=ra+dec
    p_ra=tenv(ra)*15.
    p_dec=tenv(dec)

    im=readmir(mir,hd)
    SXADDPAR,hd,'NAXIS',2
    SXDELPAR,hd,'NAXIS3'
    SXDELPAR,hd,'NAXIS4'
    xc=sxpar(hd,'CRPIX1')-1
    yc=sxpar(hd,'CRPIX2')-1
    ra=sxpar(hd,'CRVAL1')
    dec=sxpar(hd,'CRVAL2')
    adxy,hd,p_ra,p_dec,xp,yp

    getrot,hd,rotang,cdelt
    psize=abs(cdelt[0]*60.*60.)
    dra=-(xp-xc)*psize
    ddec=(yp-yc)*psize

    mostable={source:source,ra:ra,dec:dec,dra:dra,ddec:ddec,rms:rms}

endelse

return,mostable

END

;    x=[]
;    y=[]
;    z=[]
;    for i=0,n_elements(uniq)-1 do begin
;        print,i,radec[uniq[i]]
;        tag=where(radec eq radec[uniq[i]])
;        rms0=sqrt(total(rms[tag]^2.0))
;        print,ra[uniq[i]],dec[uniq[i]],rms0
;        x=[x,ra[uniq[i]]]
;        y=[y,dec[uniq[i]]]
;        z=[z,rms0]
;    endfor
;
;    z=(1/z)
;    z=z/max(z)
;    xc=median(x)
;    yc=median(y)
;    ;plot,mostab.dra,mostab.ddec,psym=symcat(16)
;   mostab=moslist('ngc6951.co.cm')
;   print,mostab
;   oplot,mostab.dra,mostab.ddec,psym=3

