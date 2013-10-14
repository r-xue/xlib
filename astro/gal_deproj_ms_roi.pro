PRO GAL_DEPROJ_MS_ROI,ref,roi=roi

;+
; NAME:
;   GAL_DEPROJ_MS_ROI
;
; PURPOSE:
;   make measurement from ROIs
;-


; LOOP THROUGH ALL GALAXIE

ref='MGP'
all_ms=[]


gal_struct_build,ref,s,h,/silent

ind=where(s.(where(h eq 'Galaxy')) eq 'LMC')
dist=s.(where(h eq 'Distance (Mpc)'))[ind]*10.^6
as2pc=dist/206264.806

ms = { $
  galno:"", $
  roi:!values.d_nan,$
  co_magma_sgm:!values.d_nan,$
  coe_magma_sgm:!values.d_nan,$
  mips24_org:!values.f_nan,$
  irac8_org:!values.f_nan,$
  irac8resid_org:!values.f_nan,$
  hi:!values.f_nan,$
  hie:!values.f_nan,$
  area:!values.f_nan}

  types=gal_deproj_fileinfo(ref)

  typetag=[31,32,29,30,33,2,5]

  imroi=readfits(roi,hdroi,/silent)
  gal_ms=replicate(ms,max(imroi,/nan))

  foreach type,types[typetag] do begin
      im='LMC'+type.posfix+'.fits'
      im=readfits(im,hd)
      getrot,hd,angle,cdelt
      psize=abs(cdelt[0])*3600.0
      
      conf=1.0
      
      if STRPOS(strupcase(type.tag), 'MAGMA') ne -1 then begin
          conf=calc_cn(1.0,'co1-0',hd=hd,/MSPPC2,/HELIUM)*(psize*as2pc)^2.0
      endif
      if STRPOS(strupcase(type.tag), 'HI') ne -1 then begin
          conf=calc_cn(1.0,'hi',hd=hd,/MSPPC2,/HELIUM)*(psize*as2pc)^2.0
      endif
      if STRPOS(strupcase(type.tag), 'MIPS24') ne -1 then begin
          conf=3.05d-4*1e6*(psize/3600)^2.0
      endif
      if STRPOS(strupcase(type.tag), 'IRAC8') ne -1 then begin
          conf=3.05d-4*1e6*(psize/3600)^2.0
      endif
      
      for ind=1,max(imroi,/nan) do begin
          roitag=where(imroi eq ind)
          tagindex=where(TAG_NAMES(ms) eq strupcase(type.tag))
          gal_ms[ind-1].(tagindex)=total(im[roitag],/nan)
          
          if strupcase(type.tag) eq 'COE_MAGMA_SGM' then begin
            gal_ms[ind-1].(tagindex)=sqrt(total(im[roitag]^2.0,/nan))
          endif
          if strupcase(type.tag) eq 'HIE' then begin
              gal_ms[ind-1].(tagindex)=sqrt(total(im[roitag]^2.0,/nan))
          endif
          gal_ms[ind-1].roi=ind
          gal_ms[ind-1].area=n_elements(roitag) ; in units of pixel
          gal_ms[ind-1].(tagindex)=gal_ms[ind-1].(tagindex)*conf

      endfor
  endforeach
  
  save,filename='magma_roi_ms.dat',gal_ms
  
END


PRO TEST_SFE_GROUP

restore,'magma_roi_ms.dat'


set_plot, 'ps'
device, filename='SFEgroup.eps', $
    bits_per_pixel=8,/encapsulated,$
    xsize=10,ysize=5,/inches,/col,xoffset=0,yoffset=0,/cmyk
!p.thick=2.0
!x.thick = 2.0
!y.thick = 2.0
!z.thick = 2.0
!p.charsize=1.0
!p.charthick=2.0

pos=pos_mp(0,[2,1],[0.01,0.01],[0.1,0.1])
plot,(gal_ms.co_magma_sgm+gal_ms.hi),gal_ms.mips24_org/(gal_ms.co_magma_sgm+gal_ms.hi),psym=symcat(16),/xlog,/ylog,pos=pos.position,/noe,$
    xtitle='Gas Mass', ytitle='M24/GasMass'
cutoff=10.^(-4.5)
;cutoff=10.^(-5)
tag1=where(gal_ms.mips24_org/(gal_ms.co_magma_sgm+gal_ms.hi) le cutoff and gal_ms.area gt 200)
tag2=where(gal_ms.mips24_org/(gal_ms.co_magma_sgm+gal_ms.hi)  gt cutoff and gal_ms.area gt 200)
oplot,[10.^(-10),10.^10],[cutoff,cutoff]

oplot,(gal_ms[tag1].co_magma_sgm+gal_ms[tag1].hi),gal_ms[tag1].mips24_org/(gal_ms[tag1].co_magma_sgm+gal_ms[tag1].hi),psym=symcat(16),color=cgcolor('blue') 
oplot,(gal_ms[tag2].co_magma_sgm+gal_ms[tag2].hi),gal_ms[tag2].mips24_org/(gal_ms[tag2].co_magma_sgm+gal_ms[tag2].hi),psym=symcat(16),color=cgcolor('red') 

oplot,gal_ms[tag1].co_magma_sgm,gal_ms[tag1].irac8_org,psym=symcat(16),color=cgcolor('blue')
oplot,gal_ms[tag2].co_magma_sgm,gal_ms[tag2].irac8_org,psym=symcat(16),color=cgcolor('red')


pos=pos_mp(1,[2,1],[0.01,0.01],[0.1,0.1])
plot,gal_ms.co_magma_sgm+gal_ms.hi,gal_ms.irac8_org,/xlog,/ylog,psym=symcat(16),pos=pos.position,/noe,$
    xtitle='Gas Mass',ytitle='I8'

oplot,gal_ms[tag1].co_magma_sgm+gal_ms[tag1].hi,gal_ms[tag1].irac8_org,psym=symcat(16),color=cgcolor('blue') 
oplot,gal_ms[tag2].co_magma_sgm+gal_ms[tag2].hi,gal_ms[tag2].irac8_org,psym=symcat(16),color=cgcolor('red')

print,correlate(gal_ms[tag1].co_magma_sgm,gal_ms[tag1].irac8_org)
print,correlate(gal_ms[tag2].co_magma_sgm,gal_ms[tag2].irac8_org)

print,'less SFE'
print,gal_ms[tag1].roi
print,replicate('*',20)
print,'more SFE'
print,gal_ms[tag2].roi

device, /close
set_plot,'X'

test_roi_extract,gal_ms[tag1].roi,'SFEless'
test_roi_extract,gal_ms[tag2].roi,'SFEMore'

test_locate,gal_ms[tag1].roi,'SFEless'
test_locate,gal_ms[tag2].roi,'SFEMore'

END

PRO TEST_GAL_DEPROJ_MS_ROI_PLOT


GAL_DEPROJ_MS_ROI,roi='lmc_v9.co.vbin.sgm.roi.fits'

restore,'magma_roi_ms.dat'

set_plot, 'ps'
device, filename='roi_corr_co_mips24.eps', $
    bits_per_pixel=8,/encapsulated,$
    xsize=10,ysize=10,/inches,/col,xoffset=0,yoffset=0,/cmyk
    !p.thick=2.0
    !x.thick = 2.0
    !y.thick = 2.0
    !z.thick = 2.0
    !p.charsize=1.0
    !p.charthick=2.0
plot,gal_ms.co_magma_sgm,gal_ms.mips24_org,psym=symcat(16),/xlog,/ylog,xrange=[1e1,1e7],yrange=[0.01,1e4],$
    xtitle='Cloud Mass (Msun,xco=2e20,+helium)',ytitle='MIPS24 (Jy)',xstyle=1,ystyle=1,pos=[0.1,0.1,0.9,0.9],/nodata

oploterror,gal_ms.co_magma_sgm,gal_ms.mips24_org,gal_ms.coe_magma_sgm,replicate(0,n_elements(gal_ms)),psym=symcat(9),$
    /nohat,color=cgcolor('red')
x=alog10(gal_ms.co_magma_sgm)
y=alog10(gal_ms.mips24_org)
coe=linfit(x,y)
oplot,10.^(findgen(100)*0.1),10.^(findgen(100)*0.1*coe[1]+coe[0]),color=cgcolor('red')
coe1=coe

oploterror,gal_ms.hi,gal_ms.mips24_org,gal_ms.hie,replicate(0,n_elements(gal_ms)),psym=symcat(6),$
        /nohat,color=cgcolor('blue')
x=alog10(gal_ms.hi)
y=alog10(gal_ms.mips24_org)
coe=linfit(x,y)
oplot,10.^(findgen(100)*0.1),10.^(findgen(100)*0.1*coe[1]+coe[0]),color=cgcolor('blue')
coe2=coe

;xyouts,gal_ms.co_magma_sgm,gal_ms.mips24_org,strtrim(fix(gal_ms.roi),2),/data
al_legend,['MIPS24 vs. MolecularISM Mass','MIPS24 vs. AtomicISM Mass'],psym=[9,6],color=['red','blue']
al_legend,['log(mips24)=a+log(MOL_mass)*b:'+strjoin(string(coe1,format='(f0.3)'),','),$
            'log(mips24)=a+log(ATO_mass)*b:'+strjoin(string(coe2,format='(f0.3)'),',')],/right,/bottom

device, /close
set_plot,'X'

for i=0,n_elements(gal_ms)-1 do begin
    print,  fix(gal_ms[i].roi),$
        gal_ms[i].co_magma_sgm,gal_ms[i].coe_magma_sgm,$
        gal_ms[i].hi,gal_ms[i].hie,$
        gal_ms[i].mips24_org,$
        gal_ms[i].irac8_org,gal_ms[i].irac8resid_org,$
        gal_ms[i].area
endfor

set_plot, 'ps'
device, filename='roi_corr_co_i8.eps', $
    bits_per_pixel=8,/encapsulated,$
    xsize=10,ysize=10,/inches,/col,xoffset=0,yoffset=0,/cmyk
!p.thick=2.0
!x.thick = 2.0
!y.thick = 2.0
!z.thick = 2.0
!p.charsize=1.0
!p.charthick=2.0
plot,gal_ms.co_magma_sgm,gal_ms.irac8_org,psym=symcat(16),/xlog,/ylog,xrange=[1e1,1e7],yrange=[0.01,1e4],$
    xtitle='Cloud Mass (Msun,xco=2e20,+helium)',ytitle='I8 (Jy)',xstyle=1,ystyle=1,pos=[0.1,0.1,0.9,0.9],/nodata
oploterror,gal_ms.co_magma_sgm,gal_ms.irac8_org,gal_ms.coe_magma_sgm,replicate(0,n_elements(gal_ms)),psym=symcat(9),$
    /nohat,color=cgcolor('red')
    x=alog10(gal_ms.co_magma_sgm)
    y=alog10(gal_ms.irac8_org)
    coe=linfit(x,y)
    oplot,10.^(findgen(100)*0.1),10.^(findgen(100)*0.1*coe[1]+coe[0]),color=cgcolor('red')
coe1=coe    
oploterror,gal_ms.hi,gal_ms.irac8_org,gal_ms.hie,replicate(0,n_elements(gal_ms)),psym=symcat(6),$
        /nohat,color=cgcolor('blue')
        
    x=alog10(gal_ms.hi)
    y=alog10(gal_ms.irac8_org)
    coe=linfit(x,y)
    oplot,10.^(findgen(100)*0.1),10.^(findgen(100)*0.1*coe[1]+coe[0]),color=cgcolor('blue')
    coe2=coe
    
;xyouts,gal_ms.co_magma_sgm,gal_ms.irac8_org,strtrim(fix(gal_ms.roi),2),/data
al_legend,['I8 vs. MolecularISM Mass','I8 vs. AtomicISM Mass'],psym=[9,6],color=['red','blue']
al_legend,['log(I8)=a+log(MOL_mass)*b:'+strjoin(string(coe1,format='(f0.3)'),','),$
    'log(I8)=a+log(ATO_mass)*b:'+strjoin(string(coe2,format='(f0.3)'),',')],/right,/bottom
device, /close
set_plot,'X'


END


PRO test_gal_deproj_ms_roi_relabel


im=readfits('lmc_v9.co.vbin.sgm.mask.fits',hd)
;step=2
;
;;newim=padding(float(im),step)
;newim=im
;base=newim*0.0
;print,'padding'
;; z
;for i=1,step-1 do begin
;    base=shift(newim,0,0,i)+base
;    base=shift(newim,0,0,-i)+base
;endfor
;
;; x
;for i=1,step-1 do begin
;    base=shift(newim,i,0,0)+base
;    base=shift(newim,i,0,0)+base
;endfor
;
;; y
;for i=1,step-1 do begin
;    base=shift(newim,0,i,0)+base
;    base=shift(newim,0,-i,0)+base
;endfor

base=total(im,3,/nan)

; for x-y pixel without any channel coverage fov0 eq 0.0
im[where(im eq im)]=1.0
im[where(im ne im)]=0.0
fov0=total(im,3,/nan)
;newim=padding(base,-step)

label=label_region(base gt 0, all_neighbors = all_neighbors, /ulong)
label=float(label)

label[where(fov0 eq 0)]=!values.f_nan
base[where(fov0 eq 0)]=!values.f_nan


; roi code
sxaddpar, hd, 'DATAMAX', max(label,/nan)
sxaddpar, hd, 'DATAMIN', min(label,/nan)
writefits,'lmc_v9.co.vbin.sgm.roi.fits',float(label),hd

sxaddpar, hd, 'DATAMAX', max(base,/nan)
sxaddpar, hd, 'DATAMIN', min(base,/nan)
writefits,'lmc_v9.co.vbin.sgm.mask0.fits',float(base),hd
    
END



PRO TEST_LOCATE,roilist,group

set_plot, 'ps'
device, filename=group+'_roi_locate.eps', $
    bits_per_pixel=8,/encapsulated,$
    xsize=10,ysize=10,/inches,/col,xoffset=0,yoffset=0,/cmyk
!p.thick=2.0
!x.thick = 2.0
!y.thick = 2.0
!z.thick = 2.0
!p.charsize=1.0
!p.charthick=2.0

dust='LMC.HERITAGE.SPIRE500.img.fits'
dust=readfits(dust,dusthd)

cgloadct,3,/rev
pos=[0.2,0.1,0.9,0.9]

maxv=max(dust,/nan)
minv=robust_sigma(dust)
print,minv,maxv
cgimage,dust,pos=pos,stretch=5,/noe,minvalue=-minv,maxvalue=maxv,/KEEP_ASPECT_RATIO
cgloadct,0
imcontour_rdgrid,dust,dusthd,nlevels=4,c_lab=0,$
    /noe,/nodata,pos=pos,/overlay,/type,$
    xtitle='Right Ascension (J2000)',ytitle='Declination (J2000)',subtitle=' '

roi='lmc_v9.co.vbin.sgm.roi.fits'
roi=readfits(roi,roihd)

nxy=size(roi,/d)
make_2d,indgen(nxy[0]),indgen(nxy[1]),xx,yy
for j=0,n_elements(roilist)-1 do begin
test=roi
test[where(test ne roilist[j])]=0.0
x=total(xx*test)/total(test)
y=total(yy*test)/total(test)
xyouts,x-30,y,strtrim(fix(roilist[j]),2),align=0.5
imcontour_rdgrid,test,roihd,levels=[roilist[j]-0.1],$
/noe,pos=pos,/overlay,/type,$
    xtitle='Right Ascension (J2000)',ytitle='Declination (J2000)',subtitle=' ',$
    c_colors=cgcolor('blue')

endfor

device, /close
set_plot,'X'

END


PRO test_roi_extract,roilist,group

    ;+
    ;   extract cutout around each group of clouds
    ;
    ;-
    types=gal_deproj_fileinfo('MGP')
    select=[31,29,30,6,2,10]
    select=[31,29,30,34,2,10]
    types=types[select]
    
    roi='lmc_v9.co.vbin.sgm.roi.fits'
    roi=readfits(roi,roihd)
    gal='lmc'
    epslist=[]

        for i=0,n_elements(roilist)-1 do begin
            
            nxy=size(roi,/d)
            ind3d=array_indices(roi,where(roi eq roilist[i]))
            xmin=min(ind3d[0,*])-20>0
            xmax=max(ind3d[0,*])+20<nxy[0]-1
            ymin=min(ind3d[1,*])-20>0
            ymax=max(ind3d[1,*])+20<nxy[1]-1
            
            set_plot, 'ps'
            
            epslist=[epslist,'roi_locate_'+strtrim(fix(roilist[i]),2)]
            device, filename='roi_locate_'+strtrim(fix(roilist[i]),2)+'.eps', $
                bits_per_pixel=8,/encapsulated,$
                xsize=10,ysize=7,/inches,/col,xoffset=0,yoffset=0,/cmyk
            !p.thick=2.0
            !x.thick = 2.0
            !y.thick = 2.0
            !z.thick = 2.0
            !p.charsize=1.0
            !p.charthick=2.0
            
            kk=0
            
            
            
            pos=[0.2,0.1,0.9,0.9]
            
            ;maxv=max(dust,/nan)
            ;minv=robust_sigma(dust)
            ;print,minv,maxv
            ;cgimage,dust,pos=pos,stretch=5,/noe,minvalue=-minv,maxvalue=maxv,/KEEP_ASPECT_RATIO
            ;cgloadct,0
            
            foreach type,types do begin
                print,'--->',type.tag
                pos=pos_mp(kk,[3,2],[0.01,0.01],[0.1,0.1])
                im=readfits(gal+type.posfix+'.fits',hd)
                hextract,im,hd,subim,subhd,xmin,xmax,ymin,ymax,/silent
                writefits,gal+type.posfix+'_roi'+strtrim(fix(roilist[i]),2)+'.fits',subim,subhd
                hextract,roi,roihd,subroi,subroihd,xmin,xmax,ymin,ymax,/silent
                writefits,gal+'.roi_roi'+strtrim(fix(roilist[i]),2)+'.fits',subroi,subroihd
                
                
                
                cgloadct,3,/rev
                pos=pos.position
                stretch=5
                if type.tag eq 'irac8_org' then stretch=5
                if type.tag eq 'hi' then stretch=1
                if type.tag eq 'hipk' then stretch=1
                min_value=min(subim,/nan)
                max_value=max(subim,/nan)
                if type.tag eq 'irac8_org' and group eq 'SFEless' then begin
                    max_value=3.0 
                endif               
                 cgimage,subim,pos=pos,/keep,/noe,stretch=stretch,minvalue=min_value,maxvalue=max_value

                subroi[where(subroi ne roilist[i])]=0.0

                xtitle=''
                ytitle=''
                subtitle=' '
                xtickname=replicate(' ',60)
                ytickname=replicate(' ',60)
                
                if  kk eq 3 then begin
                    xtitle=''
                    ytitle=''
                    subtitle=''
                    xtickname=!null
                    ytickname=!null
                endif

cgloadct,0

imcontour,subim,subhd,nlevels=4,c_lab=0,$
    /noe,/nodata,pos=pos,/overlay,$
    xtitle=xtitle,ytitle=ytitle,subtitle=subtitle,xtickname=xtickname,ytickname=ytickname
    
    imcontour,subroi,subhd,levels=roilist[i]-0.1,c_lab=0,/noe,pos=pos,/overlay,$
        xtitle=xtitle,ytitle=ytitle,subtitle=subtitle,xtickname=xtickname,ytickname=ytickname,$
        c_colors=cgcolor('blue')
   
   subnxy=size(subroi,/d)
                cgtext,10.,subnxy[1]-10,strupcase(type.tag)
                 
                psize=10
                kk=kk+1
            endforeach
            cgtext,0.75,0.05,'ROI: '+strtrim(fix(roilist[i]),2)
            device, /close
            set_plot,'X'
            

        endfor
    pineps,group,epslist,/clean
    
END



