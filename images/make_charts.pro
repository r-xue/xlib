PRO MAKE_CHARTS,OBJ,mode=mode,$
    outname=outname,$
    cross=cross,layout=layout
    
;+
; NAME:
;   make_charts
;
; PURPOSE:
;   make finding charts
;
; INPUTS:
;   obj:    object structure vector
;           .source     source name
;           .objname    object name
;           .label      object label
;           .ra         RA
;           .dec        DEC
;           .bxsz       box size (in arcsec)
;           .cell       cell size (in arcsec)
;                       actually the cell size was determined by device dpi
;           .band       band name
;           .imfile     fits image full path
;           .imext      fits image extension
;           .ptile_min  min percentile for color scaling
;           .ptile_max  max percentile for color scaling
;   mode:   =0  images has been reprocessed to the desired size
;           =1  images will be plotted as polygon
;           =2  images will be plotted after resampling 
;
; OUTOUTS:
;   outname     outout eps file name list
;   
; KEYWORDS:
;   cross:      plot cross at center rather than bars to the left and top
;   layout:     see below (hold the input for pos_mp.pro)
; 
; EXAMPLE:
;   see TEST_MAKE_CHARTS
;
; HISTORY:
;   20150812    R.Xue   add comments
;   20150820    R.Xue   add comments
;-

if  n_elements(mode) eq 0 then mode=2

;   LOAD ALL LARGE IMAGES TOGETHER INTO MEMORY 

nobj=n_elements(obj.source)
imlist=[]
for i=0,nobj-1 do begin
    imlist=[imlist,obj[i].imfile]
endfor
imlist=imlist[rem_dup(imlist)]
imlist=imlist[where(imlist ne '',/null)]
print,'+++'
print,'load fits images into memory:'
print,'+++'
imfits=[]
for i=0,n_elements(imlist)-1 do begin
    print,imlist[i]
    rdfits_struct,imlist[i],tmp
    tmp=ptr_new(tmp,/no_copy)
    imfits=[imfits,tmp]
endfor

;   SETUP LAYOUTS

if  not keyword_set(layout) then begin    
layout={xsize:8,$
        ysize:1.5,$
        nxy:[n_elements((obj[0].imfile)),1],$
        margin:[0.01,0.01],$
        omargin:[0.06,0.02,0.01,0.02],$
        type:0}
endif

;   PLOT INDIVIDUAL OBJECTS

outname=[]
for nc=0,nobj-1 do begin
    
    print,replicate('>',20) 
    print,strtrim(nc+1,2)+'/'+strtrim(nobj,2)
    print,replicate('<',20)
    
    mra=obj[nc].ra
    mdec=obj[nc].dec
    bxsz=obj[nc].bxsz
    cell=obj[nc].cell
    imfile=obj[nc].imfile
    band=obj[nc].band
    oname=obj[nc].label
    ptile=obj[nc].ptile_max
    ext=obj[nc].imext
    
    psfile=strtrim(obj[nc].source,2)
    outname=[outname,psfile]
    set_plot,'ps'
    device, file=psfile+'.eps', /color, bits=8, /encapsulated,$
        xsize=layout.xsize,ysize=layout.ysize,/inches,xoffset=0.0,yoffset=0.0
    !p.thick=1.5
    !x.thick = 1.5
    !y.thick = 1.5
    !z.thick = 1.5
    !p.charsize=0.85
    !p.charthick=1.5
    !x.gridstyle = 0
    !y.gridstyle = 0
    xyouts,'!6'

    for i=0,n_elements(imfile)-1 do begin
        
        tag=(where(imlist eq imfile[i]))[0]
        if  tag eq -1 then continue
        
        print,band[i],' ',imfile[i]
        pos=pos_mp(i,layout.nxy,layout.margin,layout.omargin)
        posp=pos.position
        xtickname=replicate(' ',60)
        ytickname=replicate(' ',60)
        xtitle=' '
        ytitle=' '
        if  pos.px eq 0 and pos.py eq (layout.nxy)[1]-1 then begin
            xtickname=!null
            ytickname=!null
            xtitle=textoidl("!6\delta(R.A.) ['']")
            ytitle=textoidl("!6\delta(Dec.) ['']")
        endif
        if  i eq floor((layout.nxy)[0]/2.0)-1 and (layout.nxy)[0] ne 1 then xtitle=oname
        cgloadct,0
        subim=fltarr(10,10)+255
        cgimage,subim,pos=posp,/keep,/noe
        subtitle='!6'+band[i]

        if  mode eq 2 or mode eq 0 then begin

            psize=dpxy(20.,ibox=[2.0,2.0],dpi=150,/silent)
            psize=min(1.0/psize)

            if  mode eq 2 then begin
                hdr0=(*imfits[tag]).hdr0
                temphd=mk_hd([mra,mdec],fix((bxsz[i]/psize)/2.0)*2+1,psize)
                ;sxaddpar,hdr0,'EQUINOX',2000.0
                if  ext[i] eq 0 then $
                    hastrom_nan,(*imfits[tag]).im0,hdr0,subim,subhd,temphd,missing=!VALUES.F_NAN,/silent,$
                        interp=0   
                if  ext[i] eq 1 then $
                    hastrom_nan,(*imfits[tag]).im1,hdr1,subim,subhd,temphd,missing=!VALUES.F_NAN,/silent,$
                        interp=0   
            endif
            if  mode eq 0 then begin
                subhd=(*imfits[tag]).hdr0
                subim=(*imfits[tag]).im0
            endif
            
            if  not (min(subim,/nan) ne max(subim,/nan) and total(subim eq subim) gt 0) then continue
            
            cgLoadCT,0,/rev,CLIP=[30,256]
            
            percent=cgPercentiles(subim[where(subim eq subim)], Percentiles=[0.50,ptile[i]])
            cgimage,subim,pos=posp,/noe, stretch=1,$
                minvalue=percent[0],$
                maxvalue=percent[1]
            nxy=size(subim,/d)
    
            ;if  (layout.nxy)[0] eq 1 then subtitle=''
            imcontour,subim,subhd,$
                /Noerase,pos=posp,$
                /nodata,xtitle=xtitle,ytitle=ytitle,title=' ',subtitle=' ',$
                xtickname=xtickname,ytickname=ytickname,$
                /overlay,$
                xcharsize=!p.charsize,ycharsize=!p.charsize,xminor=1,yminor=1,$
                charsize=!p.charsize,type=layout.type
            cgLoadCT,0
        
        endif

        if  mode eq 1 then begin
            
            if  ext[i] eq 0 then $     
                hextractx,(*imfits[tag]).im0,(*imfits[tag]).hdr0,$
                    radec=[mra,mdec],subim,subhd,bxsz[i]*[0.5,-0.5],bxsz[i]*[-0.5,0.5]
            if  ext[i] eq 1 then $
                hextractx,(*imfits[tag]).im1,(*imfits[tag]).hdr1,$
                    radec=[mra,mdec],subim,subhd,bxsz[i]*[0.5,-0.5],bxsz[i]*[-0.5,0.5]

            if  not ( min(subim,/nan) ne max(subim,/nan) and total(subim eq subim) gt 0 ) then continue
            
            plot,[0],[0],xrange=bxsz[i]*[0.5,-0.5],yrange=bxsz[i]*[-0.5,0.5],xstyle=1,ystyle=1,/noe,pos=posp,$
                xtitle=xtitle,ytitle=ytitle,xtickname=xtickname,ytickname=ytickname,$
                xcharsize=!p.charsize,ycharsize=!p.charsize,xminor=1,yminor=1,$
                charsize=!p.charsize

            percent=cgPercentiles(subim[where(subim eq subim)], Percentiles=[0.50,ptile[i]])
            cgLoadCT,0,/rev,CLIP=[30,256]
            map_fits,subim,hd=subhd,radec=[mra,mdec],$
                minvalue=percent[0],maxvalue=percent[1],stretch=1
            cgloadct,0
            
            plot,[0],[0],xrange=bxsz[i]*[0.5,-0.5],yrange=bxsz[i]*[-0.5,0.5],xstyle=1,ystyle=1,/noe,pos=posp,$
                xtitle=xtitle,ytitle=ytitle,xtickname=xtickname,ytickname=ytickname,$
                xcharsize=!p.charsize,ycharsize=!p.charsize,xminor=1,yminor=1,$
                charsize=!p.charsize
        
        endif

        if  keyword_set(cross) then begin
            PLOTS, posp[0]+(posp[2]-posp[0])*[0.0,1.0],(posp[1]+posp[3])/2,/normal,$
                color=cgcolor('red'),thick=2
            PLOTS, (posp[0]+posp[2])/2,posp[1]+(posp[3]-posp[1])*[0.0,1.0],/normal,$
                color=cgcolor('red'),thick=2
        endif else begin
            PLOTS, posp[0]+(posp[2]-posp[0])*[0.2,0.4],(posp[1]+posp[3])/2,/normal,$
                color=cgcolor('red'),thick=8
            PLOTS, (posp[0]+posp[2])/2,posp[1]+(posp[3]-posp[1])*[0.6,0.8],/normal,$
                color=cgcolor('red'),thick=8
        endelse
        if  (layout.nxy)[0] eq 1 then begin
            xyouts,posp[2]+(posp[2]-posp[0])*0.1,(posp[1]+posp[3])*0.5,'!6'+band[i],ori=-90,/norm,ali=0.5
        endif
        tx=posp[0]+(posp[2]-posp[0])*0.05
        ty=posp[1]+(posp[3]-posp[1])*0.95
        al_legend,subtitle+' ',pos=[tx,ty],background_color='white',$
            textc='red',box=0,/norm,charsize=0.6

    endfor
    
    device,/close
    set_plot,'x'
    
endfor

END


PRO TEST_MAKE_CHARTS,project
;+
; NAME:
;   test_make_charts
;
; PURPOSE:
;   make finding charts for different projects:
;
; INPUTS:
;   project:    project name
;
; EXAMPLE:
;   test_make_charts,'specz'
;
; HISTORY:
;   20150812    R.Xue   revised from make_charts_all.pro
;-

;   PROJECT SELECTION

if  project eq 'specz' then begin
    path='/Users/Rui/Workspace/highz/products/mosaic/laecore_vs_lbgcore/lbg_specz.dat'
    readcol,path,ra,dec,objname,specz,mag,format='f,f,a,f,f'
    label=strtrim(indgen(n_elements(ra))+1,2)+' '+strtrim(ra,2)+' '+strtrim(dec,2)+' '+objname+' '+strtrim(specz,2)+' '+strtrim(mag,2)
endif

if  project eq 'lae' then begin
    path=cgsourceDir()+'/metadata/newfirm/'
    readcol,path+'lyaemitter_all_clean.2d',ra,dec,tmp
    label=strtrim(indgen(n_elements(ra))+1,2)+' '+strtrim(ra,2)+' '+strtrim(dec,2)
endif

if  project eq 'lbg' then begin
    path=cgsourceDir()+'/metadata/newfirm/'
    readcol,path+'pcf_lbg_specz.2d',ra,dec
    label=strtrim(indgen(n_elements(ra))+1,2)+' '+strtrim(ra,2)+' '+strtrim(dec,2)
endif

if  project eq 'alma' then begin
    path=cgsourceDir()+'/metadata/newfirm/'
    readcol,path+'alma.2d',ra,dec
    label=strtrim(indgen(n_elements(ra))+1,2)+' '+strtrim(ra,2)+' '+strtrim(dec,2)
endif

if  strmatch(project,'DVPC*',/f) then begin
    path='/Users/Rui/GDrive/Worklib/projects/highz/metadata/deimos/'+project+'.mask.txt'
    readcol,path,objname,ra,dec,epoch,mag,band,tmp1,tmp2,tmp3,format='a,a,a,f,f,a,f,f,f'
    label=strtrim(indgen(n_elements(ra))+1,2)+' '+ra+' '+dec+' '+objname
endif

if  project eq 'oden' then begin
    path='/Users/Rui/Workspace/highz/products/mosaic/laecore_vs_lbgcore/lbg_overdensity.dat'
    readcol,path,ra,dec,tmp1,tmp2,tmp3,format='f,f,a,f,f'
    label=strtrim(indgen(n_elements(ra))+1,2)+' '+strtrim(ra,2)+' '+strtrim(dec,2)+' LBG CORE '
endif

if  project eq 'keck' then begin
  path='pcf_dropouts_Ideep_pcfo_clean.dat'
  restore,'pcf_dropouts_Ideep_pcfo_clean.template'
  ttt=read_ascii(path,tem=template)
  ra=ttt.field02
  dec=ttt.field03
  label=strtrim(ttt.field01,2)+'   '+strtrim(ttt.field06,2)+'   '+strtrim(ttt.field14,2)
  objname=strtrim(ttt.field01,2)
endif

if  project eq 'keck2' then begin
  path='pcf_dropouts_Ideep_pcfo_v2_clean.dat'
  restore,'pcf_dropouts_Ideep_pcfo_clean.template'
  ttt=read_ascii(path,tem=template)
  ra=ttt.field02
  dec=ttt.field03
  label=strtrim(ttt.field01,2)+'   '+strtrim(ttt.field06,2)+'   '+strtrim(ttt.field14,2)
  objname=strtrim(ttt.field01,2)
endif

;   SETUP OBJECTS STRUCTURE

print,'number of objs:',n_elements(ra)
str={source:'',$                        ; source name
    objname:'',$                        ; object name
    label:'',$                          ; label for this object
    ra:!values.f_nan,$                  ; ra (in degree)
    dec:!values.f_nan,$                 ; dec (in degree)
    bxsz:replicate(!values.f_nan,6),$   ; box size (in arcsec)
    cell:replicate(!values.f_nan,6),$   ; cell size (in arcsec)
    band:replicate('',6),$              ; BAND TAG
    imfile:replicate('',6),$            ; fits file full path
    ptile_min:replicate(0.5,6),$        ; percentile color scaling
    ptile_max:replicate(0.95,6),$       ; percentile color scaling
    imext:replicate(0,6)}               ; fits file extension
str=replicate(str,n_elements(ra))

;   LOAD OBJECTS INFO

str.source=strtrim(indgen(n_elements(ra)),2)
str.objname=objname
str.label=label

if  strmatch(project,'DVPC*',/f) then begin
    str.ra=tenv(ra)*15.
    str.dec=tenv(dec)
endif else begin
    str.ra=ra
    str.dec=dec
endelse

str.bxsz=15.0
str.cell=[0.26,0.26,0.3,0.3,0.4,0.4]
str.band=['WRC4','Bw','R','I','H','Ks']
str.imfile[1,*]='stack_Bw_pcfo.fits'
str.imfile[3,*]='stack_I_pcfo.fits'
str.imfile[2,*]='stack_R_pcfo.fits'
str.imfile[0,*]='stack_wrc4_pcfo.fits'

m='stack_H.fits'
hd=headfits(m)
inout=check_point(hd,str.ra,str.dec)
str[where(inout eq 1,/null)].imfile[4,*]=m

m='stack_Ks.fits'
hd=headfits(m)
inout=check_point(hd,str.ra,str.dec)
str[where(inout eq 1,/null)].imfile[5,*]=m

;m='/Users/Rui/Workspace/highz/products/newfirm/imref/irac1.fits'
;hd=headfits(m)
;inout=check_point(hd,str.ra,str.dec)
;str[where(inout eq 1,/null)].imfile[6,*]=m

layout={xsize:8,$
  ysize:1.7,$
  nxy:[6,1],$
  margin:[0.005,0.005],$
  omargin:[0.06,0.15,0.01,0.01],$
  type:0}

;   RUN MAKE_CHARTS / OUPUT EPS FILE LIST
make_charts,str,outname=outname,layout=layout

if  strmatch(project,'DVPC*',/f) then begin
    pineps,/latex,'xhs_fcs_deimos_'+project,outname,/clean
endif else begin
    pineps,/latex,'xhs_fcs_newfirm_'+project,outname,/clean
endelse

END



