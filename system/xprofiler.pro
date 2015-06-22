PRO XPROFILER,CMD,noreport=noreport

Profiler, /RESET
Profiler, /SYSTEM & Profiler

tmp1=memory(/current)

print,replicate('>',30)
tn=tic()
void=EXECUTE(CMD)
print,replicate('<',30)
toc,tn
print,replicate('>',30)

tmp2=memory(/highwater)

if  ~keyword_set(noreport) then begin
    profiler, /REPORT,/CODE_COVERAGE
    print,replicate('>',30)
    profiler, /RESET
endif


print, ''
print, 'Memory Usage START: ',(tmp1)*9.53674316e-7, 'MB'
print, 'Memory Usage PEAK:  ',(tmp2)*9.53674316e-7, 'MB'
print, 'Memory Usage DIFF:  ',(tmp2-tmp1)*9.53674316e-7, 'MB'
print, ''



END