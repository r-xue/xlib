PRO MC_MAKESFR_M24HA,gal
  ;+
  ; NAME:
  ;   SFR_M24HA
  ;
  ; PURPOSE:
  ;   calculate SFR from H-alpha & MIPS 24 micron using a Calzetti et al. 2007 Eq7
  ;
  ; INPUTS:
  ;   gal:          LMC or SMC
  ;
  ; HISTORY:
  ;
  ;   20120217      RX
  ;-
  
  ; LOAD MIPS/H-alpha
  m24=readfits(gal+'_MIPS24_GAUSS41_smo60.fits',m24hd)
  ha='013' & if gal eq "SMC" then ha='510'
  ha=readfits(gal+'.fl_smo60.fits',hahd)
  
  print,size(m24, /tn)
  print,size(ha, /tn)
  ha=float(ha)
  
  ; BLANKING
  ntag=where(m24 lt 0.0)
  if ntag[0] ne -1 then m24[ntag]=!VALUES.F_NAN
  ntag=where(ha lt 0.0)
  if ntag[0] ne -1 then ha[ntag]=!VALUES.F_NAN
  

  
  m24_sub=m24
  m24hd_sub=m24hd
  ha_sub=ha
  hahd_sub=hahd
  
  ; ergkpc -> luminosity surface density  LSD -> erg s^-1 kpc^-2
  dr2ergkpc=2.29444*10.^(35-42)
  mjy2ergkpc=9.5234*10.^(25-42)*3.0e14/24.
  
  sfr=5.3*10.^(-42+42)*(ha_sub*dr2ergkpc+0.031*m24_sub*mjy2ergkpc)
  sfrr=(0.031*m24_sub*mjy2ergkpc)/(ha_sub*dr2ergkpc+0.031*m24_sub*mjy2ergkpc)
  
  WINDOW, 0, XSIZE=800, YSIZE=800, TITLE='deproject quickview'
  cgloadct,0,/rev
  cgimage,m24_sub,STRETCH=5,position=[0.05,0.55,0.45,0.95],title='M24'
  cgimage,ha_sub,STRETCH=5,position=[0.55,0.55,0.95,0.95],title='H-alpha',/noe
  cgimage,sfr,STRETCH=5,position=[0.05,0.05,0.45,0.45],/noe,title='SFR'
  cgimage,sfrr,STRETCH=5,position=[0.55,0.05,0.95,0.45],/noe,title='SFR(H-alpha)/SFR'
  
  sxaddpar, m24hd_sub, 'DATAMAX', max(m24_sub,/nan)
  sxaddpar, m24hd_sub, 'DATAMIN', min(m24_sub,/nan)
  writefits,gal+'_m24_smo60.fits',m24_sub, m24hd_sub
  
  sxaddpar, hahd_sub, 'DATAMAX', max(ha_sub,/nan)
  sxaddpar, hahd_sub, 'DATAMIN', min(ha_sub,/nan)
  writefits,gal+'_ha_smo60.fits',ha_sub, hahd_sub
  
  sfrhd=hahd_sub
  sxaddpar, sfrhd, 'DATAMAX', max(sfr,/nan)
  sxaddpar, sfrhd, 'DATAMIN', min(sfr,/nan)
  writefits,gal+'_sfr_smo60.fits',sfr, sfrhd
  
  sfrrhd=hahd_sub
  sxaddpar, sfrrhd, 'DATAMAX', max(sfrr,/nan)
  sxaddpar, sfrrhd, 'DATAMIN', min(sfr,/nan)
  writefits,gal+'_sfr_m24frac_smo60.fits',sfrr, sfrrhd
  
END
