FUNCTION OH2Z, OH
;+
; convert metallicity in [log(O/H)+12] to Z' (defined in KMT09)
; log Z′ = [log(O/H) + 12] − 8.76.
;-
;Asplund et al .2009 solar 8.69
;Asplund et al .2009 solar neigbourhood 8.76
return, 10.0^(oh-8.76)
END
