FUNCTION PADDING,im,edge

    ; if edge>0 pad data with some zero-value pixels in each dimension
    ; if edge<0 remove the padding pixels
    
    if  edge gt 0 then begin
        struct=size(im, /STRUCTURE)
        imdims=size(im)
        tmp=MAKE_ARRAY(struct.dimensions[0:imdims[0]-1]+2*edge, TYPE=struct.TYPE)
        if imdims[0] eq 1 then tmp[edge:(edge+imdims[1]-1)]=im
        if imdims[0] eq 2 then tmp[edge:(edge+imdims[1]-1),edge:(edge+imdims[2]-1)]=im
        if imdims[0] eq 3 then tmp[edge:(edge+imdims[1]-1),edge:(edge+imdims[2]-1),edge:(edge+imdims[3]-1)]=im
        if imdims[0] eq 4 then tmp[edge:(edge+imdims[1]-1),edge:(edge+imdims[2]-1),edge:(edge+imdims[3]-1),edge:(edge+imdims[4]-1)]=im
    endif
    if  edge lt 0 then begin
        imdims=size(im)
        if imdims[0] eq 1 then tmp=im[-edge:(edge+imdims[1]-1)]
        if imdims[0] eq 2 then tmp=im[-edge:(edge+imdims[1]-1),-edge:(edge+imdims[2]-1)]
        if imdims[0] eq 3 then tmp=im[-edge:(edge+imdims[1]-1),-edge:(edge+imdims[2]-1),-edge:(edge+imdims[3]-1)]
        if imdims[0] eq 4 then tmp=im[-edge:(edge+imdims[1]-1),-edge:(edge+imdims[2]-1),-edge:(edge+imdims[3]-1),-edge:(edge+imdims[4]-1)]
    endif
    if  edge eq 0 then tmp=im
    
    return,tmp
END