FUNCTION GET_FILTER,select
;+
;   return filter information in a structure
;-

path=cgsourceDir()+'../data/filters/'
print,select
if  select eq 'gemini/n-g' then begin
    name='GMOS-g'
    namef='GMOS-!6g!n'
    ew=0.0
    effwave=0.0
    readcol,path+'gmos_n_g_G0301.txt',wv,tf,format='(f,f)'
    wave=wv*10.
    tran=tf
endif

if  select eq 'gemini/n-i' then begin
    name='GMOS-i'
    namef='GMOS-!8i!6'
    ew=0.0
    effwave=0.0
    readcol,path+'gmos_n_i_G0302.txt',wv,tf,format='(f,f)'
    wave=wv*10.
    tran=tf
endif

if  select eq 'gemini/n-r' then begin
    name='GMOS-r'
    namef='GMOS-!8r!6'
    ew=0.0
    effwave=0.0
    readcol,path+'gmos_n_r_G0303.txt',wv,tf,format='(f,f)'
    wave=wv*10.
    tran=tf
endif

if  select eq 'kpno-mosaic-bw' then begin
    name='MOSAIC-Bw'
    namef='MOSAIC-!8Bw!6'
    ew=0.0
    effwave=0.0
    readcol,path+'k10250d',wv,tf,format='(f,f)',skip=14
    wave=wv*1.0
    tran=tf/100.
endif

if  select eq 'kpno-mosaic-r' then begin
    name='MOSAIC-R'
    namef='MOSAIC-!8R!6'
    ew=0.0
    effwave=0.0
    readcol,path+'k1004bp_aug04.txt',wv,tf,format='(f,f)',skip=14
    wave=wv*1.
    tran=tf/100.
endif

if  select eq 'kpno-mosaic-i' then begin
    name='MOSAIC-I'
    namef='MOSAIC-!8I!6'
    ew=0.0
    effwave=0.0
    readcol,path+'k1005bp_aug04.txt',wv,tf,format='(f,f)',skip=14
    wave=wv*1.
    tran=tf/100.
endif

if  select eq 'kpno-mosaic-wrc4' then begin
    name='MOSAIC-WRC4'
    namef='MOSAIC-!8WRC4!6'
    ew=0.0
    effwave=0.0
    readcol,path+'k1024_mar11.txt',wv,tf,format='(f,f)'
    wave=wv*1.
    tran=tf/100.
endif

if  select eq 'subaru-ia445' then begin
    name='Subaru-IA445'
    namef='Subaru-!8IA445!6'
    ew=0.0
    effwave=0.0
    readcol,'/Users/Rui/GDrive/Worklib/filters/aux/filter-0321.asc',wv,tf,format='(f,f)',comment='#'
    wave=wv*1.
    tran=tf
endif

filter={name:name,$     ; shortname    
        namef:namef,$   ; formated name
        ew:ew,$        ; ew in AA
        effwave:effwave,$   ; effective wavelength
        wave:wave,$        ; wave vector
        tran:tran}         ; transmision function vector

return,filter

END