PRO COMA_KSPLOT

; NO DEPROJECTION
restore,'coma0_ms.dat',/verbose
ind=where(all_ms.galno eq all_ms.galno and all_ms.sig_sfr eq all_ms.sig_sfr and all_ms.nh2 gt 3.0*all_ms.nh2e)

galno=all_ms[ind].galno
nh2=all_ms[ind].nh2
nh2e=all_ms[ind].nh2e
sig_sfr=all_ms[ind].sig_sfr

res=all_ms[ind].res
inc=all_ms[ind].inc
xoffset=all_ms[ind].xoffset
yoffset=all_ms[ind].yoffset

set_plot, 'ps'
device, filename='coma_h2sfr.eps', $
  bits_per_pixel=8,/encapsulated,$
  xsize=8,ysize=5,/inches,/col,xoffset=0,yoffset=0,/cmyk

!p.thick=1.7
!x.thick = 1.7
!y.thick = 1.7
!z.thick = 1.7
!p.charsize=1.0
!p.charthick=1.7

xtick_format='logticks_exp'
ytick_format='logticks_exp'

xmin=1.e-1
xmax=1.e3
ymin=1.e-6
ymax=1.e-2

loadct,13,ncolors=256

plot, [0],[0], $
  psym=3,symsize=0.2,$
  xstyle=1, ystyle=1, $
  yrange=[ymin,ymax],xrange=[xmin,xmax],$
  /noe,$
  xtickformat=xtick_format,$
  ytickformat=ytick_format,$
  /xlog,/ylog,position=[0.09,0.1,0.51,0.76],$
  ytitle=textoidl('\Sigma_{SFR} [M!d!9n!3!n yr!u-1!n kpc!u-2!n]'),$
  xtitle=textoidl('\Sigma_{H2} [M!d!9n!3!n pc!u-2!n]')

for i=0,n_elements(nh2)-1 do begin

  if galno[i] eq 'cg159102' then pcolor=0
  if galno[i] eq 'cg160058' then pcolor=30
  if galno[i] eq 'cg160073' then pcolor=60
  if galno[i] eq 'cg160088' then pcolor=90
  if galno[i] eq 'cg160095' then pcolor=150
  if galno[i] eq 'cg160098' then pcolor=180
  if galno[i] eq 'cg160252' then pcolor=240
  if galno[i] eq 'cg160260' then pcolor=255

  symcode=16
  oplot,[nh2[i]],[sig_sfr[i]],psym=cgsymcat(symcode),color=pcolor,symsize=0.4

endfor

xyouts,0.11,0.70,'cgcg 159102',color=0,/normal
xyouts,0.11,0.66,'cgcg 160058',color=30,/normal
xyouts,0.11,0.62,'cgcg 160073',color=60,/normal
xyouts,0.11,0.58,'cgcg 160088',color=90,/normal
xyouts,0.11,0.54,'cgcg 160095',color=150,/normal
xyouts,0.11,0.50,'cgcg 160098',color=180,/normal
xyouts,0.11,0.46,'cgcg 160252',color=240,/normal
xyouts,0.11,0.42,'cgcg 160260',color=255,/normal

; AFTER DEPROJECTION
restore,'coma_ms.dat',/verbose
ind=where(all_ms.galno eq all_ms.galno and all_ms.sig_sfr eq all_ms.sig_sfr and all_ms.nh2 gt 3.0*all_ms.nh2e)

galno=all_ms[ind].galno
nh2=all_ms[ind].nh2
nh2e=all_ms[ind].nh2e
sig_sfr=all_ms[ind].sig_sfr

res=all_ms[ind].res
inc=all_ms[ind].inc
xoffset=all_ms[ind].xoffset
yoffset=all_ms[ind].yoffset

plot, [0],[0], $
  psym=3,symsize=0.2,$
  xstyle=1, ystyle=1, $
  yrange=[ymin,ymax],xrange=[xmin,xmax],$
  /noe,$
  xtickformat=xtick_format,$
  ytickformat='notickname',$
  /xlog,/ylog,position=[0.55,0.1,0.97,0.76],$
  ytitle='',$
  xtitle=textoidl('Deprojected \Sigma_{H2} [M!d!9n!3!n pc!u-2!n]')

for i=0,n_elements(nh2)-1 do begin

  if galno[i] eq 'cg159102' then pcolor=0
  if galno[i] eq 'cg160058' then pcolor=30
  if galno[i] eq 'cg160073' then pcolor=60
  if galno[i] eq 'cg160088' then pcolor=90
  if galno[i] eq 'cg160095' then pcolor=150
  if galno[i] eq 'cg160098' then pcolor=180
  if galno[i] eq 'cg160252' then pcolor=240
  if galno[i] eq 'cg160260' then pcolor=255

  symcode=16
  oplot,[nh2[i]],[sig_sfr[i]],psym=cgsymcat(symcode),color=pcolor,symsize=0.4

endfor

device, /close
set_plot,'X'
  
End


