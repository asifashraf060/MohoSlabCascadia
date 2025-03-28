%% Plotting script for the merged Moho
% output Moho structures are plotted with political and tectonic boundaries
% in a single figure

close all, clc, clear

scriptDir = fileparts(mfilename('fullpath'));
cd(scriptDir)
cd ..

% output directories for merged slabs and their plots
outPlot_dir = [pwd, '/outputs/plots/'];
outMdl_dir  = [pwd, '/outputs/models/'];

% input directory for shapefiles
inShp_dir   = [pwd, '/inputs/shapefiles/'];

% Return to the original script directory after loading necessary data files
cd(scriptDir)

% Shapefiles
    % us states
s1 = shaperead([inShp_dir,'us_states/cb_2018_us_state_500k.shp']);
    % canadian provinces
s2 = shaperead([inShp_dir,'canadian_provinces/province.shp']);
    % blanco transform faults
s3 = shaperead([inShp_dir,'blanco_transform_fault/Active Transform.shp']);
s4 = shaperead([inShp_dir,'blanco_transform_fault/Depressions.shp']);
s5 = shaperead([inShp_dir,'blanco_transform_fault/Inactive_Faults.shp']);
    % juan de fuca spreading centers
s6 = shaperead([inShp_dir,'juan_de_fuca_ridge/JDFR.shp']);
    % gorda spreading centers
s7 = shaperead([inShp_dir,'gorda_ridge/Gorda_ridge.shp'], 'UseGeoCoords', false);
% Define the source (UTM Zone 10N) and target (WGS84) projections
utm10N = projcrs(32610); % UTM Zone 10N (EPSG: 32610)
% Convert the shapefile coordinates
for k = 1:length(s7)
    % S(k).X and S(k).Y contain the UTM coordinates (in meters)
    [lon, lat] = projinv(utm10N, s7(k).X, s7(k).Y);
    % You can either save the new coordinates in new fields
    s7(k).X = lat;
    s7(k).Y = lon;
end

% load the output structures
lon = load([outMdl_dir, 'LON_grid.mat']);
lat = load([outMdl_dir, 'LAT_grid.mat']);
gp_blch = load([outMdl_dir, 'casieGP_bloch.mat']);
gp_mccr = load([outMdl_dir, 'casieGP_McCrory.mat']);
gp_slb2 = load([outMdl_dir, 'casieGP_slab2.mat']);
pf_blch = load([outMdl_dir, 'casiePF_bloch.mat']);
pf_mccr = load([outMdl_dir, 'casiePF_McCrory.mat']);
pf_slb2 = load([outMdl_dir, 'casiePF_McCrory.mat']);

% extract the only fieldname from the loaded structure
fn = fieldnames(lon); lon = lon.(fn{1});
fn = fieldnames(lat); lat = lat.(fn{1});
fn = fieldnames(gp_blch); gp_blch = gp_blch.(fn{1});
fn = fieldnames(gp_mccr); gp_mccr = gp_mccr.(fn{1});
fn = fieldnames(gp_slb2); gp_slb2 = gp_slb2.(fn{1});
fn = fieldnames(pf_blch); pf_blch = pf_blch.(fn{1});
fn = fieldnames(pf_mccr); pf_mccr = pf_mccr.(fn{1});
fn = fieldnames(pf_slb2); pf_slb2 = pf_slb2.(fn{1});


% plotting ...
figure('Position', [10 10 1400 800])
tiledlayout(2,2, 'Padding', 'none', 'TileSpacing', 'compact'); 

subplot(2,3,1)
cntr_levels = unique([min(gp_blch(:)):6:-30, -30:4:-16, -16:1:max(gp_blch(:))]);
contourf(lon, lat, gp_blch, cntr_levels, 'LineWidth',.005)
axis equal
colormap((jet(26)))
caxis([-65 -5])
c = colorbar;
c.Ticks = linspace(-65, -5, 14);
mapshow(s1, 'FaceAlpha', 0.0005, 'EdgeColor', 'r', 'LineWidth',1)
mapshow(s2, 'FaceAlpha', 0.0005, 'EdgeColor', 'r', 'LineWidth',1)
mapshow(s3, 'Color','b', 'LineWidth',1.5)
mapshow(s4, 'FaceAlpha', 0.0005, 'EdgeColor', 'b', 'LineWidth', 1.5)
mapshow(s5, 'Color','b', 'LineWidth',1.5)
mapshow(s6, 'Color','b', 'LineWidth',1.5)
mapshow(s7, 'Color','b', 'LineWidth',1.5)
xlim([min(lon(:))-.5 max(lon(:))+.15]); ylim([min(lat(:))-.5 max(lat(:))+.15])
set(gca, 'FontSize', 16)

subplot(2,3,2)
cntr_levels = unique([min(gp_mccr(:)):6:-30, -30:4:-16, -16:1:max(gp_mccr(:))]);
contourf(lon, lat, gp_mccr, cntr_levels, 'LineWidth',.005)
axis equal
colormap((jet(26)))
caxis([-65 -5])
c = colorbar;
c.Ticks = linspace(-65, -5, 14);
mapshow(s1, 'FaceAlpha', 0.0005, 'EdgeColor', 'r', 'LineWidth',1)
mapshow(s2, 'FaceAlpha', 0.0005, 'EdgeColor', 'r', 'LineWidth',1)
mapshow(s3, 'Color','b', 'LineWidth',1.5)
mapshow(s4, 'FaceAlpha', 0.0005, 'EdgeColor', 'b', 'LineWidth', 1.5)
mapshow(s5, 'Color','b', 'LineWidth',1.5)
mapshow(s6, 'Color','b', 'LineWidth',1.5)
mapshow(s7, 'Color','b', 'LineWidth',1.5)
xlim([min(lon(:))-.5 max(lon(:))+.15]); ylim([min(lat(:))-.5 max(lat(:))+.15])
set(gca, 'FontSize', 16)

subplot(2,3,3)
cntr_levels = unique([min(gp_slb2(:)):6:-30, -30:4:-16, -16:1:max(gp_slb2(:))]);
contourf(lon, lat, gp_slb2, cntr_levels, 'LineWidth',.005)
axis equal
colormap((jet(26)))
caxis([-65 -5])
c = colorbar;
c.Ticks = linspace(-65, -5, 14);
mapshow(s1, 'FaceAlpha', 0.0005, 'EdgeColor', 'r', 'LineWidth',1)
mapshow(s2, 'FaceAlpha', 0.0005, 'EdgeColor', 'r', 'LineWidth',1)
mapshow(s3, 'Color','b', 'LineWidth',1.5)
mapshow(s4, 'FaceAlpha', 0.0005, 'EdgeColor', 'b', 'LineWidth', 1.5)
mapshow(s5, 'Color','b', 'LineWidth',1.5)
mapshow(s6, 'Color','b', 'LineWidth',1.5)
mapshow(s7, 'Color','b', 'LineWidth',1.5)
xlim([min(lon(:))-.5 max(lon(:))+.15]); ylim([min(lat(:))-.5 max(lat(:))+.15])
set(gca, 'FontSize', 16)

subplot(2,3,4)
cntr_levels = unique([min(pf_blch(:)):6:-30, -30:4:-16, -16:1:max(pf_blch(:))]);
contourf(lon, lat, pf_blch, cntr_levels, 'LineWidth',.005)
axis equal
colormap((jet(26)))
caxis([-65 -5])
c = colorbar;
c.Ticks = linspace(-65, -5, 14);
mapshow(s1, 'FaceAlpha', 0.0005, 'EdgeColor', 'r', 'LineWidth',1)
mapshow(s2, 'FaceAlpha', 0.0005, 'EdgeColor', 'r', 'LineWidth',1)
mapshow(s3, 'Color','b', 'LineWidth',1.5)
mapshow(s4, 'FaceAlpha', 0.0005, 'EdgeColor', 'b', 'LineWidth', 1.5)
mapshow(s5, 'Color','b', 'LineWidth',1.5)
mapshow(s6, 'Color','b', 'LineWidth',1.5)
mapshow(s7, 'Color','b', 'LineWidth',1.5)
xlim([min(lon(:))-.5 max(lon(:))+.15]); ylim([min(lat(:))-.5 max(lat(:))+.15])
set(gca, 'FontSize', 16)

subplot(2,3,5)
cntr_levels = unique([min(pf_mccr(:)):6:-30, -30:4:-16, -16:1:max(pf_mccr(:))]);
contourf(lon, lat, pf_mccr, cntr_levels, 'LineWidth',.005)
axis equal
colormap((jet(26)))
caxis([-65 -5])
c = colorbar;
c.Ticks = linspace(-65, -5, 14);
mapshow(s1, 'FaceAlpha', 0.0005, 'EdgeColor', 'r', 'LineWidth',1)
mapshow(s2, 'FaceAlpha', 0.0005, 'EdgeColor', 'r', 'LineWidth',1)
mapshow(s3, 'Color','b', 'LineWidth',1.5)
mapshow(s4, 'FaceAlpha', 0.0005, 'EdgeColor', 'b', 'LineWidth', 1.5)
mapshow(s5, 'Color','b', 'LineWidth',1.5)
mapshow(s6, 'Color','b', 'LineWidth',1.5)
mapshow(s7, 'Color','b', 'LineWidth',1.5)
xlim([min(lon(:))-.5 max(lon(:))+.15]); ylim([min(lat(:))-.5 max(lat(:))+.15])
set(gca, 'FontSize', 16)

subplot(2,3,6)
cntr_levels = unique([min(pf_slb2(:)):6:-30, -30:4:-16, -16:1:max(pf_slb2(:))]);
contourf(lon, lat, pf_slb2, cntr_levels, 'LineWidth',.005)
axis equal
colormap((jet(26)))
caxis([-65 -5])
c = colorbar;
c.Ticks = linspace(-65, -5, 14);
mapshow(s1, 'FaceAlpha', 0.0005, 'EdgeColor', 'r', 'LineWidth',1)
mapshow(s2, 'FaceAlpha', 0.0005, 'EdgeColor', 'r', 'LineWidth',1)
mapshow(s3, 'Color','b', 'LineWidth',1.5)
mapshow(s4, 'FaceAlpha', 0.0005, 'EdgeColor', 'b', 'LineWidth', 1.5)
mapshow(s5, 'Color','b', 'LineWidth',1.5)
mapshow(s6, 'Color','b', 'LineWidth',1.5)
mapshow(s7, 'Color','b', 'LineWidth',1.5)
xlim([min(lon(:))-.5 max(lon(:))+.15]); ylim([min(lat(:))-.5 max(lat(:))+.15])
set(gca, 'FontSize', 16)