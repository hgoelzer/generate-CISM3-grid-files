# generate-CISM3-grid-files

Matlab scripts to generate grid description files used for cdo regridding.

Based on work by Jeremy Fyke, Andy Bliss and others.

CISM has thickness in the grid g1 and velocity on grid g0

## Main scripts for AIS and GrIS

```CISM3_g1_GrIS_multigrid_generater_nc.m```

```CISM3_g0_GrIS_multigrid_generater_nc.m```

```CISM3_g1_AIS_multigrid_generater_nc.m```

```CISM3_g0_AIS_multigrid_generater_nc.m```

Will generate a number of grid description files for use with the cdo remap command (https://code.mpimet.mpg.de/projects/cdo).

## Utilities

```polarstereo_inv.m```

```generate_CDO_files_g1_nc.m```

```generate_CDO_files_g0_nc.m```

```wnc.m```

## Produce area fraction files for grid g1

```calcphilambda_epsg3031.m```

```calcphilambda_epsg3413.m```

The resulting 'af' files can be used to compensate the grid projection error. Multiply 2D gridded variables with 'af' before spatial integration, summation or averaging.
