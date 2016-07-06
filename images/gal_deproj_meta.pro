PRO GAL_DEPROJ_META, cat, g, gh, b, bh,$
    gselect=gselect,bselect=bselect,$   ; select galaxies and bands based on index in tables
    gkey=gkey,gval=gval,$               ; select galaxies based on label
    bkey=bkey,bval=bval,$               ; select bands based on label
    silent=silent,refresh=refresh
;+
;
;   INPUT
;       cat:    catalog name
;       g:      galaxy information
;       b:      images information
;       
;   e.g. 
;   gal_deproj_meta,'nearby',g,gh,b,bh,$
;       gkey=['Project'],gval=['*SGP*','*TGP*'],$
;       bkey=['tag'],bval=['*co*']
;
;   e.g,
;   gal_deproj_meta,'nearby',s,h,types,gkey='Project',gval='*SGP*',$
;       bkey='tag',bval=[$
;       'hi','himom1','hisnrpk','irac4','dss',$
;       'co','cosnrpk','comom1','irac1','nuv'],/silent,/refresh
;-

path=cgsourcedir()

if  cat eq 'nearby' then begin
    btab='gsheet:nearby_fileinfo:1xSX1zD7uOoDanRWP0vMk8AqIZTtmeY-2Q922FDbTzTA'
    gtab='gsheet:nearby:1-as5SSi5ZEUFzVIB6nXH0bY_1IzxRnmuTfmBYuQp9rA'
endif


b=read_table(btab,header=bh,srow=bselect,skey=bkey,sval=bval,bkey='path',silent=silent,refresh=refresh)
g=read_table(gtab,header=gh,srow=gselect,skey=gkey,sval=gval,/scalar,bkey='Galaxy',silent=silent,refresh=refresh)

END
