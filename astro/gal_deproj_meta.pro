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
;-

path=cgsourcedir()
btab=path+'../data/'+cat+'_fileinfo.xlsx'
gtab=path+'../data/'+cat+'.xlsx'

b=read_table(btab,header=bh,srow=bselect,skey=bkey,sval=bval,bkey='path',silent=silent,refresh=refresh)
g=read_table(gtab,header=gh,srow=gselect,skey=gkey,sval=gval,/scalar,bkey='Galaxy',silent=silent,refresh=refresh)

END

PRO TEST_GAL_DEPROJ_META

gal_deproj_meta,'nearby',s,h,types,gkey='Project',gval='*SGP*',$
    bkey='tag',bval=[$
    'hi','himom1','hisnrpk','irac4','dss',$
    'co','cosnrpk','comom1','irac1','nuv'],/silent,/refresh
print,types.tag    
END