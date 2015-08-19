FUNCTION GET_FILTER,select
;+
; NAME:
;   GET_FILTER
;
; PURPOSE:
;   return filter information in a structure
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
;   20150818    R.Xue   introduced (reorgnized from getfilters.pro)
;-

path=cgsourceDir()+'../data/filters/'

if  select eq 'gemini/n-g' then begin
    name='GMOS-g'
    namef='GMOS-!6g!n'
    ew=0.0
    effwave=0.0
    readcol,path+'gmos_n_g_G0301.txt',wv,tf,format='(f,f)'
    wave=wv*10.
    tran=tf
    vega2ab=!values.f_nan
endif

if  select eq 'gemini/n-i' then begin
    name='GMOS-i'
    namef='GMOS-!8i!6'
    ew=0.0
    effwave=0.0
    readcol,path+'gmos_n_i_G0302.txt',wv,tf,format='(f,f)'
    wave=wv*10.
    tran=tf
    vega2ab=!values.f_nan
endif

if  select eq 'gemini/n-r' then begin
    name='GMOS-r'
    namef='GMOS-!8r!6'
    ew=0.0
    effwave=0.0
    readcol,path+'gmos_n_r_G0303.txt',wv,tf,format='(f,f)'
    wave=wv*10.
    tran=tf
    vega2ab=!values.f_nan
endif

if  select eq 'kpno-mosaic-bw' then begin
    name='MOSAIC-Bw'
    namef='MOSAIC-!8Bw!6'
    ew=1275.21
    effwave=4110.78
    readcol,path+'k10250d',wv,tf,format='(f,f)',skip=14
    wave=wv*1.0
    tran=tf/100.
    vega2ab=0.0185
endif

if  select eq 'kpno-mosaic-r' then begin
    name='MOSAIC-R'
    namef='MOSAIC-!8R!6'
    ew=1511.13
    effwave=6513.54
    readcol,path+'k1004bp_aug04.txt',wv,tf,format='(f,f)',skip=14
    wave=wv*1.
    tran=tf/100.
    vega2ab=0.215
endif

if  select eq 'kpno-mosaic-i' then begin
    name='MOSAIC-I'
    namef='MOSAIC-!8I!6'
    ew=1914.59
    effwave=8204.53
    readcol,path+'k1005bp_aug04.txt',wv,tf,format='(f,f)',skip=14
    wave=wv*1.
    tran=tf/100.
    vega2ab=0.459
endif

if  select eq 'kpno-mosaic-wrc4' then begin
    name='MOSAIC-WRC4'
    namef='MOSAIC-!8WRC4!6'
    ew=41.79
    effwave=5828.71
    readcol,path+'k1024_mar11.txt',wv,tf,format='(f,f)'
    wave=wv*1.
    tran=tf/100.
    vega2ab=!values.f_nan
endif

if  select eq 'subaru-ia445' then begin
    name='Subaru-IA445'
    namef='Subaru-!8IA445!6'
    ew=201
    effwave=4458
    readcol,'/Users/Rui/GDrive/Worklib/filters/aux/filter-0321.asc',wv,tf,format='(f,f)',comment='#'
    wave=wv*1.
    tran=tf
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

filter={name:name,$         ; shortname    
        namef:namef,$       ; formated name (for IDL plots)
        ew:ew,$             ; ew in AA
        effwave:effwave,$   ; effective wavelength
        vega2ab:vega2ab,$   ; AB=Vega+vega2ab
        wave:wave,$         ; wave vector
        tran:tran}          ; transmision function vector

return,filter

END