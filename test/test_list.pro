PRO TEST_LIST

n=100000000

tmp1=memory(/current)
print, 'Memory Usage: ', tmp1*9.53674316e-7, 'MB'
base1=findgen(n,20)
tmp2=memory(/current)
print, 'Memory Usage: ', (tmp2-tmp1)*9.53674316e-7, 'MB'
xx=findgen(n)
base2=list()
for j=0,19 do begin
    base2.add,xx
endfor
tmp3=memory(/current)
print, 'Memory Usage: ', (tmp3-tmp2)*9.53674316e-7, 'MB'

x=findgen(n)

T = SYSTIME(1)
base1=[[base1],[x]]
PRINT, '>> total time:   ',strtrim(string(round(SYSTIME(1)-T)),2), 'S'
T = SYSTIME(1)
base2.add,x
PRINT, '>> total time:   ',strtrim(string(round(SYSTIME(1)-T)),2), 'S'

END