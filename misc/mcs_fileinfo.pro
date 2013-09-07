FUNCTION MCS_FILEINFO
;+
; this structure includes fits file naming/path information
;-
types=replicate({path:'',prefix:'',posfix:'',tag:'',psf:-1.0,mask:''},16)
types.path=[$
  '/Users/Rui/Workspace/magclouds/gasmap/',$
  '/Users/Rui/Workspace/magclouds/gasmap/',$
  '/Users/Rui/Workspace/magclouds/gasmap/',$
  '/Users/Rui/Workspace/magclouds/gasmap/',$
  '/Users/Rui/Workspace/magclouds/gasmap/',$
  '/Users/Rui/Workspace/magclouds/gasmap/',$
  '/Volumes/Scratch/data_repo/herschel/HERITAGE/Data/',$
  '/Volumes/Scratch/data_repo/herschel/HERITAGE/Data/',$
  '/Volumes/Scratch/data_repo/herschel/HERITAGE/Data/',$
  '/Volumes/Scratch/data_repo/herschel/HERITAGE/Data/',$
  '/Volumes/Scratch/data_repo/herschel/HERITAGE/Data/',$
  '/Volumes/Scratch/data_repo/herschel/HERITAGE/Data/',$
  '/Volumes/Scratch/data_repo/herschel/HERITAGE/Data/',$
  '/Volumes/Scratch/data_repo/herschel/HERITAGE/Data/',$
  '/Volumes/Scratch/data_repo/herschel/HERITAGE/Data/',$
  '/Volumes/Scratch/data_repo/herschel/HERITAGE/Data/']
types.prefix=replicate('',16)
types.posfix=[$
  '.co_nanten.cm.sm.mom0',$
  '.co_magma.cm.sm.mom0',$
  '.hi.cm.sm.mom0',$
  '.co_nanten.cm.sm.emom0',$
  '.co_magma.cm.sm.emom0',$
  '.hi.cm.sm.emom0',$
  '.HERITAGE.PACS100.img',$
  '.HERITAGE.PACS160.img',$
  '.HERITAGE.SPIRE250.img',$
  '.HERITAGE.SPIRE350.img',$
  '.HERITAGE.SPIRE500.img',$
  '.HERITAGE.PACS100.unc',$
  '.HERITAGE.PACS160.unc',$
  '.HERITAGE.SPIRE250.unc',$
  '.HERITAGE.SPIRE350.unc',$
  '.HERITAGE.SPIRE500.unc']
types.tag=[$
  'co_nanten',$
  'co_magma',$
  'hi',$
  'coe_nanten',$
  'coe_magma',$
  'hie',$
  'pacs100',$
  'pacs160',$
  'spire250',$
  'spire350',$
  'spire500',$
  'pacs100e',$
  'pacs160e',$
  'spire250e',$
  'spire350e',$
  'spire500e']
types.psf=[$
  -1,$
  -1,$
  -1,$
  -1,$
  -1,$
  -1,$
  6.8,$ ;pacs100
  11.4,$;pacs160
  18.2,$;SPIRE250
  24.9,$;SPIRE350
  36.3,$;SPIRE500
  6.8,$ ;pacs100
    11.4,$;pacs160
    18.2,$;SPIRE250
    24.9,$;SPIRE350
    36.3];SPIRE500
  
types.mask=replicate("",n_elements(types.path))

return,types

END