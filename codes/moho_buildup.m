%% JOIN TWO SLAB MODEL

close all, clc, clear

scriptDir = fileparts(mfilename('fullpath'));
cd(scriptDir)
cd ..

% load geometry
load([pwd, '/inputs/matlab_structures/geometry/OR2012_srGeometry.mat'])

% load interfaces
% CASIE21 basement
the_CSslab = [pwd, '/inputs/slab_literature/Carbotte2024_CASIE21/Cascadia_CASIE21/Casie21-R2T-TOC_medflt-surface-mask.grd'];
% bloch moho
the_Bloch  = [pwd, '/inputs/slab_literature/Bloch2023_rf/control-points.txt'];
% McCrory slab
the_McCr   = [pwd, '/inputs/slab_literature/McCrory2012_JdF/MCslab_cut_allSlab.txt'];
% Slab2.0
the_slab2  = [pwd, '/inputs/slab_literature/Hayes2018_slab2/cas_slab2_dep_02.24.18.csv'];
% gorda ridge elevation
the_GR      = [pwd, '/inputs/gorda_ridge_elevation/GMRTv4_3_0_20250225topo_GR.asc'];

cd(scriptDir)

%% ======= %%
%% CALCULATION %%

% CASIE21 slab
disp("Working on CASIE21 basement ...")

% LOAD
ln_cs = ncread(the_CSslab,'lon');
lt_cs = ncread(the_CSslab, 'lat');
z_cs  = ncread(the_CSslab, 'z');

% lon lat GRID
[lonG, latG] = meshgrid(ln_cs, lt_cs);
% convert to x and y
[Xcs, Ycs] = map2xy(lonG, latG, srGeometry);
% convert depth into km
z_cs = (-1*(z_cs./1000))'; 
z_cs_Sub = z_cs - 6;
% Make an interface parallel to the original interface
[Xnormal, Ynormal, Znormal] = surfNormal(Xcs, Ycs, z_cs, -6);
[LONnormal, LATnormal] = xy2map(Xnormal, Ynormal, srGeometry);

%%% --- Fitting a smooth interface through the points --- %%%

% 1. POLYNOMAIL FIT
ft = fittype('poly45');
x = Xnormal(:); y = Ynormal(:); z = Znormal(:); % vector conversion for function input
goodIdx = ~isnan(x) & ~isnan(y) & ~isnan(z);    % only interpolate for non-nans
x = x(goodIdx);
y = y(goodIdx);
z = z(goodIdx);
[fitresult, gof] = fit([x, y], z, ft);
% Create a finer grid for visualization:
xFit = linspace(min(x), max(x), 2000);
yFit = linspace(min(y), max(y), 2000);
[Xpf, Ypf] = meshgrid(xFit, yFit);
% Evaluate the fit on the grid:
Zpf = feval(fitresult, Xpf, Ypf);
Zpf_interp = griddata(Xpf, Ypf, Zpf, Xcs, Ycs);
Zpf_interp(isnan(z_cs)) = nan;

% 2. GAUSSIAN PROCESS REGRESSION
goodIdx = [1:15:length(x)];                       % coarser sampling (crs)
x_crs   = x(goodIdx);
y_crs   = y(goodIdx); 
z_crs   = z(goodIdx); 
[x_y]   = [x_crs, y_crs];
gprMdl  = fitrgp(x_y, z_crs(:), ...
                'KernelFunction','squaredexponential', ...
                'Sigma',0.2, ...                  % initial guess for noise
                'BasisFunction','constant', ...
                'FitMethod','exact', ...
                'Standardize',true, ...
                'Beta',0);
                %'NoiseVariance', noiseVar);
[xG,yG] = meshgrid(x_crs, y_crs);
Gxy     = [xG(:), yG(:)];
[ZpredCS, Zstd] = predict(gprMdl, Gxy);

ZpredCS = reshape(ZpredCS, size(xG));

ZpredCS_interp = griddata(xG, yG, ZpredCS, Xcs, Ycs);
ZpredCS_interp(isnan(z_cs)) = nan;


%% Extent the moho information to most southern point
lat_ext_extract = 42.1542;
lat_ext_bound   = [40.5 41.8];
lon_ext_bound   = [-126.192 -124.556];

% lon and lat arrays to extract z values 
lon_ext_arr       = [min(lon_ext_bound):.01:max(lon_ext_bound)];
lat_ext_arr       = [min(lat_ext_bound):.01:max(lat_ext_bound)];
lat_ext_extrc_arr = zeros(1, length(lon_ext_arr)) + lat_ext_extract;

% extract z values from polynomial fit
lnpf = lonG(:); ltpf = latG(:); zpf = Zpf_interp(:);
valid = ~isnan(lnpf) & ~isnan(ltpf) & ~isnan(zpf);
lnpfG = lnpf(valid); ltpfG = ltpf(valid); znpfG = zpf(valid);
z_pf_ext = (griddata(lnpfG, ltpfG, znpfG, lon_ext_arr, lat_ext_extrc_arr))';

z_pf_ext_gr = repmat(z_pf_ext,1, length(lat_ext_arr))';
[lon_ext_g, lat_ext_g] = meshgrid(lon_ext_arr, lat_ext_arr);


%% Add the gorda ridge portion
disp('Working on Gorda ridge part ...')

[data, metadata] = readgeoraster(the_GR, 'OutputType', 'double');

xmin = metadata.XWorldLimits(1);
xmax = metadata.XWorldLimits(2);
ymin = metadata.YWorldLimits(1);
ymax = metadata.YWorldLimits(2);
xinc = metadata.CellExtentInWorldX;
yinc = metadata.CellExtentInWorldY;

data(isnan(data)) = 0;

data = (flipud((data))./1000)- 6;

data_filt = imgaussfilt(data, 10);

xg     = [xmin:xinc:xmax];
yg     = [ymin:yinc:ymax];
xg_crs = [xmin:.02:xmax];
yg_crs = [ymin:.02:ymax];

[X_gr, Y_gr]         = meshgrid(xg(1:(end-1)), yg(1:(end-1)));
[X_gr_crs, Y_gr_crs] = meshgrid(xg_crs, yg_crs);

data_crs = griddata(X_gr, Y_gr, data, X_gr_crs, Y_gr_crs);
data_crs_filt = imgaussfilt(data_crs, 10);

%% ====== %% 
%% Bloch slab
disp('Working on Bloch slab ...')

% LOAD
tb = readtable(the_Bloch);
ln_bl     = tb.longitude;
lt_bl     = tb.latitude;
z_bl      = tb.depth_m;
uc_bl     = tb.uncert_m;
ql_bl     = tb.qual_m;

idx_del   = contains(ql_bl, [{'C'} {'X'}]); % Quality control

% delete the bad quality measurements
ln_bl = ln_bl(~idx_del); lt_bl = lt_bl(~idx_del);
z_bl  = z_bl(~idx_del);  uc_bl = uc_bl(~idx_del);

% SCATTERED INTERPOLATION
[ln_bl_g, lt_bl_g] = meshgrid(ln_bl, lt_bl);
F = scatteredInterpolant(ln_bl, lt_bl, z_bl);
z_bl_g = F(ln_bl_g, lt_bl_g);

% GAUSSIAN PROCESS REGRESSION
lon_lat  = [ln_bl(:), lt_bl(:)];
noiseVar = uc_bl.^2;
gprMdl = fitrgp(lon_lat, z_bl, ...
                'KernelFunction','squaredexponential', ...
                'Sigma',0.2, ...                  % initial guess for noise
                'BasisFunction','constant', ...
                'FitMethod','exact', ...
                'Standardize',true, ...
                'Beta',0);
                %'NoiseVariance', noiseVar);

gridLonLat    = [ln_bl_g(:), lt_bl_g(:)];
[Zpred_bl, Zstd] = predict(gprMdl, gridLonLat);

Zpred_bl = reshape(Zpred_bl, size(ln_bl_g));

% MASK WITH NANS
shp = alphaShape(ln_bl, lt_bl);
insideIdx  = inShape(shp, ln_bl_g(:), lt_bl_g(:));
insideIdx  = reshape(insideIdx, size(ln_bl_g));
Zpred_bl(~insideIdx) = NaN;

blch = -1.*(Zpred_bl);

%% ======= %%
%% McCrory slab
disp('Working on McCrory slab ...')

% LOAD
tb = readtable(the_McCr);
ln_mc     = tb.Var1;
lt_mc     = tb.Var2;
z_mc      = tb.Var3;

idx_dlt = find(z_mc>-28);

% custom deleting
ln_mc(idx_dlt) = [];
lt_mc(idx_dlt) = [];
z_mc(idx_dlt)  = [];

% rate of downsampling
n_dwn = 2;
ln_mc = ln_mc(1:n_dwn:end);   lt_mc = lt_mc(1:n_dwn:end); z_mc = z_mc(1:n_dwn:end);

[ln_mc_g, lt_mc_g] = meshgrid(ln_mc, lt_mc);

lon_lat  = [ln_mc(:), lt_mc(:)];
gprMcC = fitrgp(lon_lat, z_mc, ...
                'KernelFunction','squaredexponential', ...
                'Sigma',0.2, ...                  % initial guess for noise
                'BasisFunction','constant', ...
                'FitMethod','exact', ...
                'Standardize',true, ...
                'Beta',0);
                %'NoiseVariance', noiseVar);
gridLonLat        = [ln_mc_g(:), lt_mc_g(:)];
[Zpred_McC, Zstd] = predict(gprMcC, gridLonLat);
Zpred_McC         = reshape(Zpred_McC, size(ln_mc_g));
[xg_mc, yg_mc]    = map2xy(ln_mc_g, lt_mc_g, srGeometry);
[Xnormal_mc, Ynormal_mc, Znormal_mc] = surfNormal(xg_mc, yg_mc, Zpred_McC, -6);
[LONnormal_mc, LATnormal_mc]         = xy2map(Xnormal_mc, Ynormal_mc, srGeometry);
Znormal_mc_interp                    = griddata(LONnormal_mc, LATnormal_mc, ...
                                                Znormal_mc, ln_mc_g, lt_mc_g);
% MASK WITH NANS
shp        = alphaShape(ln_mc, lt_mc);
insideIdx  = inShape(shp, ln_mc_g(:), lt_mc_g(:));
insideIdx  = reshape(insideIdx, size(ln_mc_g));
Znormal_mc_interp(~insideIdx) = NaN;

%% ======= %%
%% Slab 2.0
disp('Working on Slab2.0 ...')

% LOAD
tb = readtable(the_slab2, 'Format', '%f%f%f', 'Delimiter', ',');
ln_sl     = tb.Var1 - 360;
lt_sl     = tb.Var2;
z_sl      = tb.Var3;

idx_dlt = find(isnan(z_sl) == 1);
ln_sl(idx_dlt) = [];   lt_sl(idx_dlt) = [];   z_sl(idx_dlt) = [];

idx_dlt = find(z_sl>-26);

% custom deleting
ln_sl(idx_dlt) = [];
lt_sl(idx_dlt) = [];
z_sl(idx_dlt)  = [];

lnlm = [-129 -122]; ltlm = [38 52];

idx_ln = find(ln_sl>min(lnlm) & ln_sl<max(lnlm));
idx_lt = find(lt_sl>min(ltlm) & lt_sl<max(ltlm));
idx_ln_lt = intersect(idx_ln, idx_lt);

ln_sl = ln_sl(idx_ln_lt);   lt_sl = lt_sl(idx_ln_lt);   z_sl = z_sl(idx_ln_lt);

% downsampling factor
n = 10;
ln_sl = ln_sl(1:n:end);     lt_sl = lt_sl(1:n:end);     z_sl = z_sl(1:n:end);

[ln_sl_g, lt_sl_g] = meshgrid(ln_sl, lt_sl);

% GAUSSIAN PROCESS REGRESSION
lon_lat  = [ln_sl(:), lt_sl(:)];
gprMdl = fitrgp(lon_lat, z_sl, ...
                'KernelFunction','squaredexponential', ...
                'Sigma',0.2, ...                  % initial guess for noise
                'BasisFunction','constant', ...
                'FitMethod','exact', ...
                'Standardize',true, ...
                'Beta',0);
                %'NoiseVariance', noiseVar);
gridLonLat = [ln_sl_g(:), lt_sl_g(:)];
[Zpred_sl, Zstd] = predict(gprMdl, gridLonLat);
Zpred_sl         = reshape(Zpred_sl, size(ln_sl_g));
[xg_sl, yg_sl]   = map2xy(ln_sl_g, lt_sl_g, srGeometry);
[Xnormal_sl, Ynormal_sl, Znormal_sl] = surfNormal(xg_sl, yg_sl, Zpred_sl, -6);
[LONnormal_sl, LATnormal_sl]         = xy2map(Xnormal_sl, Ynormal_sl, srGeometry);
Znormal_sl_interp                    = griddata(LONnormal_sl, LATnormal_sl, ...
                                                Znormal_sl, ln_sl_g, lt_sl_g);
% MASK WITH NANS
shp        = alphaShape(ln_sl, lt_sl);
insideIdx  = inShape(shp, ln_sl_g(:), lt_sl_g(:));
insideIdx  = reshape(insideIdx, size(ln_sl_g));
Znormal_sl_interp(~insideIdx) = NaN;

%% MERGING
disp('Merging different slab models ...')

lnlm = [-130.5 -122.25]; ltlm = [40.5 50];

lnAr = [min(lnlm):.02:max(lnlm)];
ltAr = [min(ltlm):.02:max(ltlm)];

[lnAr_g, ltAr_g] = meshgrid(lnAr, ltAr);
gpr_data         = (griddata(lonG, latG, ZpredCS_interp, lnAr_g, ltAr_g))';
pf_data          = (griddata(lonG, latG, Zpf_interp, lnAr_g, ltAr_g))';
mh_ext_data      = (griddata(lon_ext_g, lat_ext_g, z_pf_ext_gr, lnAr_g, ltAr_g))';
gr_data          = (griddata(X_gr_crs, Y_gr_crs, data_crs_filt, lnAr_g, ltAr_g))';
blch_data        = (griddata(ln_bl_g, lt_bl_g, blch, lnAr_g, ltAr_g))';
mc_data          = (griddata(ln_mc_g, lt_mc_g, Znormal_mc_interp, lnAr_g, ltAr_g))';
sl_data          = (griddata(ln_sl_g, lt_sl_g, Znormal_sl_interp, lnAr_g, ltAr_g))';

ln_M = []; lt_M = []; slab = [];

for i = 1:length(lnAr)

    ln = lnAr(i);

    for j = 1:length(ltAr)

        lt = ltAr(j);
        % offshore
        if ~isnan(pf_data(i,j))
            ln_M = vertcat(ln_M, ln);
            lt_M = vertcat(lt_M, lt);
            slab = vertcat(slab, pf_data(i,j));
        % northern california
        elseif ~isnan(mh_ext_data(i,j))
            ln_M = vertcat(ln_M, ln);
            lt_M = vertcat(lt_M, lt);
            slab = vertcat(slab, mh_ext_data(i,j));
        % gorda ridge
        elseif ~isnan(gr_data(i,j))
            ln_M = vertcat(ln_M, ln);
            lt_M = vertcat(lt_M, lt);
            slab = vertcat(slab, gr_data(i,j));
        % onshore
        elseif ~isnan(blch_data(i,j))
            ln_M = vertcat(ln_M, ln);
            lt_M = vertcat(lt_M, lt);
            slab = vertcat(slab, blch_data(i,j));
        end

    end

end

F = scatteredInterpolant(ln_M, lt_M, slab);
slabG = F(lnAr_g, ltAr_g);

slabG_filt = imgaussfilt(slabG, 2);











