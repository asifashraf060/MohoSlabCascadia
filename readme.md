# Cascadia Moho Modeling

This repository contains MATLAB scripts and utility functions for constructing a coherent Moho structure of the subducting slab beneath the Cascadia Subduction Zone. By integrating seismic and geophysical datasets, these scripts produce a consistent 3D model of the Moho interface from offshore to onshore.

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

## Requirements

- **MATLAB** with access to functions typically found in the Mapping Toolbox (e.g., `geodetic2ecef`, `ecef2geodetic`).
- Scripts assume data are available in specific file formats (e.g., `.nc`, `.txt`, `.csv`, `.mat`). Adjust the file paths in `moho_buildup.m` according to your local file structure.