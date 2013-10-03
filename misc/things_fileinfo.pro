FUNCTION THINGS_FILEINFO
;+
; this structure includes fits file naming/path information
;-
types=replicate({path:'',prefix:'',posfix:'',tag:'',psf:-1.0,mask:''},27)
types.path=['/Users/Rui/Workspace/things/irac12/',$
  '/Users/Rui/Workspace/things/irac12/',$
  '/Users/Rui/Workspace/things/irac4/',$
  '/Users/Rui/Workspace/things/irac4/',$
  '/Users/Rui/Workspace/things/mips/',$
  '/Users/Rui/Workspace/things/mips/',$
  '/Users/Rui/Workspace/things/mips/',$
  '/Users/Rui/Workspace/things/herschel/',$
  '/Users/Rui/Workspace/things/herschel/',$
  '/Users/Rui/Workspace/things/herschel/',$
  '/Users/Rui/Workspace/things/herschel/',$
  '/Users/Rui/Workspace/things/herschel/',$
  '/Users/Rui/Workspace/things/herschel/',$
  '/Users/Rui/Workspace/things/galex/',$
  '/Users/Rui/Workspace/things/galex/',$
  '/Users/Rui/Workspace/things/galex/',$
  '/Users/Rui/Workspace/things/galex/',$
  '/Users/Rui/Workspace/things/co/',$
  '/Users/Rui/Workspace/things/co/',$
  '/Users/Rui/Workspace/things/hi/',$
  '/Users/Rui/Workspace/things/hi/',$
  '/Users/ruixue/Workspace/sting/gromom/',$
  '/Users/ruixue/Workspace/sting/gromom/',$
  '/Users/ruixue/Workspace/sting/gromom/',$
  '/Users/ruixue/Workspace/sting/gromom/',$
  '/Users/ruixue/Workspace/sting/gromom/',$
  '/Users/ruixue/Workspace/sting/gromom/']
types.prefix=['NGC',$
  'NGC',$
  'ngc',$
  'ngc',$
  'ngc',$
  'ngc',$
  'ngc',$
  'ngc',$
  'ngc',$
  'ngc',$
  'ngc',$
  'ngc',$
  'ngc',$
  'ngc',$
  'ngc',$
  'ngc',$
  'ngc',$
  '',$
  '',$
  '',$
  '',$
  'n',$
  'n',$
  'n',$
  'n',$
  'n',$
  'n']
types.posfix=[ '.phot_bgsub.1',$
  '.phot_bgsub.1e',$
  '.phot_bgsub.4',$
  '.phot_bgsub.4e',$
  '.mips24',$
  '.mips70',$
  '.mips160',$
  '.pacs70',$
  '.pacs100',$
  '.pacs160',$
  '.spire250',$
  '.spire350',$
  '.spire500',$
  '-nd-wt',$
  '-nd-intbgsub',$
  '-fd-wt',$
  '-fd-intbgsub',$
  '.co21.mom0',$
  '.co21.emom0',$
  '.hi.mom0',$
  '.hi.emom0',$
  'co.sgm.mom0_lsen',$
  'co.sgm.emom0_lsen',$
  'hi.sgm.mom0_hsen',$
  'hi.sgm.emom0_hsen',$
  'hi.sgm.mom0_lsen',$
  'hi.sgm.emom0_lsen']
types.tag=[   'irac1',$
  'irac1e',$
  'irac4',$
  'irac4e',$
  'mips24',$
  'mips70',$
  'mips160',$
  'pacs70',$
  'pacs100',$
  'pacs160',$
  'spire250',$
  'spire350',$
  'spire500',$
  'nuv-wt',$
  'nuv',$
  'fuv-wt',$
  'fuv',$
  'co21',$
  'co21e',$
  'hi',$
  'hie',$
  'co_lsen',$
  'coe_lsen',$
  'hi_hsen',$
  'hie_hsen',$
  'hi_lsen',$
  'hie_lsen']
types.psf=[   1.66,$
  1.66,$
  1.98,$
  1.98,$
  6.,$  ;mips24
  18.,$ ;mips70
  40.,$ ;mips160
  5.6,$ ;pacs70
  6.8,$ ;pacs100
  11.4,$ ;pacs160
  18.2,$
  24.9,$
  36.3,$
  5.3,$
  5.3,$
  4.3,$
  4.3,$
  -1,$
  -1,$
  -1,$
  -1,$
  -1,$
  -1,$
  -1,$
  -1,$
  -1,$
  -1]
types.mask=['.1.final_mask',replicate("",n_elements(types.psf)-1)]

return,types

END