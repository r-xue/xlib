PRO MAKE_CHARTS,CUTOUTS,$
    PLOT_METHOD=PLOT_METHOD,cross=cross,layout=layout,$
    band_select=band_select,type_select=type_select,band_label=band_label,$
    id_select=id_select,$
    extra_label=extra_label,box_label=box_label,$
    bxsz=bxsz,$
    epslist=epslist
    
    
    

;+
; NAME:
;   make_charts
;
; PURPOSE:
;   make finding charts
;
; INPUTS:
;   objs:       check make_objects.pro for the detailed defination of this structure 
;               it could a scale or vector of the predefined structure.
;
; OUTOUTS:
;   epslist     outout eps file name list
;
; KEYWORDS:
;   cross:      plot cross at center rather than bars to the left and top
;   layout:     see below (hold the input for pos_mp.pro)
;   plot_method:    'orginal':      beaware that the xy may not be RA-DEC if pixel is rotated in
;                   'polygon':      plot each pixel as a polygon, the file size could be too large.
;                   'resample':     automatically resample based on the plot dpi request;
;                                   so a pixel in the image will still appear as a pixel when printed out,
;                                       * the pixel rotation will still show up.
;                                       * no blurr when print the ps file on paper.
; EXAMPLE:
;   see TEST_MAKE_CHARTS
; 
; NOTE:
;   The older version of make_charts.pro will load all input images at once for saving the time wasted on
;   repeating load same images for individual objects, but this doesn't scale up well if the image dataset
;   is too large for memory (like the COSMOS data in mutiple tiles/bands) 
;   
;   This new version will do the job in two steps:
;       1. load input image one by one; for each images, generate requried stamps and save them to memory;
;          release memory 
;       2. plot stamps
;   The 1st step is actually shared with the new version of make_cutouts.pro. 
;   The input structures of make_charts.pro and make_cutouts.pro can share same structure tags now.
;   
; EXAMPLES:
;   make_charts,cutouts,id_select='zc400275'
;
; HISTORY:
;   20160629    R.Xue   completely rewritten from the older version
;-


if  n_elements(plot_method) eq 0 then plot_method='resample'

;   PLOT INDIVIDUAL OBJECTS (SORT BY IDS)

id=cutouts.nestedmap(Lambda(x:x.id))
id=id.toarray(/tran)

band=cutouts.nestedmap(Lambda(x:x.band))
band=band.toarray(/tran)

type=cutouts.nestedmap(Lambda(x:x.type))
type=type.toarray(/tran)

if  n_elements(id_select) eq 0 then id_select=id[uniq(id, sort(id))]
if  n_elements(band_select) eq 0 then band_select=band[uniq(band, sort(band))]
if  n_elements(type_seletc) eq 0 then type_select=replicate('sci',n_elements(band_select))


if  ~keyword_set(layout) then begin
    layout={xsize:8,$
        ysize:1.5,$
        nxy:[n_elements(band_select),1],$
        margin:[0.01,0.01],$
        omargin:[0.06,0.02,0.01,0.02],$
        type:0}
endif

print,''
print,'Working on these bands:'
print,''
print,band_select+'-'+type_select
print,''

epslist=[]

for i=0,n_elements(id_select)-1 do begin
    
    print,replicate('>',20)
    print,strtrim(i+1,2)+'/'+strtrim(n_elements(id_select),2)
    print,replicate('<',20)

    
    psfile=strtrim(id_select[i],2)
    epslist=[epslist,psfile]
    
    set_plot,'ps'
    device, file=psfile+'.eps', /color, bits=8, /encapsulated,$
        xsize=layout.xsize,ysize=layout.ysize,/inches
    !p.thick=1.5
    !x.thick = 1.5
    !y.thick = 1.5
    !z.thick = 1.5
    !p.charsize=0.85
    !p.charthick=1.5
    !x.gridstyle = 0
    !y.gridstyle = 0
    xyouts,'!6'
    
    for j=0,n_elements(band_select)-1 do begin
        
        
        tag=where(id eq id_select[i] and band eq band_select[j] and type eq type_select[j])

        if  tag[0] eq -1 then continue
        tag=tag[0]
        
        ;   Overwrite the default setting
        if  n_elements(bxsz) ne 0 then bxsz1=bxsz else bxsz1=cutouts[tag].bxsz
        
        print,id_select[i],'-',band_select[j],'-',type_select[j]
        pos=pos_mp(j,layout.nxy,layout.margin,layout.omargin)
        posp=pos.position
        xtickname=replicate(' ',60)
        ytickname=replicate(' ',60)
        xtitle=' '
        ytitle=' '
        if  pos.px eq 0 and pos.py eq (layout.nxy)[1]-1 and keyword_set(box_label) then begin
            xtickname=!null
            ytickname=!null
            xtitle=textoidl("!6\delta(R.A.) ['']")
            ytitle=textoidl("!6\delta(Dec.) ['']")
        endif
        cgloadct,0
        subim=fltarr(10,10)+255
        cgimage,subim,pos=posp,/keep,/noe
        subtitle='!6'+band_select[j]
        if  n_elements(band_label) eq n_elements(band_select) then subtitle=band_label[j]
        
        if  plot_method eq 'resample' or plot_method eq 'orginal' then begin

            psize=dpxy(20.,ibox=[2.0,2.0],dpi=150,/silent)
            psize=min(1.0/psize)

            if  plot_method eq 'resample' then begin
                temphd=mk_hd([cutouts[tag].ra,cutouts[tag].dec],fix((bxsz1/psize)/2.0)*2+1,psize)
                ;sxaddpar,hdr0,'EQUINOX',2000.0
                hastrom_nan,cutouts[tag].im0,cutouts[tag].hd0,subim,subhd,temphd,missing=!VALUES.F_NAN,/silent,interp=0
            endif
            if  plot_method eq 'original' then begin
                subhd=cutouts[tag].hd0
                subim=cutouts[tag].im0
            endif

            if  not (min(subim,/nan) ne max(subim,/nan) and total(subim eq subim) gt 0) then continue

            cgLoadCT,0,/rev,CLIP=[30,256]

            percent=cgPercentiles(subim[where(subim eq subim)], Percentiles=[cutouts[tag].ptile_min,cutouts[tag].ptile_max])
            cgimage,subim,pos=posp,/noe, stretch=1,$
                minvalue=percent[0],$
                maxvalue=percent[1]
            nxy=size(subim,/d)

            imcontour,subim,subhd,$
                /Noerase,pos=posp,$
                /nodata,xtitle=xtitle,ytitle=ytitle,title=' ',subtitle=' ',$
                xtickname=xtickname,ytickname=ytickname,$
                /overlay,$
                xcharsize=!p.charsize,ycharsize=!p.charsize,xminor=1,yminor=1,$
                charsize=!p.charsize,type=layout.type
            cgLoadCT,0

        endif

        if  plot_method eq 'polygon' then begin

            cgLoadCT,0
            hextractx,cutouts[tag].im0,cutouts[tag].hd0,$
                radec=[cutouts[tag].ra,cutouts[tag].dec],subim,subhd,bxsz1*[0.5,-0.5],bxsz1*[-0.5,0.5]

            if  not ( min(subim,/nan) ne max(subim,/nan) and total(subim eq subim) gt 0 ) then continue

            plot,[0],[0],xrange=bxsz1*[0.5,-0.5],yrange=bxsz1*[-0.5,0.5],xstyle=1,ystyle=1,/noe,pos=posp,$
                xtitle=xtitle,ytitle=ytitle,xtickname=xtickname,ytickname=ytickname,$
                xcharsize=!p.charsize,ycharsize=!p.charsize,xminor=1,yminor=1,$
                charsize=!p.charsize

            percent=cgPercentiles(subim[where(subim eq subim)], Percentiles=[cutouts[tag].ptile_min,cutouts[tag].ptile_max])
            cgLoadCT,0,/rev,CLIP=[30,256]
            map_fits,subim,hd=subhd,radec=[cutouts[tag].ra,cutouts[tag].dec],$
                minvalue=percent[0],maxvalue=percent[1],stretch=1
            cgloadct,0

            plot,[0],[0],xrange=bxsz1*[0.5,-0.5],yrange=bxsz1*[-0.5,0.5],xstyle=1,ystyle=1,/noe,pos=posp,$
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
            if  ~keyword_set(band_label) then begin
                xyouts,posp[2]+(posp[2]-posp[0])*0.1,(posp[1]+posp[3])*0.5,'!6'+band[i],ori=-90,/norm,ali=0.5
            endif else begin
                xyouts,posp[2]+(posp[2]-posp[0])*0.1,(posp[1]+posp[3])*0.5,'!6'+band_label[j],ori=-90,/norm,ali=0.5 
            endelse
        endif
        tx=posp[0]+(posp[2]-posp[0])*0.05
        ty=posp[1]+(posp[3]-posp[1])*0.95
        al_legend,subtitle+' ',pos=[tx,ty],background_color='white',$
            textc='red',box=0,/norm,charsize=0.4
        
        tx=posp[0]+(posp[2]-posp[0])*0.85
        ty=posp[1]+(posp[3]-posp[1])*0.05
        xyouts,tx,ty,extra_label[j,i],color=cgcolor('blue'),/norm,charsize=0.4,ali=0.5        
            
    endfor
    
    if  ~keyword_set(box_label) then begin
        xyouts,0.03,0.5,id_select[i],/normal,orien=90,ali=0.5
    endif
    
    device,/close
    set_plot,'x'
    
endfor


END


PRO TEST_MAKE_CHARTS,cutouts,zcat

    layout={xsize:8.,$
        ysize:1.70,$
        nxy:[9,2],$
        margin:[0.005,0.005],$
        omargin:[0.04,0.01,0.01,0.01],$
        type:0}
band_select=[   'Subaru-IB427',$
                'Subaru-IB464',$
                'Subaru-IA484',$
                'Subaru-IB505',$
                'Subaru-IA527',$
                'Subaru-IA624',$
                'Subaru-IA679',$
                'Subaru-IA738',$
                'Subaru-IA767',$
                'Subaru-B',$
                'Subaru-gp',$
                'acs-g',$
                'Subaru-V',$
                'Subaru-rp',$
                'Subaru-ip',$
                'cfht-i',$
                'acs-I']
band_label=[    '!8IB427!6',$
                '!8IB464!6',$
                '!8IA484!6',$
                '!8IB505!6',$
                '!8IA527!6',$
                '!8IA624!6',$
                '!8IA679!6',$
                '!8IA738!6',$
                '!8IA767!6',$
                '!8B!6',$
                '!8g+!6',$
                'acs-!8g!6',$
                '!8V!6',$
                '!8r+!6',$
                '!8i+!6',$
                'CFHT-!8i!6',$
                'acs-!8I!6']                
                
extra_label=[]

id=cutouts.nestedmap(Lambda(x:x.id))
id=id.toarray(/tran)


restore,'../cats/ibg_all.xdr'
tag=strmatch(zc.group,'*'+zcat+'*',/f)
id_select=zc[tag]
id_select=id_select[uniq(id_select, sort(id_select))]

for i=0,n_elements(id_select)-1 do begin
    id1=id_select[i]
    tag=where(id1 eq zc.id)
    one_label=[ string(pc[tag].IB427_MAG_AUTO,format='(f5.2)'),$
        string(pc[tag].IB464_MAG_AUTO,format='(f5.2)'),$
        string(pc[tag].IA484_MAG_AUTO,format='(f5.2)'),$
        string(pc[tag].IB505_MAG_AUTO,format='(f5.2)'),$
        string(pc[tag].IA527_MAG_AUTO,format='(f5.2)'),$
        string(pc[tag].IA624_MAG_AUTO,format='(f5.2)'),$
        string(pc[tag].IA679_MAG_AUTO,format='(f5.2)'),$
        string(pc[tag].IA738_MAG_AUTO,format='(f5.2)'),$
        string(pc[tag].IA767_MAG_AUTO,format='(f5.2)'),$
        string(pc[tag].B_MAG_AUTO,format='(f5.2)'),$
        '',$
        '',$
        string(pc[tag].V_MAG_AUTO,format='(f5.2)'),$
        string(pc[tag].r_MAG_AUTO,format='(f5.2)'),$
        string(pc[tag].ip_MAG_AUTO,format='(f5.2)'),$
        '',$
        '']
    extra_label=[[extra_label],[one_label]]
endfor

print,size(extra_label)

make_charts,cutouts,$
    id_select=id_select,$
    band_select=band_select,band_label=band_label,$
    extra_label=extra_label,$
    bxsz=12,$
    layout=layout,$
    epslist=epslist
pineps,/latex,zcat+'_charts',epslist

END
