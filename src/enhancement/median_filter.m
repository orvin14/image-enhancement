function [outMatrix] = median_filter(inMatrix, kernelLength)

arguments (Input)
    inMatrix (:, :)
    kernelLength (1, 1) double {mustBePositive} = 3
end

arguments (Output)
    outMatrix (:, :)
end

if mod(kernelLength, 2) == 0
    error('kernelLength must be an odd integer.');
end

[H, W] = size(inMatrix);
padSize = floor(kernelLength / 2);

padded = padarray(inMatrix, [padSize, padSize], 0, 'both');

outMatrix = zeros(H, W, 'like', inMatrix);

for row = 1:H
    for col = 1:W
        % ambil elemen yang ditangkap window/kernel
        region = padded(row : row + kernelLength - 1, col : col + kernelLength - 1);
        
        % colon operator (:) flattens 2D matrix into vector
        outMatrix(row, col) = median(region(:));
    end
end

end