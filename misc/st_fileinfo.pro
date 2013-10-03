FUNCTION ST_FILEINFO
;+
; this structure includes fits file naming/path information
;-
types=replicate({path:'',prefix:'',posfix:'',tag:'',psf:-1.0,mask:''},33)
types.path=['/Users/Rui/Workspace/sting/irac/',$
  '/Users/Rui/Workspace/sting/irac/',$
  '/Users/Rui/Workspace/sting/irac/',$
  '/Users/Rui/Workspace/sting/irac/',$
  '/Volumes/Scratch/reduc/sting-co/mscr/mom0/',$
  '/Volumes/Scratch/reduc/sting-co/mscr/mom0/',$
  '/Volumes/Scratch/reduc/sting-co/mscr/mom0/',$
  '/Volumes/Scratch/reduc/sting-co/mscr/mom0/',$
  '/Volumes/Scratch/reduc/sting-co/mscr/mom0/',$
  '/Volumes/Scratch/reduc/sting-co/mscr/mom0/',$
  '/Volumes/Scratch/reduc/sting-hi/mom0/',$
  '/Volumes/Scratch/reduc/sting-hi/mom0/',$
  '/Volumes/Scratch/reduc/sting-hi/mom0/',$
  '/Volumes/Scratch/reduc/sting-hi/mom0/',$
  '/Volumes/Scratch/reduc/sting-hi/mom0/',$
  '/Volumes/Scratch/reduc/sting-hi/mom0/',$
  '/Volumes/Scratch/data_repo/sting-hi/msc-products/hicont/',$
  '/Volumes/Scratch/data_repo/sting-hi/msc-products/hicont/',$
  '/Users/Rui/Workspace/sting/himom_sim/',$
  '/Users/Rui/Workspace/sting/himom_sim/',$
  '/Users/Rui/Workspace/sting/himom_sim/',$
  '/Users/Rui/Workspace/sting/galex/',$
  '/Users/Rui/Workspace/sting/galex/',$
  '/Users/Rui/Workspace/sting/galex/',$
  '/Users/Rui/Workspace/sting/galex/',$
  '/Users/Rui/Workspace/sting/gromom/',$
  '/Users/Rui/Workspace/sting/gromom/',$
  '/Users/Rui/Workspace/sting/gromom/',$
  '/Users/Rui/Workspace/sting/gromom/',$
  '/Users/Rui/Workspace/sting/gromom/',$
  '/Users/Rui/Workspace/sting/gromom/',$
  '/Users/Rui/Workspace/sting/gromom/',$
  '/Users/Rui/Workspace/sting/gromom/']
types.prefix=['',$
  '',$
  '',$
  '',$
  '',$
  '',$
  '',$
  '',$
  '',$
  '',$
  '',$
  '',$
  '',$  
  '',$
  '',$
  '',$
  '',$
  '',$
  '',$
  '',$
  '',$
  '',$
  '',$
  '',$
  '',$
  'n',$
  'n',$
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
  'co.line.cm.sgm.mom0',$
  'co.line.cm.sgm.emom0',$
  'co.line.cm.sgm.mom1',$
  'co.line.cm.sgm.mom2',$
  'co.line.cm.sgm.snrpk',$
  'co.line.cm.sgm.rms',$
  'hi.line.cm.sgm.mom0',$
  'hi.line.cm.sgm.emom0',$
  'hi.line.cm.sgm.mom1',$
  'hi.line.cm.sgm.mom2',$
  'hi.line.cm.sgm.snrpk',$
  'hi.line.cm.sgm.rms',$
  'hi.cont.cm',$
  'hi.cont.sen',$
  'him.sgm.mom0',$
  'himlow.sgm.mom0',$
  'himhigh.sgm.mom0',$
  '-nd-wt',$
  '-nd-intbgsub',$
  '-fd-wt',$
  '-fd-intbgsub',$
  'co.sgm.mom0_hsen',$
  'co.sgm.emom0_hsen',$
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
  'co',$
  'coe',$
  'comom1',$
  'comom2',$
  'cosnrpk',$
  'corms',$
  'hi',$
  'hie',$
  'himom1',$
  'himom2',$
  'hisnrpk',$
  'hirms',$
  'cont',$
  'conte',$
  'him',$
  'himlow',$
  'himhigh',$
  'nuv-wt',$
  'nuv',$
  'fuv-wt',$
  'fuv',$
  'co_hsen',$
  'coe_hsen',$
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
  -1,$
  -1,$
  -1,$
  -1,$
  -1,$
  -1,$
  -1,$
  -1,$
  -1,$
  -1,$
  -1,$
  -1,$
  -1,$
  -1,$
  -1,$
  -1,$
  -1,$
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
  -1]
types.mask=['.1.final_mask',replicate("",n_elements(types.psf)-1)]

return,types

END