FUNCTION GET_FILTER,select
;+
; NAME:
;   GET_FILTER
;
; PURPOSE:
;   return filter information via a structure
;
; INPUTS:
;   select      see the options below
;
; OUTOUTS:
;   output     filter structure
;              tag names are listed at the end of this routine
;
; KEYWORDS:
;
; EXAMPLE:
; 
; NOTE:
;   vega2abs was from a note of K.S.Lee
;   
; HISTORY:
;   20150818    R.Xue   introduced (re-orgnized from getfilters.pro)
;   20151202    R.Xue   borrow k_load_filters for popular filters
;-

path=cgsourceDir()+'../data/filters/'

if  select eq 'gemini/n-g' then begin
    name='GMOS-g'
    namef='GMOS-!6g!n'
    ew=0.0
    effwave=0.0
    readcol,/silent,path+'gmos_n_g_G0301.txt',wv,tf,format='(f,f)'
    wave=wv*10.
    tran=tf
    vega2ab=!values.f_nan
endif

if  select eq 'gemini/n-i' then begin
    name='GMOS-i'
    namef='GMOS-!8i!6'
    ew=0.0
    effwave=0.0
    readcol,/silent,path+'gmos_n_i_G0302.txt',wv,tf,format='(f,f)'
    wave=wv*10.
    tran=tf
    vega2ab=!values.f_nan
endif

if  select eq 'gemini/n-r' then begin
    name='GMOS-r'
    namef='GMOS-!8r!6'
    ew=0.0
    effwave=0.0
    readcol,/silent,path+'gmos_n_r_G0303.txt',wv,tf,format='(f,f)'
    wave=wv*10.
    tran=tf
    vega2ab=!values.f_nan
endif

if  select eq 'kpno-mosaic-bw' then begin
    name='MOSAIC-Bw'
    namef='MOSAIC-!8Bw!6'
    ew=1275.21
    effwave=4110.78
        
;    readcol,/silent,path+'k10250d',wv,tf,format='(f,f)',skip=14
;    wave=wv*1.0
;    tran=tf/100.
;    vega2ab=0.0185
;   this is just the filter
    k_load_filters,'ndwfs_Bw.par',filter_nlambda, filter_lambda, filter_pass
    wave=filter_lambda
    tran=filter_pass
    vega2ab=k_vega2ab(filterlist='ndwfs_Bw.par',/kurucz)
endif

if  select eq 'kpno-mosaic-r' then begin
    name='MOSAIC-R'
    namef='MOSAIC-!8R!6'
    ew=1511.13
    effwave=6513.54
    
    ;readcol,/silent,path+'k1004bp_aug04.txt',wv,tf,format='(f,f)',skip=14
    ;wave=wv*1.
    ;tran=tf/100.
    ;vega2ab=0.215
    
    k_load_filters,'ndwfs_R.par',filter_nlambda, filter_lambda, filter_pass
    wave=filter_lambda
    tran=filter_pass
    vega2ab=k_vega2ab(filterlist='ndwfs_R.par',/kurucz)
    

endif

if  select eq 'kpno-mosaic-i' then begin
    name='MOSAIC-I'
    namef='MOSAIC-!8I!6'
    ew=1914.59
    effwave=8204.53
    
;    readcol,/silent,path+'k1005bp_aug04.txt',wv,tf,format='(f,f)',skip=14
;    wave=wv*1.
;    tran=tf/100.
;    vega2ab=0.459
    
    k_load_filters,'ndwfs_I.par',filter_nlambda, filter_lambda, filter_pass
    wave=filter_lambda
    tran=filter_pass
    vega2ab=k_vega2ab(filterlist='ndwfs_I.par',/kurucz)
    
endif

if  select eq 'kpno-mosaic-wrc4' then begin
    name='MOSAIC-WRC4'
    namef='MOSAIC-!8WRC4!6'
    ew=41.79
    effwave=5828.71
    readcol,/silent,path+'/misc/k1024_mar11.txt',wv,tf,format='(f,f)'
    wave=float(wv*1.)
    tran=float(tf/100.)>0.0
    vega2ab=!values.f_nan
endif

if  select eq 'subaru-ia445' then begin
    name='Subaru-IA445'
    namef='Subaru-!8IA445!6'
    ew=201
    effwave=4458
    readcol,/silent,path+'/misc/ia445_07.txt',wv,tf,format='(f,f)',comment='#'
    wave=wv*1.
    tran=tf/max(tf)>0.0
    vega2ab=!values.f_nan
endif

if  select eq 'kpno-newfirm-j' then begin
    name=''
    namef=''
    ew=!values.f_nan
    effwave=!values.f_nan
    wave=!values.f_nan
    tran=!values.f_nanf
    vega2ab=0.943
endif

if  select eq 'kpno-newfirm-h' then begin
    name=''
    namef=''
    ew=!values.f_nan
    effwave=!values.f_nan
    wave=!values.f_nan
    tran=!values.f_nanf
    vega2ab=1.367
endif

if  select eq 'kpno-newfirm-ks' then begin
    name=''
    namef=''
    ew=!values.f_nan
    effwave=!values.f_nan
    wave=!values.f_nan
    tran=!values.f_nanf
    vega2ab=1.836
endif

if  select eq 'irac-ch1' then begin
    name=''
    namef=''
    ew=!values.f_nan
    effwave=!values.f_nan
    wave=!values.f_nan
    tran=!values.f_nanf
    vega2ab=2.79
endif

if  select eq 'irac-ch2' then begin
    name=''
    namef=''
    ew=!values.f_nan
    effwave=!values.f_nan
    wave=!values.f_nan
    tran=!values.f_nanf
    vega2ab=3.26
endif

if  select eq 'irac-ch3' then begin
    name=''
    namef=''
    ew=!values.f_nan
    effwave=!values.f_nan
    wave=!values.f_nan
    tran=!values.f_nanf
    vega2ab=3.73
endif

if  select eq 'irac-ch4' then begin
    name=''
    namef=''
    ew=!values.f_nan
    effwave=!values.f_nan
    wave=!values.f_nan
    tran=!values.f_nanf
    vega2ab=4.40
endif

if  n_elements(name) eq 0 then begin
    k_load_filters,select,filter_nlambda, filter_lambda, filter_pass
    ; filter_pass is the contribution to the detector signal per photon
    ; entering the atmosphere of Earth at a specific AM.
    ; it's not the filter transmission function here.
    name=''
    namef=''
    ew=!values.f_nan
    effwave=!values.f_nan
    wave=filter_lambda
    tran=filter_pass
    vega2ab=k_vega2ab(filterlist=select,/kurucz)
endif

wave_halfpower=[]
tranmax=max(tran,tagmax)
wave_maxtran=wave[tagmax]
x=wave[0:tagmax]
y=tran[0:tagmax]
tmp=min(abs(y-0.5*tranmax),tag)
wave_halfpower=[wave_halfpower,x[tag]]
x=wave[tagmax:-1]
y=tran[tagmax:-1]
tmp=min(abs(y-0.5*tranmax),tag)
wave_halfpower=[wave_halfpower,x[tag]]

filter={name:name,$                   ; shortname    
        namef:namef,$                 ; formated name (for IDL plots)
        ew:ew,$                       ; ew in AA
        effwave:effwave,$             ; effective wavelength
        ewf:3e10*1e8/effwave^2.0*ew,$ ; ew in hz
        vega2ab:vega2ab,$             ; AB=Vega+vega2ab
        wave:wave,$                   ; wave vector
        wave_halfpower:[min(wave_halfpower),max(wave_halfpower)],$    
        wave_maxtran:wave_maxtran,$   ; wave halfpower                 
        tran:tran}                    ; transmision function vector

return,filter

END

PRO TEST_GET_FILTER

st=get_filter('sdss_i6.par')
plot,st.wave,st.tran
print,st.vega2ab

st=get_filter('ndwfs_Bw.par')
plot,st.wave,st.tran/max(st.tran,/nan)
y=st.tran*(1./st.wave)
oplot,st.wave,y/max(y),color=cgcolor('yellow')
print,st.vega2ab

st=get_filter('kpno-mosaic-bw')
y=st.tran
oplot,st.wave,y/max(y),color=cgcolor('red')
print,st.vega2ab

;st=get_filter('ndwfs_R.par')
;y=st.tran/(1./st.wave)
;plot,st.wave,y/max(y,/nan)
;print,st.vega2ab
;st=get_filter('kpno-mosaic-r')
;y=st.tran/(1./st.wave)
;oplot,st.wave,y/max(y,/nan),color=cgcolor('red')
;print,st.vega2ab

END