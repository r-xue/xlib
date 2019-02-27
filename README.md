### IDL-xlib

This repository contains various routines written in IDL for my astronomy research projects. Most rocedures/functions in this collection were written as library codes for "general" purposes, but motivated by specific projects.

###### One-line descriptions of some procedures/functions (still under construction):


Astrophysics Models

*   [calc_nc.py]()
    calculate the critical density of common ISM molecular/atomic species  
*   [calc_igmtau.pro]()
    compute a model IGM transmission function

Astronomical Utilities

*   [calc_qb.pro]()
    calculate the effective bandwidth (narrow-line) and gain (continuum) of an imaging filter
*   [deproj_beam.pro]()
    calculate the beam shape of a deprojected galaxy image.
*   [deproj_im.pro]()
    deproject a galaxy image
*   [fxreadx.pro]()
    a fast and memory-saving routine to extract sub-regions from a large 2D image.
*   [get_filter.pro]()
    query astronomical filter properties from a built-in database
*   [map_fits.pro]()
    display fits images with an arbitrary projection
*   [map_boundary.pro]()
    display the imaging boundary by looking up missing data
*   [mk_hd.pro]()
    make a reference image header
*   [query_refobj.pro]()
    query reference objects for astrometry correction
*   [check_point.pro]()
    validate a position in an astronomical image
*   [match_astro.pro]()
    derive astrometry solution with high-order distortions
*   [psfex_analyzer.pro]()
    an IDL wrapper of PSFEX, for analyzing PSF in optical images
*   [smooth3d.pro]()
    convolve a cube or image to a desired resolution
*   [pltmom_pv.pro]()
    plot PV maps
*   [pltmom.pro]()
    plot moment-0/1 maps
*   [maskmoment_pv.pro]()
    make moment-0 maps in the position-velocity dimension
*   [hrot3d.pro]()
    rotate 3D cubes
*   [err_cube.pro]()
    derive an error cube based on a noise pattern model
*   [gkernel.pro]()
    derive the kernel for convolving a gaussian beam to a desired shape

MISC

*   [amoeba_sa.py]()
    a Python implementation of the Nelder-Mead algorithm for function minimization
*   [pineps.pro]()
    combine eps/ps files into multi-page PDF.
*   [read_table.pro]()
    read tables fro google docs, excel, etc.

<!---
There is no guarantee for 100% accuracy / correct. But any feedback or correction is welcome. I tend to borrow pre-existing library codes from other people rather than reinventing the wheel, so the collection here represents the optimized version of pre-existing codes or something missed out by other mature IDL libraries. This increases the complexity of code dependency, but reduce duplicated coding works. The IDL libraries I borrowed (from other hard-working people!) are listed in the folder /borrow/README.md .
--->

### Install


Download the update-to-date version of this library using the following command:

    git clone http://github.com/r-xue/xlib.git

Add the library path to your IDL environment.

<!---
If a code complains something (functions/procedures) missing, most likely I have borrowed some library codes not in your IDL setup. Please check README.md in /borrow/ for their information. Also different IDL libraries may have duplicated code pieces in various versions (same file names!). This creates a common headache for IDL users. I recommend to have a look at the /system/xstartup.pro for prioritizing different libraries. The strategy I prefer is putting the bleeding-edge version of "low-level" libraries (eg. IDLAstro/idl-coyote) at the beginning of your IDL_path.
--->
