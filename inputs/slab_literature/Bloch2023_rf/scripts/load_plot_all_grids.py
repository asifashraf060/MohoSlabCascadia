#!/usr/bin/env python3

"""
Sample script to load and plot all model grids of the Cascadia forearc slab
model.

Creates the files:
    grids_masked.pdf
    grids_unmasked.pdf

Depends on xarray and matplotlib

Wasja Bloch, Sep 2023
"""

import os
import os.path as path
import xarray as xr
import matplotlib.pyplot as mp

# Current working directory
cwd = os.getcwd()

# Directories with unmasked and masked grids
for dir in ["grids_unmasked", "grids_masked"]:
    
    # Full path of data directory
    fdir = path.join(os.path.dirname(cwd), dir)
    
    # File names with full paths
    fns = [path.join(fdir, fn) for fn in os.listdir(fdir)]

    # One figure per folder. Adjust number of rows by number of files
    nrow = len(fns) // 3
    fig, axs = mp.subplots(nrow, 3, tight_layout=True, figsize=(7, nrow*3))
    fig.suptitle(f"Folder: {dir}")

    for ax, fn in zip(axs.flat, fns):
        
        # Load data into xarray
        da = xr.open_dataarray(fn)

        # Use filename as title
        ax.set_title(path.basename(fn))

        # Plot in geographic coordinates
        ax.imshow(
            da,
            origin="lower",
            aspect = "auto",
            extent=(da.lon.min(), da.lon.max(), da.lat.min(), da.lat.max()),
        )

    # Save figures
    fig.savefig(f"{dir}.pdf")
