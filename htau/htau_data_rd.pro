PRO HTAU_DATA_RD,path=path,outpath=outpath
;+
;
;   Read H2/HD/HI/DI data in Meudon into an IDL structure,
;   also 
;   save the structure in the common block htau_data..
;
;   if you alrady have the Meudon code installed,
;   try path='$pdr/1.4.4/data/UVdata'
;-


if  n_elements(path) eq 0 then begin
    path=''
    tmp='/opt/astroph/mpdr/PDRLight_1.0/data/UVdata/'
    if  file_test(tmp) then path=tmp
    tmp=cgSourceDir()+'../data/uvdata/'
    if  file_test(tmp) then path=tmp
endif else begin
    if  ~file_test(path) then path='' 
endelse

if  path eq '' then begin
    print,'!!no data found!!'
    stop
endif



COMMON htau,htau_data,htau_grid

; IDL STRUCTURE HOLDING ABSORPTION LINE DATABASE
temp =  {   spec:'',$                   ; species
            wl:!values.f_nan,$          ; wavelength
            f:!values.f_nan,$           ; oscillator strength
            gamma:!values.f_nan,$       ; inverse radiative lifetime of upper level (s-1)
            name:'',$                   ; transition name
            nu:'',$                     ; upper electronic level
            nl:'',$                     ; lower electronic level (nl=1 ground level)
            nvu:'',$                    ; upper vibrational level 
            nvl:'',$                    ; lower vibrational level (nvl=0 ground level)
            nju:'',$                    ; upper rotational level
            njl:'',$                    ; lower rotational level (njl=0 ground level)
            note:'' $                   ; comment
         }
hdata=[]

; FOR H2/HD LYMAN/WERNER
paths=path+['/uvh2b29.dat','/uvh2c29.dat','/uvhd.dat']
specs=['H2','H2','HD']
for i=0,2 do begin
    if i ne 2 then begin
    readcol,paths[i],$
        index,$
        nd,$
        nvl,$
        njl,$
        nvu,$
        njd,$
        f,$
        wl,$
        gamma,$
        dummy1,$
        format='I,I,I,I,I,I,f,f,f,f',/silent
    endif else begin
    readcol,paths[i],$
        nd,$
        nvl,$
        njl,$
        nvu,$
        njd,$
        f,$
        wl,$
        dummy1,$
        gamma,$
        dummy2,$
        format='I,I,I,I,I,f,f,f,f,f',/silent
    endelse
    temps=replicate(temp,n_elements(nd))
    temps.spec=specs[i]
    temps.wl=wl
    temps.name=''
    temps.f=f
    temps.gamma=gamma
    temps[where(nd eq 1,/null)].nu='B'
    temps[where(nd eq 2,/null)].nu='C'
    temps.nl='X'
    temps.nvu=strtrim(nvu,2)
    temps.nvl=strtrim(nvl,2)
    temps.nju=strtrim(njl+njd,2)
    temps.njl=strtrim(njl,2)
    hdata=[hdata,temps]
endfor

; FOR HI/DI LYMAN LINES
paths=path+['/uvh.dat','/uvd.dat']
specs=['H I','D I']
for i=0,1 do begin
    readcol,paths[i],$
        nd,$
        f,$
        wl,$
        gamma,$
        format='I,f,f,f',/silent
    temps=replicate(temp,n_elements(nd))
    temps.spec=specs[i]
    temps.wl=wl
    temps.name=''
    temps.f=f
    temps.gamma=gamma
    temps.nu=strtrim(nd+1,2)
    temps.nl='1'
    hdata=[hdata,temps]
endfor

; FOR OWENS LINES
paths=path+'/AtomicData.d'
    readfmt,paths,$
        'f9,a11,i4,f10,f10',$
        wl,$
        names,$
        refc,$
        f,$
        gamma,$
        /silent
temps=replicate(temp,n_elements(wl))
temps.spec=strtrim(names,2)
temps.wl=wl
temps.name=''
temps.f=f
temps.gamma=gamma
temps.note='owens'
hdata=[hdata,temps]

; ADD TRANSITION NAMES
letters = [ 'alpha', 'beta', 'gamma', 'delta', 'epsilon',  'zeta', $
            'eta', 'theta', 'iota', 'kappa', 'lambda', 'mu', $
            'nu', 'xi', 'omicron', 'pi', 'rho', 'sigma', 'tau', $
            'upsilon', 'phi', 'chi', 'psi', 'omega' ]

for i=0,n_elements(hdata)-1 do begin
    name=''
    if  hdata[i].spec eq 'H2' or hdata[i].spec eq 'HD' then begin
        if hdata[i].nl eq 'X' and hdata[i].nu eq 'B' then eband='L'
        if hdata[i].nl eq 'X' and hdata[i].nu eq 'C' then eband='W'
        vband=hdata[i].nvu+'-'+hdata[i].nvl
        njd=fix(hdata[i].nju)-fix(hdata[i].njl)
        if njd eq 1  then jband='R'
        if njd eq 0  then jband='Q'
        if njd eq -1 then jband='P'
        jband=jband+'('+hdata[i].njl+')'
        name=eband+vband+jband
    endif
    if  hdata[i].spec eq 'H I' or hdata[i].spec eq 'D I' then begin
        if hdata[i].nl eq 1 then eband='Ly'
        nd=fix(hdata[i].nu)-fix(hdata[i].nl)
        if  nd le 24 then begin
            name=eband+cggreek(letters[nd-1])
        end
    endif
    hdata[i].name=name
endfor

htau_data=hdata

if  n_elements(outpath) eq 0 then outpath='.'

print,''
print,replicate('+',40)
save,htau_data,filename=outpath+'/htau_database.xdr',/compress
print,'write out templates: ', outpath+'/htau_database.xdr'
print,replicate('+',40)
print,''

END



PRO TEST_HTAU_DATA_RD

;htau_data_rd
COMMON htau,htau_data,htau_grid
line=htau_data

;tag=where(line.spec eq 'H2' and line.note eq '')
;for i=0,n_elements(tag)-1 do begin
;    print,line[tag[i]]
;endfor

tag=where(line.spec eq 'D I' and line.note eq '')
for i=0,n_elements(tag)-1 do begin
    print,line[tag[i]]
endfor

tag=where(line.spec eq 'D I' and line.note eq 'owens')
for i=0,n_elements(tag)-1 do begin
    print,line[tag[i]]
endfor

tag=where( (line.spec eq 'C II' or line.spec eq 'C II*') and $
            line.note eq 'owens' and $
            line.wl gt 1035 and line.wl le 1038.)
for i=0,n_elements(tag)-1 do begin
    print,line[tag[i]]
endfor


END

;
;
;
;;+++++++++++++++++++++++++++++++++++++++++++
;;  ARCHIVED CODES
;;+++++++++++++++++++++++++++++++++++++++++++
;
;FUNCTION OLD_H2DATA_RD,lvib,path=path
;;+
;;   used to read H2 data from the h2ools format (not useful anymore)
;;-
;
;if n_elements(path) eq 0 then path="/Users/Rui/Dropbox/Worklib/idl/resource/h2ools/h1h2data/"
;h2_lvib=strtrim(lvib,2)
;molec_linefile=path+"highjsh2vpnvpp"+h2_lvib+".dat"
;
;readcol, molec_linefile,  $
;    molec_uvib, molec_lvib, $
;    molec_urot, molec_lrot, $
;    molec_wl, molec_f, $
;    molec_gu, molec_gamma,$
;    format='I,I,I,I,f,f,I,F',/silent
;
;lastwb=where(molec_wl eq 1008.5518)
;band=replicate(' ',n_elements(molec_f))
;band[0:lastwb-1]='L'
;band[lastwb:*]='W'
;
;return,{  uvib:molec_uvib,$
;    lvib:molec_lvib,$
;    urot:molec_urot,$
;    lrot:molec_lrot,$
;    wl:molec_wl,$
;    f:molec_f,$
;    gu:molec_gu,$
;    gamma:molec_gamma,$
;    band:band}
;
;END
;
;FUNCTION OLD_HDDATA_RD,path=path
;
;;+
;;   used to read HD data from the h2gui format (values from D. Welty)
;;-
;    
;if  not keyword_set(path) then begin
;    path="~/Dropbox/Worklib/idl/resource/h2tau/borrow/h1h2data-h2gui/"
;endif
;hd_linefile=path+'line_hd.dat'
;
;readcol, hd_linefile,  hd_id, hd_elec, hd_uvib, hd_lvib, $
;    hd_urot, hd_lrot, hd_wl, hd_f, $
;    hd_gu, hd_gamma, hd_names, hd_rank,$
;    format='I,I,I,I,I,I,F,F,I,F,A,I', skipline=9,/silent
;
;
;return,{  uvib:hd_uvib,$
;    lvib:hd_lvib,$
;    urot:hd_urot,$
;    lrot:hd_lrot,$
;    wl:hd_wl,$
;    f:hd_f,$
;    gu:hd_gu,$
;    gamma:hd_gamma,$
;    name:hd_names,$
;    rank:hd_rank}
;
;END
;
;FUNCTION OLD_ATDATA_RD,path=path
;
;if  not keyword_set(path) then begin
;    path="~/Dropbox/Worklib/idl/resource/h2tau/borrow/h1h2data-h2gui/"
;endif
;atom_linefile=path+'line_atom.dat'
;readcol, atom_linefile, atom_index, atom, ion, atom_wl, format='I,A,A,F',/silent
;atom_label ='  '+atom+' '+ion
;
;return,{index:atom_index,label:atom_label,wl:atom_wl}
;
;END

