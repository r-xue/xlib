!PATH=  !PATH +':'+$
        Expand_Path('+~/GDrive/Worklib/idl/resource/misc')+':'+$        ; core libs
        Expand_Path('+~/GDrive/Worklib/idl/resource')+':'+$        ; core libs
        Expand_Path('+~/GDrive/Worklib/projects')+':'+$            ; projects
        Expand_Path('+~/GDrive/Worklib/idl/packages')              ; packages
!PATH=  Expand_Path('+~/GDrive/Worklib/projects/xlib')+':'+!PATH
!PATH=  Expand_Path('+~/GDrive/Worklib/idl/resource/astron/pro/')+':'+!PATH

;xyouts,'!6'
;Device, RETAIN=2
!p.thick=1.0
!x.thick = 1.0
!y.thick = 1.0
!z.thick = 1.0
!p.charthick=1.0
