;@htau_grid_script
;+
;   this demostrate how to generate the htau templates and use it.
;-

;   BUILD DATABASE/GRID
.com htau_data_rd
.com htau_line_calc
.com htau_grid_build
.com htau_grid_rd
.com htau_grid_mkline
.com htau_grid_plot

htau_data_rd            ;   save the uvline database into htau_databse.xdr
htau_grid_build         ;   use htau_line_calc.pro to build the HTAU templates into htau_templates.xdr
htau_grid_rd            ;   read the database/templates into the memory
htau_grid_plot          ;   test plot
htau_grid_plot_h2_slow  ;   test plot







