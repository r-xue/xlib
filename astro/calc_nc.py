from astroquery.lamda import Lamda
import numpy as np
import fnmatch
from decimal import Decimal
from astropy import constants as const

def calc_nc(mol='co',tk=40.0,qn='1',r_oph2=3.0,pt='H2',verbose=False):
    
    """
    Calculate the critical density of typical gas tracers (optically thin and no bg)
    
    About the LAMDA database and its format/query:
        
        http://home.strw.leidenuniv.nl/~moldata/
        
        http://astroquery.readthedocs.io/en/latest/lamda/lamda.html
           initial the database: 
           Lamda.molecule_dict
    keywords:
        mol:       database name
        tk:        t_kin (number)
        qn:        energy level notation (string)
        r_oph2:    ortho-para H2 ratio (number)
        pt:        coll parter (string) 
        verbose    (bool)
    
    History:
        20170921   R.Xue    introduced
        
    Reference:
        Schoier+2005
        Shirley+2015
        
    To-Do:
        add the piecewise temperature interpolation for gamma_ul (Lykins+2015)
    """
  
    
    collrates, radtransitions, enlevels = Lamda.query(mol=mol)
    if  verbose==True:
        print ""
        print "="*200
        print "partner: {0}".format(collrates.keys())
        print enlevels
        print radtransitions
        print collrates
        print "="*200
        print ""
    
    """
    get level_i
    """
    ind,=np.where(enlevels['J']==str(qn))
    level=ind[0]+1
    if  verbose==True:
        print ""
        print ">"*200
        print enlevels[ind]
        print "<"*200
        print ""
    
    """
    get sum(A_ul [u>l])
    """
    
    ind=np.where(radtransitions['Upper']==level)
    sum_a=np.sum(radtransitions['EinsteinA'][ind].quantity)
    if  verbose==True:
        print ""
        print ">"*200
        print radtransitions[ind]
        print 'sum(A_ul):',sum_a
        print "<"*200
        print ""

    """
    get sum(C_ul [u!=l])
    """
    
    sum_c=0.0
    tselect='C_ij(T='+str(int(tk))+')'
    if  verbose==True:
        print ""
        print ">"*200
    for cti,ct in enumerate(collrates.keys()):
        
        if  not fnmatch.fnmatch(ct,'*'+pt+'*'):
            continue
        wt=1.0
        if  ct=='PH2':
            wt=1.0/(r_oph2+1.)
        if  ct=='OH2':
            wt=r_oph2/(r_oph2+1.)
        crate=collrates[ct]
        
        # Downwards Rate
        ind=np.where(crate['Upper']==level)
        if  verbose==True:
            print ct,'Downwards Rate'
            print '-->',crate[ind]
        sum_c=sum_c+np.sum(crate[tselect][ind])*wt
        
        # Upwards Rate
        ind,=np.where(crate['Lower']==level)
        if  verbose==True:
            print ct,'Upwards Rate'
            print '-->',crate[ind]
        for ilevel_u,level_u in enumerate(crate['Upper'][ind]):
            e_u=np.where(enlevels['Level']==level_u)
            e_l=np.where(enlevels['Level']==level)
            eul=enlevels[e_u]['Energy']-enlevels[e_l]['Energy']
            expt=np.exp(-const.h.cgs.value*const.c.cgs.value/const.k_B.cgs.value/tk*eul[0])
            c_lu=crate[tselect][ind[ilevel_u]]*enlevels[e_u]['Weight']*1.0/enlevels[e_l]['Weight']*expt
            c_lu=c_lu.quantity
            c_lu=c_lu[0]
            if  verbose==True:
                print 'r_wt:        ',(enlevels[e_u]['Weight']*1.0/enlevels[e_l]['Weight']*1.0).quantity
                print 'exp(-e/kt)   ',expt            
            sum_c=sum_c+c_lu*wt

    nc=(sum_a/sum_c)
    if  verbose==True:
        
        print "<"*200
        print ""
    
        print ""
        print ">"*200
        print 'sum(C_ul):',sum_c
        print "<"*200
        print ""    
        print "n_crit: {:.2e}".format(nc.value)

    return nc


if  __name__=="__main__":
    """
    try different atoms/mols
    
    output log:
    
        hco+@xpol       qn=1           20k pt:H2    n_crit: 4.65e+04
        h13co+@xpol     qn=1           20k pt:H2    n_crit: 4.14e+04
        cs@lique        qn=1           40k pt:H2    n_crit: 8.53e+03
        hcn             qn=" 01 "      40k pt:H2    n_crit: 1.96e+05
        hcn@hfs         qn=1 2         40k pt:H2    n_crit: 1.64e+05
        hcn@xpol        qn=1           40k pt:H2    n_crit: 1.64e+05
        co              qn=1           40k pt:H2    n_crit: 3.53e+02
        co@old          qn=1           20k pt:H2    n_crit: 5.01e+02
        co@neufeld      qn=1           20k pt:H2    n_crit: 5.23e+02
        ph2o@daniel     qn=2_1_1       35k pt:H2    n_crit: 2.26e+07
        oh2o@daniel     qn=2_1_2       35k pt:H2    n_crit: 2.56e+08
        catom           qn=2           50k pt:H2    n_crit: 1.25e+03
        co              qn=7           50k pt:H2    n_crit: 1.24e+05
        catom           qn=2           50k pt:H2    n_crit: 1.25e+03
        ph2o@daniel     qn=2_1_1       45k pt:H2    n_crit: 2.10e+07
        
    """
    

    level_list=[]
    level_list.append({'mol':'hco+@xpol','qn':'1','tk':20,'pt':'H2'})
    level_list.append({'mol':'h13co+@xpol','qn':'1','tk':20,'pt':'H2'})
    level_list.append({'mol':'cs@lique','qn':'1','tk':40,'pt':'H2'})
    level_list.append({'mol':'hcn','qn':'" 01 "','tk':40,'pt':'H2'})
    level_list.append({'mol':'hcn@hfs','qn':'1 2','tk':40,'pt':'H2'})
    level_list.append({'mol':'hcn@xpol','qn':'1','tk':40,'pt':'H2'})
    level_list.append({'mol':'co','qn':'1','tk':40,'pt':'H2'})
    level_list.append({'mol':'co@old','qn':'1','tk':20,'pt':'H2'})
    level_list.append({'mol':'co@neufeld','qn':'1','tk':20,'pt':'H2'})
    level_list.append({'mol':'ph2o@daniel','qn':'2_1_1','tk':35,'pt':'H2'})
    level_list.append({'mol':'oh2o@daniel','qn':'2_1_2','tk':35,'pt':'H2'})
    level_list.append({'mol':'catom','qn':'2','tk':50,'pt':'H2'})
    level_list.append({'mol':'co','qn':'7','tk':50,'pt':'H2'})
    level_list.append({'mol':'catom','qn':'2','tk':50,'pt':'H2'})
    level_list.append({'mol':'ph2o@daniel','qn':'2_1_1','tk':45,'pt':'H2'})
    
    for i in range(len(level_list)):
        nc=calc_nc(mol=level_list[i]['mol'],
                   qn=level_list[i]['qn'],
                   tk=level_list[i]['tk'],
                   pt=level_list[i]['pt'],
                   verbose=False)
        print "{0:15} {1:12} {2:4}k pt:{3:5} n_crit: {4:.2e}".format(level_list[i]['mol'],
                                                          'qn='+level_list[i]['qn'],
                                                          level_list[i]['tk'],
                                                          level_list[i]['pt'],
                                                          nc.value)
    

