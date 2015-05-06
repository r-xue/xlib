PRO MAKE_CHARTS,OBJ,outname=outname,cross=cross,layout=layout,$
    mode=mode

; MODE 0:    images has been reprocessed to the desired size
; MODE 1:    images will be plotted as polygon
; MODE 2:    images will be plotted after OTF resampling 

nobj=n_elements(obj.source)

imlist=[]
for i=0,nobj-1 do begin
    imlist=[imlist,obj[i].imfile]
endfor
imlist=imlist[rem_dup(imlist)]
imlist=imlist[where(imlist ne '',/null)]
print,imlist

imfits=[]
for i=0,n_elements(imlist)-1 do begin
    rdfits_struct,imlist[i],tmp
    tmp=ptr_new(tmp,/no_copy)
    imfits=[imfits,tmp]
endfor

if  not keyword_set(layout) then begin    
layout={xsize:8,$
        ysize:1.5,$
        nxy:[7,1],$
        margin:[0.01,0.01],$
        omargin:[0.06,0.02,0.01,0.02],$
        type:0}
endif

outname=[]

for nc=0,nobj-1 do begin
    
    print,replicate('>',20) 
    print,strtrim(nc,2)+'/'+strtrim(nobj,2)
    print,replicate('<',20)
    
    mra=obj[nc].ra
    mdec=obj[nc].dec
    bxsz=obj[nc].bxsz
    cell=obj[nc].cell
    imfile=obj[nc].imfile
    band=obj[nc].band
    oname=obj[nc].objname
    ptile=obj[nc].ptile
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
        
        print,band[i],imfile[i]
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
        if  i eq fix((layout.nxy)[0]/2.0) and (layout.nxy)[0] ne 1 then xtitle=oname
        ;if i eq 0 then subtitle='!8Bw!6='+string(str[nc].bmag,format='(f5.2)')
        ;if i eq 1 then subtitle='!8R!6='+string(str[nc].rmag,format='(f5.2)')
        ;if i eq 2 then subtitle='!8I!6='+string(str[nc].kmag,format='(f5.2)')
        ;if i eq 3 then subtitle='!6IRAC1'
        ;if i eq 4 then subtitle='!6IRAC2'
        ;if i eq 5 then subtitle='!6IRAC4'
        subim=fltarr(10,10)
        cgimage,subim,pos=posp,/keep,/noe
        subtitle='!6'+band[i]

        if  mode eq 2 or mode eq 0 then begin
            
            
            psize=dpxy(20.,ibox=[2.0,2.0],dpi=150)
            psize=min(1.0/psize)

            if  mode eq 2 then begin
                hdr0=(*imfits[tag]).hdr0
                temphd=mk_hd([mra,mdec],fix((bxsz[i]/psize)/2.0)*2+1,psize)
                sxaddpar,hdr0,'EQUINOX',2000.0
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
            percent=cgPercentiles(subim[where(subim eq subim)], Percentiles=[0.50,0.98])
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
            
            plot,[0],[0],xrange=bxsz[i]*[0.5,-0.5],yrange=bxsz[i]*[-0.5,0.5],xstyle=1,ystyle=1,/noe,pos=posp,$
                xtitle=xtitle,ytitle=ytitle,xtickname=xtickname,ytickname=ytickname,$
                xcharsize=!p.charsize,ycharsize=!p.charsize,xminor=1,yminor=1,$
                charsize=!p.charsize
            
            if  ext[i] eq 0 then $     
                hextractx,(*imfits[tag]).im0,(*imfits[tag]).hdr0,$
                    radec=[mra,mdec],subim,subhd,bxsz[i]*[0.5,-0.5],bxsz[i]*[-0.5,0.5]
            if  ext[i] eq 1 then $
                hextractx,(*imfits[tag]).im1,(*imfits[tag]).hdr1,$
                    radec=[mra,mdec],subim,subhd,bxsz[i]*[0.5,-0.5],bxsz[i]*[-0.5,0.5]
            percent=cgPercentiles(subim[where(subim eq subim)], Percentiles=[0.50,0.98])
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
        tx=posp[0]+(posp[2]-posp[0])*0.07
        ty=posp[1]+(posp[3]-posp[1])*0.93
        al_legend,subtitle+' ',pos=[tx,ty],background_color='white',$
            textc='red',box=0,/norm,charsize=0.7

        
        ;oplot,[-10,10],[0,0]
        
        ;xyouts,nxy[0]/2.,nxy[1],band[i],/data,ali=0.5
;        resolve_routine,'xhs_select_cosmos'
;        er=EXECUTE('xhs_select_cosmos,hd=temphd')
        ;XHS_SELECT_COSMOS,hd=temphd
;        endif else begin
;            print,str[nc].source,allimages[j,0]
;        endelse
        ;xyouts,0.5,0.1,str[nc].source+'/'+str[nc].field+'/'+strtrim(str[nc].index,2),/normal,ali=0.5
    endfor
    
    device,/close
    set_plot,'x'
    
endfor

END
