function [ln_M, lt_M, slab] = mergeSlabData(lnAr, ltAr, varargin)
% mergeSlabData Merges multiple slab data models into a unified structure.
%
%   [ln_M, lt_M, slab] = mergeSlabData(lnAr, ltAr, data1, data2, ..., dataN)
%
%   This function loops over a grid defined by the vectors lnAr and ltAr.
%   At each grid point, it sequentially checks the input slab data matrices.
%   The first non-NaN value encountered is recorded for that grid point.
%
%   Inputs:
%       lnAr - Vector of longitudes (or x-coordinates) defining the grid.
%       ltAr - Vector of latitudes (or y-coordinates) defining the grid.
%       data1, data2, ..., dataN - Slab data matrices of size 
%                                  [length(lnAr) x length(ltAr)].
%
%   Outputs:
%       ln_M - Column vector of longitudes where a valid slab value was found.
%       lt_M - Column vector of latitudes corresponding to ln_M.
%       slab - Column vector of slab values selected from the input matrices.
%
%   Example:
%       [ln_M, lt_M, slab] = mergeSlabData(lnAr, ltAr, pf_data, mh_ext_data, gr_data, blch_data);
%
%   Author: Asif Ashraf
%   Date: March 25

    % Initialize output arrays
    ln_M = [];
    lt_M = [];
    slab = [];
    
    % Loop over each grid point defined by lnAr and ltAr.
    for i = 1:length(lnAr)
        ln = lnAr(i);
        for j = 1:length(ltAr)
            lt = ltAr(j);
            % Check each provided slab data matrix in order.
            for k = 1:length(varargin)
                currentData = varargin{k};
                if ~isnan(currentData(i,j))
                    % If a valid value is found, store the longitude, latitude,
                    % and corresponding slab value.
                    ln_M = [ln_M; ln];
                    lt_M = [lt_M; lt];
                    slab = [slab; currentData(i,j)];
                    break; % Exit the loop once the first valid value is found.
                end
            end
        end
    end
end
