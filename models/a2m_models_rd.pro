PRO A2M_MODELS_RD

path=cgSourceDir()

COMMON a2m_models,$
    mk10_grid,mk10_zm,$
    mk10ph10_grid,mk10ph1_grid,$
    s14comp_grid,s14slab_grid,s14_zm,$
    br06_grid,br06_sigs,$
    gd14_grid,gd14x_grid,gd14_zm
    
restore,path+'/a2m_br06_grid.dat'
restore,path+'/a2m_gd14_grid.dat'
restore,path+'/a2m_mk10_grid.dat'
restore,path+'/a2m_s14_grid.dat'

restore,path+'/a2m_mk10ph1_grid.dat'
restore,path+'/a2m_mk10ph10_grid.dat'
END


