FUNCTION MAKE_OBJECTS,nobj

;+
; NAME:
;   make_objects
;
; PURPOSE:
;   setup objects/cutouts info structures for MAKE_CHARTS/MAKE_CUTOUTS 
;-

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;INPUT STRUCTURE for MAKE_CHARTS.PRO/MAKE_CUTOUTS.PRO
;   (default values are in the code)
;
;   not every tag is essential for a specfic procedure in xlib; but this is a complete tag defination list 
;
;-
;   obj:    object structure vector
;           
;           objects related:
;   
;               .id             object name
;               .id_alter       alternative object name
;               .label          idl-friendly object label
;   
;               .ra             RA
;               .dec            DEC
;           
;           charts/cutout related:
;
;               .bxsz       box size (in arcsec)
;               .cell       cell size (in arcsec)
;                           actually the cell size was determined by device dpi
;               .mode:      =0  images has been reprocessed to the desired size
;                           =1  images will be plotted as polygon
;                           =2  images will be plotted after resampling

;           data related:
;
;               .image      image file full/relative path (in fits)
;               .imext      image fits extension
;               .band       band name
;               .tile       tile tag
;           
;           charts related:
;           
;               .ptile_min  min percentile for color scaling
;               .ptile_max  max percentile for color scaling
;------------------------------------------------------------------------------------------


obj=    { $
        id:'',$
        id_alter:'',$
        id_label:'',$
        ra:!values.f_nan,$
        dec:!values.f_nan,$
        ;
        bxsz:30.0,$
        cell:1.0,$
        mode:1,$
        ;
        image:'',$              ;   original image file name
        imext:0,$
        bunit:'',$
        type:'',$               ;   rms / wht / int / sci / msk
        ;
        band:'',$
        tile:'',$
        proc:1,$
        ;
        imout:'',$
        ;
        ptile_min:0.01,$
        ptile_max:0.99 $
        }

objs=replicate(obj,nobj)
return,objs

END


PRO TEST_MAKE_OBJECTS

objs=make_objects(10000)

END
       