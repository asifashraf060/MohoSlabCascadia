# Cascadia Moho Modeling

This repository contains MATLAB scripts and utility functions for constructing a coherent and unified Moho structure of the subducting slab beneath the Cascadia Subduction Zone. By integrating seismic and geophysical datasets, and applying smoothing technqiues these scripts produce a consistent 3D model of the Moho interface from offshore to onshore.

## Overview

- **`moho_buildup.m`**  
  The main driver script that:
  - Loads input surfaces and geometry.
  - Interpolates and smooths various sub-surface horizons (e.g., from Carbotte, Bloch, McCrory, Slab2.0, Gorda Ridge data).
  - Merges them into a coherent representation of the Moho.

- **Utility Scripts**:
  - **`map2xy.m`**: Converts longitude/latitude (or easting/northing) to local Cartesian coordinates, taking into account rotation and ellipsoid parameters from `srGeometry`.
  - **`xy2map.m`**: Inverse transformation, converting local Cartesian coordinates back to longitude/latitude (or easting/northing).
  - **`surfNormal.m`**: Offsets a surface along the local normal by a specified thickness to produce parallel surfaces (e.g., offsetting an interface by 6 km to emulate Moho depth).
  - **`mergeSlabData.m`**: Merges multiple slab data models into a unified structure in the same grid spacing

## Requirements

- **MATLAB** with access to functions typically found in the Mapping Toolbox (e.g., `geodetic2ecef`, `ecef2geodetic`).
- Scripts assume data are available in specific file formats (e.g., `.nc`, `.txt`, `.csv`, `.mat`).
- Toolboxes:
  - *Statistics and Machine Learning Toolbox* (for `fitrgp`).
  - *Curve Fitting Toolbox* (for `fit` and `fittype`).
  - *Mapping Toolbox* (for coordinate transformations, if custom functions rely on it).
- NetCDF file support (for reading `.grd` files via `ncread`).

## Usage
1. Clone the repository and ensure the directory structure matches above.
2. Open MATLAB and navigate to the script directory.
3. Run `moho_buildup.m`. The script will:
   - Load input data.
   - Process and merge models.
   - Save outputs to `outputs/models/` and plots to `outputs/plots/`.

## Outputs
- **Models**: Six merged slab interfaces (e.g., `casiePF_bloch.mat`, `casieGP_slab2.mat`).
- **Plots**: Contour maps (JPEG format) visualizing each merged model.

## References
- **CASIE21**: Carbotte et al. (2024)
- **Bloch et al. (2023)**: Crustal interface measurements
- **McCrory (2012)**: Juan de Fuca slab model
- **Hayes et al. (2018)**: Slab2.0 dataset
- **Gorda Ridge**: GMRTv4.3 elevation data

---

**Author**: Asif Ashraf(aashraf@uoregon.edu)
**Date**: February 2025  