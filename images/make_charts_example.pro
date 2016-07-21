;cosmos_stack_charts.pro
;
;<COSMOS_STACK_CHARTS_RUN> is the master pro, which
;* will run <COSMOS_STACK_CHARTS_CUTOUTS> to generate a single fits file containing all stamps (from various tile/bands/objects) (essentially it uses xlib/<make_cutouts.pro>)
;* will run <COSMOS_STACK_CHARTS_ALL> to generate eps/pdf: one eps for each object with the page layout specified in the keyword <layouts> (essentially it uses xlib/<make_charts.pro>)
;* <COSMOS_STACK_CHARTS> is not used in this example
;
;The up-to-date library codes are in ~rui/Applications/xlib, so you may need to load the path before anything else.
;
;What you may need to do are:
;
;* filling cutout metadata possibly just by doing some loops in <COSMOS_STACK_CHARTS_CUTOUTS>
;each element of the input structure vector for make_cutouts.pro is just one stamp
;* change the panel layout and band_select in <COSMOS_STACK_CHARTS_ALL>
;one eps for one object, with the band sequence defined in <band_select>.


PRO COSMOS_STACK_CHARTS_CUTOUTS,output
;+++
;   * make small stamps for finding charts
;   * save the stamps to a mef file.
;---

;   this csv file contains object-tilelocation information
;   you may build your own or just hardcode it here from your object list.
;   full path: /Volumes/Leo/rx_workspace/cosmos/cats
st=read_table('../cats/ibg_tileloc.csv',head=hd,/silent,/scalar)


;   BUILD INPUT-STR FOR MAKE_CUTOUTS.PRO
;   each element in the structure vector present the cutout setup for one stamp (with nesscary metadata)

;   MAKE TEMPLATES
objs=make_objects(n_elements(st.id))
;   FILL METADATA
objs.id=st.id                   ;   object name
objs.band=st.band               ;   band name
objs.type=st.type               ;   image type (probally not important in making finding chart) 
objs.ra=st.ra                   ;   object ra
objs.dec=st.dec                 ;   object dec
objs.bxsz=12.0                  ;   the box size in arcsec for each stamp
objs.image=st.image             ;   input image for extacting stamps
                                ;   need images in the primary extension currently 
tag=where(st.type eq 'sci')     ;   we only use st.type='sci' for finding charts
objs=objs[tag]                  ;

print,'---------'
print,n_elements(st)
print,'---------''

;   RUN MAKE_CUTSOUTS

tic
make_cutouts,objs,export_method='mef',output=output,extract_method='hextractx-fast'
toc

END


PRO COSMOS_STACK_CHARTS,cutouts,zcat=zcat,outname=outname
;+
;   *   generate finding charts
;-

if  n_elements(zcat) eq 0 then zcat='*'
if  n_elements(outname) eq 0 then outname='test'

layout={xsize:8.,$
    ysize:1.70,$
    nxy:[9,2],$
    margin:[0.005,0.005],$
    omargin:[0.04,0.01,0.01,0.01],$
    type:0}
band_select=[   $
    'Subaru-IB427',$
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
band_label=[    $
    '!8IB427!6',$
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
restore,'../cats/ibg_all.xdr'

;+++
;choice 1
tag=where(strmatch(zc.group,'*'+zcat+'*',/f))
id_select=zc.id
id_select=id_select[tag]
;---

;+++
;choice 2
;fits_open,cutouts,fcb
;next=fcb.nextend
;cutouts_hd=mrdfits(cutouts,next)
;id_select=cutouts_hd.id
;---

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

print,'--->',size(extra_label)

make_charts,cutouts,$
    id_select=id_select,$
    band_select=band_select,band_label=band_label,$
    extra_label=extra_label,$
    bxsz=8.0,$
    layout=layout,$
    epslist=epslist
pineps,/latex,outname+'_charts',epslist


END

PRO COSMOS_STACK_CHARTS_ALL,cutouts,outname=outname
;+
;   *   generate finding charts
;-

if  n_elements(outname) eq 0 then outname='test'

layout={xsize:8.,$                          ;   eps size in inch
        ysize:1.70,$                        ;   eps size in inch
        nxy:[9,2],$                         ;   9 x 2 layout
        margin:[0.005,0.005],$              ;   margin for each panel
        omargin:[0.04,0.01,0.01,0.01],$     ;   margin for the page
        type:0}                             ;   offset coord system
    
;   this should match what you have in the object metadata

band_select=[   $
    'Subaru-IB427',$
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
band_label=[    $
    '!8IB427!6',$
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


make_charts,cutouts,$
    band_select=band_select,band_label=band_label,$
    bxsz=8.0,$
    layout=layout,$
    epslist=epslist
pineps,/latex,outname+'_charts',epslist

END


PRO COSMOS_STACK_CHARTS_RUN

COSMOS_STACK_CHARTS_CUTOUTS,'ibg_cutouts4charts.fits'
COSMOS_STACK_CHARTS_ALL,'ibg_cutouts4charts.fits',outname='all'

END





