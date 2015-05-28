PRO TEST_PROFILER,CMD

Profiler, /RESET

Profiler, /SYSTEM & Profiler
void=EXECUTE(CMD)

print,replicate('>',60)
Profiler, /REPORT,/CODE_COVERAGE
print,replicate('>',60)

Profiler, /RESET

END