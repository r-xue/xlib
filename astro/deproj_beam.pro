PRO DEPROJ_BEAM, bmaj0, bmin0, bpa0, pa0, inc0, bmaj1,bmin1,bpa1
;+
; NAME:
;   DEPROJ_BEAM
;
; PURPOSE:
;   calculate the deprojected beam size after an image deprojection
;   process (e.g. using gal_flat.pro)
;
; INPUTS:
;
;   BMAJ            beam major before deprojection
;   BMIN            beam minor before deprojection
;   BPA0            beam position angle before deprojectoon (in degree, North up, East left)
;
;   PA0             Galaxy major axis position angle (in degree, North up, East left)
;   INC0            Galaxy inclination angle (in degree, North up, East left)
;
; OUTPUTS:
;   
;   BMAJ            beam major after deprojection
;   BMIN            beam minor after deprojection
;   BPA0            beam position angle after deprojectoon (in degree, counterclockwise from Y-axis)
;                   NOTE: for a deproject image, the true north might not be along Y-axis any more. 
;
; HISTORY:
;
;   20130405  RX  initial version
;-




pa=pa0/180.*!dpi
inc=inc0/180.*!dpi
bpa=bpa0/180.*!dpi
bmaj=bmaj0
bmin=bmin0

mxx=Cos(PA)^2 + Cos(inc)*Sin(PA)^2
mxy=Cos(PA)*Sin(PA) - Cos(inc)*Cos(PA)*Sin(PA)
myx=Cos(PA)*Sin(PA) - Cos(inc)*Cos(PA)*Sin(PA)
myy=Cos(inc)*Cos(PA)^2 + Sin(PA)^2


a=   (mxx^2*Cos(BPA)^2)/bmaj^2 + (myx^2*Cos(BPA)^2)/bmin^2 + $
       (2*mxx*myx*Cos(BPA)*Sin(BPA))/bmaj^2 - $
       (2*mxx*myx*Cos(BPA)*Sin(BPA))/bmin^2 + $
       (mxx^2*Sin(BPA)^2)/bmin^2 + (myx^2*Sin(BPA)^2)/bmaj^2

b=   (2*mxx*mxy*Cos(BPA)^2)/bmaj^2 + $
       (2*myx*myy*Cos(BPA)^2)/bmin^2 + $
       (2*mxy*myx*Cos(BPA)*Sin(BPA))/bmaj^2 - $
       (2*mxy*myx*Cos(BPA)*Sin(BPA))/bmin^2 + $
       (2*mxx*myy*Cos(BPA)*Sin(BPA))/bmaj^2 - $
       (2*mxx*myy*Cos(BPA)*Sin(BPA))/bmin^2 + $
       (2*mxx*mxy*Sin(BPA)^2)/bmin^2 + (2*myx*myy*Sin(BPA)^2)/bmaj^2
b=b/2.0

c=    (mxy^2*Cos(BPA)^2)/bmaj^2 + (myy^2*Cos(BPA)^2)/bmin^2 + $
       (2*mxy*myy*Cos(BPA)*Sin(BPA))/bmaj^2 - $
       (2*mxy*myy*Cos(BPA)*Sin(BPA))/bmin^2 + $
       (mxy^2*Sin(BPA)^2)/bmin^2 + (myy^2*Sin(BPA)^2)/bmaj^2

g=-1.0

bmaj1=((2*(g*b^2-a*c*g))/(b^2-a*c)/(((a-c)^2+4*b^2)^0.5-a-c))^0.5
bmin1=((2*(g*b^2-a*c*g))/(b^2-a*c)/(-((a-c)^2+4*b^2)^0.5-a-c))^0.5


if a lt c then bpa1=0.5*atan(2*b/(a-c))
if a gt c then bpa1=0.5*(!dpi+atan(2*b/(a-c)))
if a eq c then bpa1=0.0 

if bpa1 lt 0.0 then bpa1=bpa1+!dpi
bpa1=bpa1*180./!dpi


END


PRO TEST_ELLDEPROJ

bmaj=100.
bmin=100.*cos(80./180.*!dpi)
ELLDEPROJ,bmaj,bmin,45.,45.,0.0,bmaj1,bmin1,bpa1

print,bmaj1,bmin1,bpa1


END