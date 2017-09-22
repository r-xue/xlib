### IDL/Python-xlib

This repository contains various routines written in IDL/Python for my astronomy research projects. Most rocedures/functions in this collection were written as library codes for "general" purposes, but motivated by specific projects. Some highlights include:

* astro/calc_igmtau.pro

* astro/calc_qb.pro

* astro/deproj_beam.pro

* astro/deproj_im.pro

* astro/fxreadx.pro

* astro/get_filter.pro

* astro/map_fits.pro

* astro/map_boundary.pro

* astro/map_fits.pro

* astro/mk_hd.pro

* astro/radprofile_analyzer.pro

* astro/radprofile_grow.pro

* astro/query_refobj.pro

* htau/

* images/check_point.pro

* images/im_circularize.pro

* images/ims_sexfind.pro

* images/make_charts.pro

* images/match_astro.pro

* images/psfex_analyzer.pro

* misc/pineps.pro

* misc/read_table.pro


Some original IDL-xlib codes I wrote have been moved into an co-developed independent IDL package for generating moments maps from 3D radio spectral line cubes:

    https://github.com/tonywong94/idl_mommaps

I retired them from IDL-xlib to avoid duplications. Some of those useful IDL routines includes:

* idl_mommaps/smooth3d.pro

* idl_mommaps/pltmom_pv.pro

* idl_mommaps/pltmom.pro

* idl_mommaps/maskmoment_pv.pro

* idl_mommaps/hrot3d.pro

* idl_mommaps/err_cube.pro

* idl_mommaps/gkernel.pro


There is no guarantee for 100% accuracy / correct. But any feedback or correction is welcome. I tend to borrow pre-existing library codes from other people rather than reinventing the wheel, so the collection here represents the optimized version of pre-existing codes or something missed out by other mature IDL libraries. This increases the complexity of code dependency, but reduce duplicated coding works. The IDL libraries I borrowed (from other hard-working people!) are listed in the folder /borrow/README.md .


### Install


Download the update-to-date version of this library using the following command:

    git clone http://github.com/r-xue/xlib.git

Add the library path to your IDL environment.

If a code complains something (functions/procedures) missing, most likely I have borrowed some library codes not in your IDL setup. Please check README.md in /borrow/ for their information. Also different IDL libraries may have duplicated code pieces in various versions (same file names!). This creates a common headache for IDL users. I recommend to have a look at the /system/xstartup.pro for prioritizing different libraries. The strategy I prefer is putting the bleeding-edge version of "low-level" libraries (eg. IDLAstro/idl-coyote) at the beginning of your IDL_path.
