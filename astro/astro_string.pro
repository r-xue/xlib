FUNCTION ASTRO_STRING
;+
;shortcut for print out strings: more coming
;-
as={$
ti_i8:'!8I!3('+textoidl("8\mum")+') [MJy sr!u-1!n]',$
ti_nh2:'!8N!3(H!d2!n) [cm!u-2!n]',$
ti_nhi:'!8N!3(H!dI!n) [cm!u-2!n]',$
ti_inuv:'!8I!3('+textoidl("NUV")+') [MJy sr!u-1!n]',$
ti_ifuv:'!8I!3('+textoidl("FUV")+') [MJy sr!u-1!n]',$
msunpc2:'!6M!d!9n!6!n pc!u-2!n',$
msunyr:'!6M!d!9n!6!n yr!u-1!n',$
msunyrkpc2:'!6M!d!9n!6!n yr!u-1!n kpc!u-2!n'}

return,as
END

PRO TEST_ASTRO_STRING
;+
; print out examples
;-
set_plot, 'ps'
device, filename=ProgramRootDir()+'/astro_string.eps', $
  bits_per_pixel=8,/encapsulated,$
  xsize=8.5,ysize=11,/inches,/col,xoffset=0,yoffset=0,/cmyk

as=astro_string()
tagnames=TAG_NAMES(as)

for i=0,n_elements(tagnames)-1 do begin
  pos=pos_mp(i,[5,10],[0.01,0.01],[0.1,0.1])
  pos=[pos.position[0]+pos.position[2],pos.position[1]+pos.position[3]]/2.0
  xyouts,pos[0],pos[1],as.(i),/normal, ALIGNMENT=0.5
endfor

device, /close
set_plot,'X'

END