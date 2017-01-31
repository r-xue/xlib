FUNCTION MAKE_OBJECTS,nobj

;+
; NAME:
;   make_objects
;
; PURPOSE:
;   setup an object/cutout metadata template for MAKE_CHARTS/MAKE_CUTOUTS.PRO
;   
;   note:   see the predefined tags below
;           some tags are not essential for xlib codes
;   
;-


obj=    { $
        id:'',$                     ;   object name
        id_alter:'',$               ;   alternative object name
        id_label:'',$               ;   textoidl-friendly label
        ra:!values.d_nan,$          ;   ra  [degree]
        dec:!values.d_nan,$         ;   dec [degree]
                                    ;
        bxsz:30.0,$                 ;   cutout box size [arcsec]
        cell:0.2,$                  ;   cutout cell size [arcsec]
                                    ;   the cellsize may be determined by device dpi in some configs
                                    ;   
        mode:1,$                    ;    =0  images has been reprocessed to the desired size
                                    ;    =1  images will be plotted as polygon
                                    ;    =2  images will be plotted after resampling
                                    ;
        image:'',$                  ;   image file name (full/relative path)
        imext:0,$                   ;   image fits extension
        bunit:'',$                  ;   image bunit
        type:'',$                   ;   image type ( rms / wht / int / sci / msk )
                                    ;
        band:'',$                   ;   band name
        tile:'',$                   ;   tile name
        proc:1, $                   ;   processing tag
                                    ;
        imout:'',$                  ;   cutout image name
                                    ;
        ptile_min:0.01,$            ;   min percentile for color scaling
        ptile_max:0.99 $            ;   max percentile for color scaling
        }

objs=replicate(obj,nobj)
return,objs

END


PRO TEST_MAKE_OBJECTS

objs=make_objects(10000)

END
       