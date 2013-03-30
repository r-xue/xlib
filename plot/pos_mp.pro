FUNCTION POS_MP, ip, nxy,margin, omargin
;+
; NAME:
;   POS_MP
;
; PURPOSE:
;   calculate the normalized posistion vector fro muti-panel plotting
;
; INPUTS:
;   ip      -- which panel (in a left->right/top->bottom sequence)
;   nxy     -- number of columns/rows in the plot
;   margin  -- margin for each panel (scaler or vector of two)
;   omargin -- omargin for each panel (scaler or vector of two)
;
; OUTPUTS:
;   posisition vector
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
px=ip-ip/nxy[0]*nxy[0]
py=ip/nxy[0]
dx=(1.0-2.*omargin[0])/nxy[0]
dy=(1.0-2.*omargin[1])/nxy[1]
sx=omargin[0]
sy=1.-omargin[1]
poset=[sx+dx*px+margin[0], sy-dy*(py+1)+margin[1]  , sx+dx*(px+1)-margin[0]  , sy-dy*py-margin[1] ] 

if px eq 0 then px=1          ; left edge
if px eq nxy[0]-1 then px=2   ; right edge
if py eq 0 then py=1          ; top edge
if py eq nxy[1]-1 then py=2   ; bottom edge

return,{position:poset,xb:px,yb:py}

END