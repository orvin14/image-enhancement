function [outMatrix] = max_filter(inMatrix, kernelLength)
arguments (Input)
    inMatrix (:, :, :)
    kernelLength (1, 1) double = 3
end
arguments (Output)
    outMatrix (:, :, :)
end

[H, W, C] = size(inMatrix);
padSize = floor(kernelLength / 2);

% kalau padding dengan nol jadi merusak nilai min, jadi kita replicate
padded = padarray(inMatrix, [padSize, padSize, 0], 'replicate', 'both');
outMatrix = zeros(H, W, C, 'like', inMatrix);

for c = 1:C
    for row = 1:H
        for col = 1:W
            region = padded(row : row + kernelLength - 1, col : col + kernelLength - 1, c);
            outMatrix(row, col, c) = max(region(:));
        end
    end

end

end