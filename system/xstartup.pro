!PATH=  !PATH+':'+$
        Expand_Path('+~/Dropbox/Worklib/idl/resource/misc')+':'+$   ; core libs
        Expand_Path('+~/Dropbox/Worklib/idl/resource/cmtotal')+':'+$   ; core libs
        Expand_Path('+~/Dropbox/Worklib/idl/resource')+':'+$        ; core libs
        Expand_Path('+~/Dropbox/Worklib/projects')+':'+$            ; projects
        Expand_Path('+~/Dropbox/Worklib/idl/packages')              ; packages

!PATH=  !PATH+':'+$
        Expand_Path('+~/GDrive/Worklib/idl/resource/misc')+':'+$        ; core libs
        Expand_Path('+~/GDrive/Worklib/idl/resource')+':'+$        ; core libs
        Expand_Path('+~/GDrive/Worklib/projects')+':'+$            ; projects
        Expand_Path('+~/GDrive/Worklib/idl/packages')              ; packages

!PATH=  Expand_Path('+~/Dropbox/Worklib/idl/resource/impro')+':'+!PATH
!PATH=  Expand_Path('+~/Dropbox/Worklib/projects/xlib')+':'+!PATH
!PATH=  Expand_Path('+~/Dropbox/Worklib/idl/resource/IDLAstro/pro/')+':'+!PATH
!PATH=  Expand_Path('+~/Dropbox/Worklib/idl/resource/idl-coyote')+':'+!PATH

;!PATH=  Expand_Path('+~/GDrive/Worklib/idl/packages/astron-contrib/varosi/')+':'+!PATH
;@~/GDrive/Worklib/idl/packages/astron-contrib/varosi/vlib/idl_startup.pro
;xyouts,'!6'
;Device, RETAIN=2

!p.thick=1.0
!x.thick = 1.0
!y.thick = 1.0
!z.thick = 1.0
!p.charthick=1.0
