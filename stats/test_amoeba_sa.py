


if  __name__=="__main__":
    
    """
    run fitting benchmark for amoeba_sa.py
        https://docs.scipy.org/doc/scipy/reference/tutorial/optimize.html
        https://docs.scipy.org/doc/scipy/reference/generated/scipy.optimize.minimize.html#scipy.optimize.minimize
        http://pyfssa.readthedocs.io/en/stable/nelder-mead.html
        https://codesachin.wordpress.com/2016/01/16/nelder-mead-optimization/
        http://www.scipy-lectures.org/advanced/mathematical_optimization/
        https://stackoverflow.com/questions/43644797/what-is-xtol-for-in-minimizemethod-nelder-mead
        https://github.com/alexblaessle/constrNMPy
        http://effbot.org/zone/default-values.htm
        
        http://www.informit.com/articles/article.aspx?p=2355856&seqNum=4
        https://codehabitude.com/2013/12/24/python-objects-mutable-vs-immutable/
    """

    import numpy as np
    import matplotlib.pyplot as plt
    from astropy.modeling.models import custom_model
    from astropy.modeling.fitting import LevMarLSQFitter
    from astropy.modeling import models, fitting
    import scipy.optimize as optimize
    
    def func(p,x):
        y=p[0] * np.exp(-0.5 * ((x - p[1]) / p[2])**2) + p[3] * np.exp(-0.5 * ((x - p[4]) / p[5])**2)
        return y
    
    def func_chi2(p,x,y):
        ym=func(p,x)
        dv=(ym-y)/0.1
        chi2=np.sum(dv**2.0)
        return chi2
    
    def func_chi2_new(p,x=None,y=None):
        ym=func(p,x)
        dv=(ym-y)/0.1
        chi2=np.sum(dv**2.0)
        return chi2
    

    
    
    #######################################################################
    
    # Define model
    @custom_model
    def sum_of_gaussians(x, amplitude1=1., mean1=-1., sigma1=1.,
                            amplitude2=1., mean2=1., sigma2=1.):
        return (amplitude1 * np.exp(-0.5 * ((x - mean1) / sigma1)**2) +
                amplitude2 * np.exp(-0.5 * ((x - mean2) / sigma2)**2))
    
    # Generate fake data

    x = np.linspace(-5., 5., 200)
    m_ref = sum_of_gaussians(amplitude1=2., mean1=-0.5, sigma1=0.4,
                             amplitude2=0.5, mean2=2., sigma2=1.0)
    np.random.seed(0)
    y = m_ref(x) + np.random.normal(0., 0.1, x.shape)
    
    # Fit model to data
    m_init = sum_of_gaussians()
    fit = LevMarLSQFitter()
    m = fit(m_init, x, y)
    
    # Plot the data and the best fit
    plt.plot(x, y, 'o', color='k')
    plt.plot(x, m(x),color='b')
    
    #######################################################################
    
    #   scipy.optimize test

    po=np.array([2,-0.5,0.4,0.5,2,1.0])
    p0=np.array([0.2,-0.5,0.4,0.5,3.,1.0])
    #p0=np.array([1.0,-0.5,0.4,0.5,3.,1.0])
    
    # this doesnt work properly as the simplex_init is not good.
    pr=optimize.minimize(func_chi2,p0,args=(x,y),method='Nelder-Mead',tol=1e-10,options={'disp':True,'maxiter':5000})
    print pr.x
    
    # this works
    initial_simplex=np.outer(np.ones(len(p0)+1),p0)
    for i in range(len(p0)):
        initial_simplex[i+1, i]=p0[i]+2.0
    pr=optimize.minimize(func_chi2,p0,args=(x,y),method='Nelder-Mead',tol=1e-10,options={'disp':True,'maxiter':5000,'initial_simplex':initial_simplex}) 
    print pr.x
    
    # this one works with a speedup evluation
    pr=optimize.minimize(func_chi2,p0,args=(x,y),method='BFGS',tol=1e-10,options={'disp':True,'maxiter':5000})
    print pr.x
    
    print 'po:',po
    print 'p0:',p0
    print 'pf:',pr.x

    plt.plot(x, func(po,x),color='k')
    plt.plot(x, func(pr.x,x),color='y')

    # try the amobea.pro algorithm now
    pr=amoeba_sa(func_chi2_new,p0,np.array([2.,2.,2.,2.,2.,2.]),funcargs={'x':x,'y':y})
    print 'pbest:   ',pr['p_best']
    print 'pniter:  ',pr['niter']
    print func_chi2_new(po,x=x,y=y)
    
    # try the amobea.pro algorithm now
    pr=amoeba_sa(func_chi2_new,p0,np.array([2.,2.,2.,2.,2.,2.]),funcargs={'x':x,'y':y},temperature=10)
    print 'pbest:   ',pr['p_best']
    print 'pniter:  ',pr['niter']
    print func_chi2_new(po,x=x,y=y)    
    
    plt.plot(x, func(pr['p_best'],x),color='r')
    #######################################################################

    
    plt.savefig('test_amoeba_sa.png')
    plt.close()
    
    #execfile('/Users/Rui/Dropbox/Worklib/projects/xlib/stats/amoeba_sa.py')
    
    """
    mmuttable:
    list
    dict
    set
    bytearray
    user-defined classes (unless specifically made immutable)
    """
    
    """
    def function(data=[]):
        data.append(1)
        return data
    
    print function()
    print function()
    print function()
    
    def inc(j):
        j += 1
        
    def empty(j):
        j=np.array([])
        
        
        
    j=1
    print j
    inc(j)
    print j
    
    j=1
    j=np.array(j)
    print j
    inc(j)
    print j
    
    j=1
    j=np.array(j)
    print j
    empty(j)
    print j
    """
    
    
    