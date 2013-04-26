FUNCTION POS_MP, ip, nxy, margin, omargin
;+
; NAME:
;   POS_MP
;
; PURPOSE:
;   calculate the normalized posistion vector fro muti-panel plotting
;
; INPUTS:
;   ip      -- which panel (in a left->right/top->bottom sequence), starting with 0
;   nxy     -- number of columns/rows in the plot
;   margin  -- margin for each panel (scaler or vector of two or four) [in normal]
;              [leftside,bottom,rightside,top]
;   omargin -- overall margin for multi-panel plots (scaler or vector of two or four) [in normal]
;              [leftside,bottom,rightside,top]
; OUTPUTS:
;   position.poset
;           .px   x-position, starting with 0
;           .py   y-position, starting with 0
;           .xb   x=1 most left panel; x=2 most right panel
;           .yb   y=1 bottom panel; y=2 top panel
;   
; Example:
;   x=pos_mp(1,[5,12],[0.01,0.01],[0.1,0.1])
;
; HISTORY:
;
;   20120810  RX    introduced
;   20130422  RX    set different margin for each direction
;-
mg_lrbt=margin
omg_lrbt=omargin
if n_elements(mg_lrbt) eq 1 then mg_lrbt=replicate(mg_lrbt,2)
if n_elements(omg_lrbt) eq 1 then omg_lrbt=replicate(omg_lrbt,2)
if n_elements(mg_lrbt) eq 2 then mg_lrbt=[mg_lrbt,mg_lrbt]
if n_elements(omg_lrbt) eq 2 then omg_lrbt=[omg_lrbt,omg_lrbt]

px=ip-floor(ip/nxy[0])*nxy[0]
py=floor(ip/nxy[0])

dx=(1.0-omg_lrbt[0]-omg_lrbt[2])/nxy[0]
dy=(1.0-omg_lrbt[1]-omg_lrbt[3])/nxy[1]
sx=omg_lrbt[0]
sy=1.-omg_lrbt[3]
poset=[sx+dx*px+mg_lrbt[0], sy-dy*(py+1)+mg_lrbt[1]  , sx+dx*(px+1)-mg_lrbt[2]  , sy-dy*py-mg_lrbt[3] ] 

xb=0
yb=0

if px eq 0 then xb=1          ; left edge
if px eq nxy[0]-1 then xb=2   ; right edge
if py eq 0 then yb=1          ; top edge
if py eq nxy[1]-1 then yb=2   ; bottom edge

return,{position:poset,xb:xb,yb:yb,px:px,py:py}

END
