function [X_new, Y_new, Z_new] = surfNormal(X, Y, Z, thickness)

    % OFFSET_SURFACE_ALONG_NORMAL
    %   Offsets a 3D surface Z = f(X, Y) by a user-specified thickness THK 
    %   (e.g., 6 km) along the local normal. The script calculates the partial 
    %   derivatives of Z (via GRADIENT) to find the unit normal, then adjusts 
    %   each grid point by THK in that direction. This ensures a consistent 
    %   separation between the original and new surfaces, accounting for 
    %   curvature.
    %
    % Inputs:
    %   X, Y, Z:      2D matrices of the same size, describing the original surface
    %   thickness:    Distance to offset along the local normal (e.g., 6 km)
    %
    % Outputs:
    %   X_new, Y_new, Z_new: 2D matrices describing the offset surface

    % Make a copy of Z for inpainting
    Z_inpaint = Z;
    maskValid = ~isnan(Z_inpaint);
    if any(~maskValid(:))
        F = scatteredInterpolant(X(maskValid), Y(maskValid), Z(maskValid), 'natural', 'none');
        Z_inpaint(~maskValid) = F(X(~maskValid), Y(~maskValid));
    end

    % --- 1. Determine Grid Spacing ---
    % (Adjust these if your grid spacing is nonuniform.)
    dx = mean(diff(X(1,:)), 'omitnan');   % approximate spacing in the X direction
    dy = mean(diff(Y(:,1)), 'omitnan');   % approximate spacing in the Y direction
    
    % --- 2. Compute Surface Gradients ---
    % Compute the partial derivatives of Z with respect to x and y.
    [Zx, Zy] = gradient(Z_inpaint, dx, dy);
    
    % --- 3. Compute the Magnitude of the Normal Vector ---
    % For the upward-pointing unnormalized normal, we have (-Zx, -Zy, 1).
    normFactor = sqrt(1 + Zx.^2 + Zy.^2);
    
    % --- 4. Compute the Unit Normal Vector ---
    % Upward unit normal:
    n_x = -Zx ./ normFactor;
    n_y = -Zy ./ normFactor;
    n_z =  1   ./ normFactor;
    
    % we offset along the negative of the upward normal:
    % The offset vector is:
    % offset_vector = thickness * [n_x, n_y, n_z]
    
    % Thus, the new (moho) surface coordinates become:
    X_new = X + thickness * n_x;  % This equals X + 6*(Zx./normFactor)
    Y_new = Y + thickness * n_y;  % This equals Y + 6*(Zy./normFactor)
    Z_new = Z + thickness * n_z;  % For a flat surface, Z_moho = Z - 6
    %Z_new(~maskValid) = NaN;

end