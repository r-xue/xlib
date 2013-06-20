FUNCTION COMA_FILEINFO
;+
; this structure includes fits file naming/path information
;-
types=replicate({path:'',prefix:'',posfix:'',tag:'',psf:-1.0,mask:''},3)
types.path=['/Users/tonywong/Data/carma/coma/moment/',$
  '/Users/tonywong/Data/carma/coma/moment/',$
  '/Users/tonywong/Data/carma/coma/halpha/']
types.prefix=['',$
  '',$
  '']
types.posfix=[ '.cmmsk.sgm.mom0',$
  '.cmmsk.sgm.emom0',$
  '_netk']
types.tag=[   'co',$
  'coe',$
  'halpha']
types.psf=[   -1,$
   -1,$
   2]
types.mask=['','','']

return,types

END