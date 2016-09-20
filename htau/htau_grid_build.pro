PRO HTAU_GRID_BUILD,outpath=outpath
;+
; NAME:
;   HTAU_GRID
;
; PURPOSE:
;   calculate template grid using htau_grid_calc.pro.
;   The templates will be save in an IDL XDR file <htau.dat>,
;
; OUTPUTS:
;   htau_grid.wave     template wavelength grid (list)
;                      grid=wave_samp[1]*10.^(dindgen(wave_samp[2])*wave_samp[0])                         
;   htau_grid.tau      templates (list)
;   htau_grid.state    state for each template (list) 
;   htau_grid.nn       fiducial column density for each template (list)
;   htau_grid.doppb    b-value for each template (list)

; NOTE:
;   the template wavelength grids are optimized for binning in log and coadding
;   
; HISTORY:
;
;   20120810    RX      introduced
;   20140210    RX      add HD/DI and change the template format from 3d to 2d
;   20140212    RX      use IDL list datatype to save templates (IDL v8 required)
;   20150212    RX      use log(lambda) grid to avoid regridding in doppler shifting
;                       
;
;-

tau_grid=list()
wave_grid=list()
state_grid=list()
nn_grid=list()
doppb_grid=list()

; FOR HI/DI LYMAN


state=[replicate("H I,1,*,*,*,*,*",4),replicate("D I,1,*,*,*,*,*",4)]
nn=10.^21
doppb=[2.,4.,8.,16.,2.,4.,8.,16.]

wave_samp=[3e-6,900*10.^(1e-6),55000]
wave=wave_samp[1]*10.^(dindgen(wave_samp[2])*wave_samp[0])

print,''
print,'b-values', string(doppb,format='(f6.1)')
print,'wave:           ',min(wave),max(wave)
print,'wave_dw (AA)  : ',wave[1]-wave[0],wave[-1]-wave[-2]
print,'wave_dv (km/s): ',3e5*(wave[1]-wave[0])/wave[0],3e5*(wave[-1]-wave[-2])/wave[-1]
print,''

T=SYSTIME(1)
tau=htau_line_calc(wave,state,nn,doppb,silent=0)
nd=size(tau,/d)

for j=0,nd[1]-1 do begin
    tau_grid.add,tau[*,j]
    wave_grid.add,wave_samp
    state_grid.add,state[j]
    nn_grid.add,nn
    doppb_grid.add,doppb[j]
endfor
print, '>> total time:   ',strtrim(string(round(SYSTIME(1)-T)),2), 'S'

; FOR H2/HD LYMAN-WERNER

T=SYSTIME(1)
state=[ "H2,X,*,0,*,0,*",$
        "H2,X,*,0,*,1,*",$
        "H2,X,*,0,*,2,*",$
        "H2,X,*,0,*,3,*",$
        "H2,X,*,0,*,4,*",$
        "H2,X,*,0,*,5,*",$
        "H2,X,*,0,*,6,*",$
        "H2,X,*,0,*,7,*",$
        "H2,X,*,0,*,8,*",$
        "HD,X,*,0,*,0,*",$
        "HD,X,*,0,*,1,*",$
        "HD,X,*,0,*,2,*",$
        "HD,X,*,0,*,3,*",$
        "HD,X,*,0,*,4,*"]
n=10.^21
doppb=0.7+findgen(244)*0.1

for i=0,n_elements(doppb)-1 do begin
    
    if  doppb[i] le 2.0 then wave_samp=[1e-6,900.,120000]
    if  doppb[i] gt 2.0 then wave_samp=[3e-6,900*10.^(1e-6),40000]
    print,''
    print,'b-values', string(doppb[i],format='(f6.1)')
    
    wave=wave_samp[1]*10.^(dindgen(wave_samp[2])*wave_samp[0])
    print,'wave:           ',min(wave),max(wave)
    print,'wave_dw (AA)  : ',wave[1]-wave[0],wave[-1]-wave[-2]
    print,'wave_dv (km/s): ',3e5*(wave[1]-wave[0])/wave[0],3e5*(wave[-1]-wave[-2])/wave[-1]
        
    tau=htau_line_calc(wave,state,n,doppb[i],silent=0)
    nd=size(tau,/d)
    for j=0,nd[1]-1 do begin
        tau_grid.add,tau[*,j]
        wave_grid.add,wave_samp
        state_grid.add,state[j]
        nn_grid.add,n
        doppb_grid.add,doppb[i]
    endfor
    
endfor
print, '>> total time:   ',strtrim(string(round(SYSTIME(1)-T)),2), 'S'

htau_grid={wave:wave_grid,tau:tau_grid,state:state_grid,nn:nn_grid,doppb:doppb_grid}

if  n_elements(outpath) eq 0 then outpath='.'
save,htau_grid,filename=outpath+'/htau_templates.xdr',/compress
print,'write out templates: ',  outpath+'/htau_templates.xdr'

END




