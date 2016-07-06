PRO GAL_DEPROJ_DET,$
    cat=cat,$
    gselect=gselect,bselect=bselect,$           ; select galaxies and bands based on index in tables
    gkey=gkey,gval=gval,$                       ; select galaxies based on label
    bkey=bkey,bval=bval,$                       ; select bands based on label
    box=box,$
    ores=ores,out=out,$
    nodp=nodp

;+
; NAME:
;   GAL_DPROJ_MS
;
; PURPOSE:
;   mark detection regions
;  (will fetch a set of fits data from the current working directory)
;  box in arcsec
;  
; Examples:
;   gal_deproj_det,gkey='Galaxy',gval='ngc4254',bkey='tag',bkey=['co','coe']
;  
;-
resolve_routine,'gal_deproj_meta'
dp='_dp'
if keyword_set(nodp) then dp=''
if n_elements(ores) eq 0 then ores='_smo*'
if n_elements(out) eq 0 then out='all_ms'
if n_elements(select_ref) eq 0 then select_ref=0



if  not keyword_set(cat) then cat='nearby'
GAL_DEPROJ_META, cat, s, h, types, typesh,$
    gselect=gselect,bselect=bselect,$
    gkey=gkey,gval=gval,$
    bkey=bkey,bval=bval

restore,'sting.dat',/v

tag=where(all_ms.galno eq 'ngc4254' and all_ms.co gt 3.0*all_ms.coe)
write_ds9_regionfile,all_ms[tag].ra,all_ms[tag].dec,color='cyan',symbol='x',filename='codet.reg'

tag=where(all_ms.galno eq 'ngc4254' and all_ms.hi gt 3.0*all_ms.hie)
write_ds9_regionfile,all_ms[tag].ra,all_ms[tag].dec,color='cyan',symbol='x',filename='hidet.reg'

END


