PRO MAKE_CUTOUTS,objs,proj=proj,$
    mode=mode
;+
;
;   objs:    OBJ META DATA
;   
;-
;+
;general:
;   
;   str.source      source name
;   str.objname     objname
;   str.ra          source ra
;   str.dec         source dec
;   str.bxsz        cutout box size     (in arcsec)
;   str.cell        cutout cell size    (in arcsec)
;   str.band        band name
;   str.imfile      fits image name
;   str.imext       fits image extension
;   str.cutouts     0:  imfile<-orginal data
;                   1:  imfile<-cutout from hextract (subregion covers cutout box)
;                   2:  imfile<-cutout from hastrom (resampling);                   
;   mode    1 hextractx
;   mode    2 hastrom
;   mode    3 hextract
;plotting:   
;   str.ptile       percentile for color scaling
;
;-

if  ~keyword_set(proj) then proj='make_cutouts_temp'
if  ~keyword_set(mode) then mode=1

;   FIND OUT A LIST OF UNIQ FITS/EXTENSION COMBINATIONS

imlist=strtrim(objs.imfile,2)+strtrim(round(objs.imext),2)
temp1=rem_dup(imlist)
temp2=where((objs.imfile)[temp1] ne '',/null)
ulist=imlist[temp1[temp2]]
print,imlist[*,1]
;   LOOP THROUGH EACH FILE 

foreach filename,ulist do begin
    
    print,''
    print,'-->',filename
    print,''
    
    tag=array_indices(imlist,where(imlist eq filename))
    otag=transpose(tag[1,*])
    btag=transpose(tag[0,*])
    
    im=readfits(objs[otag[0]].imfile[btag[0]],hd,$
        ext=objs[otag[0]].imext[btag[0]],/silent)
    
    for i=0,n_elements(otag)-1 do begin
        io=otag[i]
        ib=btag[i]
        print,'<<<<<',string(i+1,format='(i3)')+'/'+strtrim(n_elements(otag),2),$
            ' obj: ', objs[io].source,$
            adstring(objs[io].ra,objs[io].dec,2),$
            ' band: ',objs[io].band[ib]
        
        if  mode eq 1 then begin
            hextractx,im,hd,$
                radec=[objs[io].ra,objs[io].dec],subim,subhd,$
                (objs[io].bxsz)[ib]*[0.5,-0.5],$
                (objs[io].bxsz)[ib]*[-0.5,0.5],/silent
            outname=objs[io].source+'_'+(objs[io].band)[ib]+'.fits'
            sxaddpar, subhd, 'DATAMAX', max(subim,/nan),before='HISTORY'
            sxaddpar, subhd, 'DATAMIN', min(subim,/nan),before='HISTORY'
            writefits,outname,subim,subhd
            objs[io].imfile[ib]=outname
            objs[io].imext[ib]=0
        endif

        if  mode eq 2 then begin
            psize=(objs[io].cell)[ib]
            temphd=mk_hd([objs[io].ra,objs[io].dec],$
                fix(((objs[io].bxsz)[ib]/psize)/2.0)*2.0+1.0,psize)
            hastrom_nan,im,hd,subim,subhd,temphd,missing=!VALUES.F_NAN,/silent,$
                interp=0
            outname=objs[io].source+'_'+(objs[io].band)[ib]+'.fits'
            sxaddpar, subhd, 'DATAMAX', max(subim,/nan),before='HISTORY'
            sxaddpar, subhd, 'DATAMIN', min(subim,/nan),before='HISTORY'
            writefits,outname,subim,subhd
            objs[io].imfile[ib]=outname
            objs[io].imext[ib]=0
        endif        
        
        if  mode eq 3 then begin
            sz=size(im,/d)
            getrot,hd,rotang,cdelt
            psize=abs(cdelt[0]*60.*60.)
            hbx=fix((objs[io].bxsz)[ib]/2.0/psize)
            adxy,hd,objs[io].ra,objs[io].dec,x,y
            xmin=fix(x)-hbx
            xmax=fix(x)+hbx
            ymin=fix(y)-hbx
            ymax=fix(y)+hbx
            if  not (xmin ge 0 and xmax lt sz[0] and ymin ge 0 and ymax lt sz[1]) then continue
            hextract,im,hd,subim,subhd,xmin,xmax,ymin,ymax
            outname=objs[io].source+'_'+(objs[io].band)[ib]+'.fits'
            sxaddpar, subhd, 'DATAMAX', max(subim,/nan),before='HISTORY'
            sxaddpar, subhd, 'DATAMIN', min(subim,/nan),before='HISTORY'
            writefits,outname,subim,subhd
            objs[io].imfile[ib]=outname
            objs[io].imext[ib]=0
        endif
        
        print,'>>>>>',outname        
    endfor
    
endforeach
print,''

save,objs,filename=proj+'.dat'

END