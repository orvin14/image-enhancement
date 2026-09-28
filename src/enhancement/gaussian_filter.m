function [outMatrix, kernel] = gaussian_filter(inMatrix, sigma)

arguments (Input)
    inMatrix (:, :, :)
    sigma (1, 1) double {mustBePositive} = 1.0
end

arguments (Output)
    outMatrix (:, :, :)
    kernel (:, :)
end

% width = 5 * sigma (radius = 2.5 * sigma)
radius = ceil(2.5 * sigma);

% meshgrid from -radius to +radius jadi width = 2*radius + 1 (termasuk pusatnya)
% jadi misal radius = 1 jadinya x = [[-1,0,1],[-1,0,1],[-1,0,1]]
% y = [[-1,-1,-1],[0,0,0],[1,1,1]]
[x, y] = meshgrid(-radius:radius, -radius:radius);

% .^2 artinya setiap elemen dilakukan ^2
kernel = exp(-(x.^2 + y.^2) / (2 * sigma^2));
kernel = kernel / sum(kernel, 'all');

outMatrix = my_conv(inMatrix, kernel);
end