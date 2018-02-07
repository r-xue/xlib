
"""

A Python implementation of the AMOEBA / Nelder-Mead downhill-simplex algorithm for
minizing a model function

    loosely based on amoeba_sa.pro (IDL) from E.Rolosky with the improvements from H.Fu

reference:
    https://github.com/fchollet/nelder-mead/blob/master/nelder_mead.py
    https://docs.scipy.org/doc/scipy/reference/optimize.html#module-scipy.optimize
    https://docs.scipy.org/doc/scipy/reference/tutorial/optimize.html
    https://en.wikipedia.org/wiki/Nelder%E2%80%93Mead_method

note:
    for using it as a module:
    >sys.path.append("/PATH_TO_SCRIPTS/")
    >from amoeba_sa import amoeba_sa

history:
    20171215    RX      introduced
    20171216    RX      return the result as dict
    
"""

import numpy as np
import copy
import sys

#from scipy.stats.distributions import chi2

def amoeba_sa(func,p0,scale, 
              p_lo=None,p_up=None,
              funcargs=None,
              ftol=1e-5,
              maxiter=5000,
              temperature=0.,
              verbose=False): 
    """
    
    Keywords:
        func:         name of the function to be evaluate
        scale:        the search scale for each variable, a list with one
                      element for each variable.
        funcargs:     unction optional parameters packed (dict)
        p0:           initial values (ndarray)
        scale:        initial scale (ndarray)
        p_lo:         p_lo limit for p (ndarray)
        p_up:         p_up limit for p (ndarray)
    
    return
    
        dict
    
    """
    if  p_lo is None:
        p_lo=p0-np.inf
    if  p_up is None:
        p_up=p0+np.inf

    # (i,i+1) array for SIMPLEX
    # IDL and Python have different indexing orders
    # https://docs.scipy.org/doc/numpy/user/basics.indexing.html
    ndim=len(p0)
    p = np.outer(p0, np.ones(ndim+1))
    for i in range(ndim):
        p[i][i+1]+=scale[i]

    y=np.zeros(ndim+1)+func(p[:, 0],**funcargs)
    for i in range(1,ndim+1):
        y[i]=func(p[:, i],**funcargs)
    
    # list holding your trying route
    pars=copy.deepcopy(p)    # p: (ndim,ndim+1) positions of each simplex vertex
    chi2=copy.deepcopy(y)    # y: (ndim+1) chi2 at each simplex vertex
 
    
    niter=0
    psum=np.sum(p, axis=1)

    while niter<=maxiter:
        
        y=y-temperature*np.log(np.random.random(ndim+1))

        s=np.argsort(y)
        ilo=s[0]                            # index to Lowest chi^2
        ihi=s[-1]                           # index to Highest chi^2
        inhi=s[-2]                          # index to Next highest chi^2
        d=np.abs(y[ihi])+np.abs(y[ilo])     # denominator = interval
        
        if  verbose==True:
            print niter,np.abs(y[ilo]),np.abs(y[ihi])
        
        if  d!=0.0:                         # compute fractional change in chi^2
            rtol=2.0*np.abs(y[ihi]-y[ilo])/d
        else:                               # terminate if denominator is 0
            rtol=ftol/2.  

        if  rtol<ftol or niter==maxiter:
            #print rtol,ftol
            break

        niter=niter+2
        #print '->',psum
        p,psum,pars,chi2,ytry=amotry_sa(func,p,psum,ihi,-1.0,y,
                       temperature=temperature,
                       p_up=p_up,p_lo=p_lo,
                       pars=pars,chi2=chi2,funcargs=funcargs)
        #print '<-',psum
        if  ytry<=y[ilo]:
            p,psum,pars,chi2,ytry=amotry_sa(func,p,psum,ihi,2.0,y,
                           temperature=temperature,
                           p_up=p_up,p_lo=p_lo,
                           pars=pars,chi2=chi2,funcargs=funcargs)
        else: 
            if  ytry>=y[inhi]:
                ysave=y[ihi] 
                p,psum,pars,chi2,ytry=amotry_sa(func,p,psum,ihi,0.5,y,
                               temperature= temperature,
                               p_up=p_up,p_lo=p_lo,
                               pars=pars,chi2=chi2,funcargs=funcargs)
                if  ytry>=ysave:
                    for i in range(ndim+1):
                        if  i!=ilo:
                            psum=0.5*(p[:, i] + p[:, ilo])
                            p[:, i] = psum
                            y[i] = func(psum,**funcargs)
                            pars=np.append(pars,np.expand_dims(psum,axis=1),axis=1)
                            chi2=np.append(chi2,y[i])
                    niter=niter + ndim
                    psum=np.sum(p, axis=1)
            else: 
                niter=niter-1
    
    dict={}
    #print chi2
    #print chi2[np.argmin(chi2)]
    dict['p_best']=pars[:,np.argmin(chi2)]
    dict['p0']=p0
    dict['niter']=niter
    dict['maxiter']=maxiter
    dict['chi2']=chi2       # (ndim+1+niter)        chi2 at each simplex vertex
    dict['pars']=pars       # (ndim,ndim+1+niter)   positions of each simplex vertex
    dict['temperature']=temperature
    dict['p_up']=p_up
    dict['p_up']=p_lo
    
    return  dict

def amotry_sa(func,p,psum,ihi,fac,y, 
              temperature=0.0, 
              p_up=+np.inf,p_lo=-np.inf,
              pars=None,chi2=None,
              funcargs=None):
    # we can return modified parameters via mutable variales
    # but it's not safe in general
    # we return stack variables instead
    fac1=(1.0-fac)/len(psum)
    fac2=fac1-fac
    ptry=np.maximum(np.minimum(psum*fac1-p[:,ihi]*fac2,p_up),p_lo)
    
    ytry=func(ptry,**funcargs)

    
    pars=np.append(pars,np.expand_dims(ptry,axis=1),axis=1)
    chi2=np.append(chi2,ytry)
 
    ytry = ytry+temperature*np.log(np.random.random())  
    if  ytry<y[ihi]:
        y[ihi]=ytry
        #psum=psum+ptry-p[:, ihi] #(don't use this as we don't want to change psum id (just modify it) 
        psum+=ptry-p[:, ihi]
        p[:,ihi] = ptry
        
    return  p,psum,pars,chi2,ytry



