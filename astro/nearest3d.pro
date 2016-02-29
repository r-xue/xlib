FUNCTION NEAREST3D,points,catalog,neartag=neartag,verbose=verbose
;+
; PURPOSE:
;  This function returns the nth closest object to a given set of coordinates
;
; PROCEDURE:
;  Designed to scale roughly linearly with the catalog size, as opposed to more common
;  O(n^2) methods (e.g. computing every distance for each point and
;  sorting).
;
; CATEGORY:
;  catalog processing
;
; CALLING SEQUENCE:
;  result = nearestN(points, catalog, n, [dist = dist, /all])
;
; INPUTS:
;   points: The points to find the nth nearest neighbor for
;  catalog: A (3,m) array of m (x,y,z) points
;        n: Find the n'th closest neighbor. The closest point
;        corresponds to n = 0
;-

np=size(points,/d)
dr_nearby=findgen(np[1])*!values.f_nan
neartag=replicate(-1,np[1])
for i=0,np[1]-1 do begin
    
    dr= (points[0,i]-catalog[0,*])^2.0+$
        (points[1,i]-catalog[1,*])^2.0+$
        (points[2,i]-catalog[2,*])^2.0
    dr=dr^0.5
    dr=dr[where(dr ne 0,/null)]
    dr_nearby[i]=min(dr,dr_tag)
    neartag[i]=dr_tag
    if  keyword_set(verbose) then begin
        print,i,neartag[i],dr_nearby[i],$
            (points[0,i]-catalog[0,neartag[i]]),$
            (points[1,i]-catalog[1,neartag[i]]),$
            (points[2,i]-catalog[2,neartag[i]])
    endif
endfor

return,dr_nearby

END


PRO TEST_NEAREST3D

catalog=randomu(seed,[3,300])

dr=nearest3d(catalog,catalog)
print,dr

END