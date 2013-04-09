FUNCTION POS_MP, ip, nxy,margin, omargin
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
;   margin  -- margin for each panel (scaler or vector of two) [in normal]
;   omargin -- overall margin for multi-panel plots (scaler or vector of two) [in normal]
;
; OUTPUTS:
;   position.poset
;           .px   x-position, starting with 0
;           .py   y-position, starting with 0
;   
; Example:
;   x=pos_mp(1,[5,12],[0.01,0.01],[0.1,0.1])
;
; HISTORY:
;
;   20120810  RX    initial version
;-

if n_elements(margin) eq 1 then margin=replicate(margin,2)
if n_elements(omargin) eq 1 then margin=replicate(omargin,2)
px=ip-floor(ip/nxy[0])*nxy[0]
py=floor(ip/nxy[0])

dx=(1.0-2.*omargin[0])/nxy[0]
dy=(1.0-2.*omargin[1])/nxy[1]
sx=omargin[0]
sy=1.-omargin[1]
poset=[sx+dx*px+margin[0], sy-dy*(py+1)+margin[1]  , sx+dx*(px+1)-margin[0]  , sy-dy*py-margin[1] ] 

xb=0
yb=0

if px eq 0 then xb=1          ; left edge
if px eq nxy[0]-1 then xb=2   ; right edge
if py eq 0 then yb=1          ; top edge
if py eq nxy[1]-1 then yb=2   ; bottom edge

return,{position:poset,xb:xb,yb:yb,px:px,py:py}

END