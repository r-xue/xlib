FUNCTION READ_ASCIIX,file

template=ascii_template(file)
rootname=cgrootname(file,dir=dir,ext=ext)
save,template,filename=dir+'/'+rootname+'.template'
struct=read_ascii(file,template=template)

return,struct
END

PRO TEST_READ_ASCIIX

st=read_asciix('all_DEIMOS_2015apr17.redshifts_v1_coords')
print,tag_names(st)
END