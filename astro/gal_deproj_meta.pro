PRO GAL_DEPROJ_META, cat, g, gh, b, bh,$
    gselect=gselect,bselect=bselect,$   ; select galaxies and bands based on index in tables
    gkey=gkey,gval=gval,$               ; select galaxies based on label
    bkey=bkey,bval=bval,$               ; select bands based on label
    silent=silent
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
btab=path+'../data/'+cat+'_fileinfo.csv'
gtab=path+'../data/'+cat+'.csv'

b=read_table(btab,header=bh,srow=bselect,skey=bkey,sval=bval,bkey='path',silent=silent)
g=read_table(gtab,header=gh,srow=gselect,skey=gkey,sval=gval,/scalar,bkey='Galaxy',silent=silent)

END

PRO TEST_GAL_DEPROJ_META

gal_deproj_meta,'nearby',s,h,types,gkey='Project',gval='*SGP*',$
    bkey='tag',bval=[$
    'hi','himom1','hisnrpk','irac4','dss',$
    'co','cosnrpk','comom1','irac1','nuv'],/silent
print,types.tag    
END