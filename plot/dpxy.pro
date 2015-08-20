FUNCTION DPXY, XYBOX,$
    IBOX=IBOX,DPI=DPI,$
    PBOX=PBOX,DPP=DPP,$
    CURRENT=CURRENT,silent=silent
;+
;   Calculate the resolution (dot density in the DATA coordinates) offered by the output device
;   using the below options:
;       ps:         dot per inch (DPI), plotting box size in inches (ibox) <--default
;       xwin:       dot per pixel (DPP), plotting box size in pixel number (pbox)
;       current:    dpxy from the current device
;   
;   Your resampled image will still look sharp if the resolution is better than DPXY() 
;-
if  n_elements(mindpi) NE 1 THEN mindpi=100.

;   FIND PLOTTING BOX SIZE (IN THE DATA UNITS)
XYSIZE=XYBOX
if  n_elements(xysize) eq 1 then begin
    xysize=xysize*[1.,1.]
endif

;   FIND OUT THE NUMBER OF DOTS WHICH THE DEVICE CAN PUT INTO THE PLOTTING BOX
if  ~keyword_set(dpi) then dpi=100.
if  ~keyword_set(dpp) then dpp=4.

if  ~keyword_set(pbox) then begin
    if  n_elements(ibox) eq 0 then ndot=[8.0,8.0]*2.54*dpi
    if  n_elements(ibox) eq 1 then ndot=ibox*[1.,1.]*2.54*dpi
    if  n_elements(ibox) eq 2 then ndot=ibox*2.54*dpi
endif else begin
    if  n_elements(pbox) eq 1 then pbox=pbox*[1.,1.]
    ndot=pbox*dpp
endelse

if  keyword_set(current) then begin
    IF !D.name EQ 'PS' THEN BEGIN
        ndot=[!D.x_size,!D.y_size]/[2.54*!D.x_px_cm,2.54*!D.x_px_cm]*dpi
        if  ~keyword_set(silent) then begin
            print,'device: ps'
            print,'size (inch): '+string(ndot[0]/dpi)+string(ndot[1]/dpi)
        endif
    ENDIF ELSE BEGIN
        ndot=[!D.x_size,!D.y_size]*dpp
        if  ~keyword_set(silent) then begin
            print,'device: x'
            print,'size (pix):  '+string(ndot[0]/dpp)+string(ndot[1]/dpp)
        endif
    ENDELSE
endif

dpxy=ndot/xysize
if  ~keyword_set(silent) then begin
    print,'dpxy: ',dpxy
    print,'psxy: ',1.0/dpxy
endif

return,dpxy

END

PRO TEST_DPXY

XYSIZE=600.0    ;in data units
IBOX=3.0        ;in inches

print,'--'
tt=dpxy(xysize,ibox=ibox)
print,'--'


set_plot,'X'
print,'--'
tt=dpxy(xysize,ibox=ibox,/current)
print,'--'

set_plot, 'ps'
device, filename='test.eps', $
    bits_per_pixel=8,/encapsulated,$
    xsize=10,ysize=7,/inches,/col,xoffset=0,yoffset=0,/cmyk
print,'--'
tt=dpxy(xysize,ibox=ibox,/current)
plot,[0],[0,0],position=[0.1,0.1,0.9,0.9]
tt=dpxy(xysize,ibox=ibox,/current)
print,'--'
device, /close
set_plot,'X'

    
END