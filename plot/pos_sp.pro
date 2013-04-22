FUNCTION POS_SP,par_pos,sub_pos
;+
; return a position of a sub-panel using the parent panel postion
; and the normalized position parameter of the sub panel in the parent
; panel
;-

pos=[0.,0.,0.,0.]

pos[0]=par_pos[0]+(par_pos[2]-par_pos[0])*sub_pos[0]
pos[2]=par_pos[0]+(par_pos[2]-par_pos[0])*sub_pos[2]
pos[1]=par_pos[1]+(par_pos[3]-par_pos[1])*sub_pos[1]
pos[3]=par_pos[1]+(par_pos[3]-par_pos[1])*sub_pos[3]

return,pos

END