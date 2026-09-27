function [outMatrix] = max_filter(inMatrix, kernelLength)
arguments (Input)
    inMatrix (:, :)
    kernelLength (1, 1) double = 3
end
arguments (Output)
    outMatrix (:, :)
end

[H, W] = size(inMatrix);
padSize = floor(kernelLength / 2);

% kalau padding dengan nol jadi merusak nilai min, jadi kita replicate
padded = padarray(inMatrix, [padSize, padSize], 'replicate', 'both');
outMatrix = zeros(H, W, 'like', inMatrix);

for row = 1:H
    for col = 1:W
        region = padded(row : row + kernelLength - 1, col : col + kernelLength - 1);
        outMatrix(row, col) = max(region(:));
    end
end
end