FUNCTION OH2Z, OH
;+
; convert metallicity in [log(O/H)+12] to Z' (defined in KMT09)
; log Z′ = [log(O/H) + 12] − 8.76.
;-

return, 10.0^(oh-8.76)
end