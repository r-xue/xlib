FUNCTION READ_ASCIIX,file,refresh=refresh

rootname=cgrootname(file,dir=dir,ext=ext)
if  ~file_test(dir+'/'+rootname+'.template') or keyword_set(refresh) then begin
    template=ascii_template(file)
    save,template,filename=dir+'/'+rootname+'.template'
endif

restore,filename=dir+'/'+rootname+'.template'
struct=read_ascii(file,template=template)

return,struct
END

PRO TEST_READ_ASCIIX

st=read_asciix('all_DEIMOS_2015apr17.redshifts_v1_coords')
print,tag_names(st)
END