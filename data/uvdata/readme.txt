The atomic and molecular hydrogen/deuterium data were collected from various sources:

* h2gui package by J. Tumlinson
line_atom.dat
line_h2.dat
line_hd.dat

* h2ools package by S. McCandliss:
http://www.pha.jhu.edu/~stephan/H2ools/h1h2data/

* Owens.f format: 
http://astro.uni-tuebingen.de/~reindl/OWENS/AtomicData.d

* Meudon PDR code format:
https://luthsvn.obspm.fr/PDRDEV/branches/1.6/data/UVdata

We adopted the valuess from Meudon, and here is a note for the format:
(also see PXDR_INITIAL.f90)

*** H2 data
uvh2b29.dat for Lyman Bands (B-X)    2nd electronic state <- 1st electronic state
uvh2c20.dat for Werner Bands (C-X)   3rd electronic state <- 1st electronic state

c1:     Index
c2:     1=Lyman;  2=Werner
c3:     lower vibrational level (nvl)
c4:     lower rotational level (njl)
c5:     upper vibrational level (nvu)
c6:     <upper rotational level>  -  <lower rotational level> (nju-njl)
c7:     f=oscillator strength
c8:     wavelength (Angstrom)
c9:     gamma=inverse radiative lifetime of upper level (s-1)
c10:    dissociation probability of upper level

The transition label can be created:
<bandname><c5>-<c3>R|P|Q<abs(c6)>
R: c6=1
Q: c6=0
P: c6=-1

g_nj
if (j mod 2) eq 0 then g_nj=2*nj+1
if (j mod 2) eq 1 then g_nj=3*(2*nj+1)

*** HD data
uvhd.data for Lyman/Werner Bands (B-X/C-X)

c1:     1=Lyman;  2=Werner
c2:     lower vibrational level (nvl)
c3:     lower rotational level (njl)
c4:     upper vibrational level (nvu)
c5:     <upper rotational level>  -  <lower rotational level> (nvu-nvl)
c6:     f=oscillator strength
c7:     wavelength (Angstrom)
c8:     dummy
c9:     gamma
c11:    dummy
c12:    *

The transition label can be created:
<bandname><c5>-<c3>R|P|Q<abs(c6)>
R: c6=1
Q: c6=0
P: c6=-1

g_nj
if (j mod 2) eq 0 then g_nj=2*nj+1
if (j mod 2) eq 1 then g_nj=3*(2*nj+1)

*** HI/DI data
uvh.dat for HI data
uvd.dat for DI data

c1:     <higher level> - <lower level,n=1>
c2:     f
c3:     wavelength (A)
c4:     gamma
c5:     dummy



