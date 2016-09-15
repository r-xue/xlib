
FUNCTION SAFE_CORRELATE_GPDF,center,sigma_high,sigma_low

    temp=fltarr(n_elements(center),2,1000)

    xnorm=randomn(seed,10000)
    tagp=where(xnorm gt 0.0)
    tagn=where(xnorm le 0.0)

    for i=0,n_elements(center)-1 do begin

        x=xnorm
        x[tagp]=xnorm[tagp]*sigma_high[i]
        x[tagn]=xnorm[tagn]*sigma_low[i]
        x=x+center[i]
        pdf_den=histogram(x,nbins=1000,location=locs)
        pdf_val=locs+abs(locs[1]-locs[0])*0.5

        temp[i,0,*]=pdf_val
        temp[i,1,*]=pdf_den*1.0/max(pdf_den*1.0)

    endfor

    return,temp

END
