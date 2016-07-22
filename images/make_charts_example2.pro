PRO PCF_STACK_CHARTS_CUTOUTS

;+++
;   * make small stamps for finding charts
;   * save the stamps to a mef file.
;---

bands_list=['Bw','WRC4','R','I','H','Ks','ch1','ch2','ch3','ch4']
image_list=[    '/Volumes/Neo/mosaic_3year/stack_bw_all.fits',$
                '/Volumes/Neo/mosaic_3year/stack_wrc4_all.fits',$
                '/Volumes/Neo/mosaic_3year/stack_R_all.fits',$
                '/Volumes/Neo/mosaic_3year/stack_I_all.fits',$
                '/Volumes/Neo/newfirm2015/reduced/stacks/stacks_Ke/stack_H.fits',$
                '/Volumes/Neo/newfirm2015/reduced/stacks/stacks_Ke/stack_Ks.fits',$
                '/Volumes/Neo/NDWFS/SDWFS/I1_bootes.v32.fits',$
                '/Volumes/Neo/NDWFS/SDWFS/I2_bootes.v32.fits',$
                '/Volumes/Neo/NDWFS/SDWFS/I3_bootes.v32.fits',$
                '/Volumes/Neo/NDWFS/SDWFS/I4_bootes.v32.fits']


path='/Users/rui/Workspace/temporary/fcs_newfirm/stacklist_all.dat'
readcol,path,ra,dec,objname,format='(f,f,a)'

nstamp=n_elements(bands_list)*n_elements(ra)
objs=make_objects(nstamp)
for i=0,n_elements(ra)-1 do begin
    for j=0,n_elements(bands_list)-1 do begin
        ind=i*n_elements(bands_list)+j
        objs[ind].id=objname[i]
        objs[ind].band=bands_list[j]
        objs[ind].ra=ra[i]                  ;   object ra
        objs[ind].dec=dec[i]                ;   object dec
        objs[ind].bxsz=12.0                 ;   the box size in arcsec for each stamp
        objs[ind].image=image_list[j]       ;   input image for extacting stamps
        objs[ind].imout=objname[i]+'/'+objname[i]+'_'+bands_list[j] ; stamp name
    endfor
endfor


;   RUN MAKE_CUTOUTS for finding charts

tic
make_cutouts,objs,export_method='mef',output='pcf_cutout4charts.fits',extract_method='hextractx-fast'
toc

;   RUN MAKE_CUTOUTS for examinations (export to individial fits files) 

;tic
;make_cutouts,objs,export_method='stamps',output='pcf_cutout4charts.fits',extract_method='hextractx-fast'
;toc

END

PRO PCF_STACK_CHARTS_PLOTS

if  n_elements(outname) eq 0 then outname='pcf_newfirm_cat'

layout={xsize:8.,$                      ;   eps size in inch
    ysize:2.5,$                         ;   eps size in inch
    nxy:[5,2],$                         ;   5 x 2 layout
    margin:[0.005,0.005],$              ;   margin for each panel
    omargin:[0.04,0.01,0.01,0.01],$     ;   margin for the page
    type:0}                             ;   offset coord system

;   this should match what you have in the object metadata

band_select=['Bw','WRC4','R','I','H','Ks','ch1','ch2','ch3','ch4']
type_select=replicate('',n_elements(band_select))
tic
make_charts,'pcf_cutout4charts.fits',$
    band_select=band_select,type_select=type_select,$
    ;id_select='dvpc07_009_LAE34611',$
    bxsz=10.0,$
    layout=layout,$
    epslist=epslist
pineps,/latex,outname+'_charts',epslist
toc

END




