function [outMatrix] = median_filter(inMatrix, kernelLength)

arguments (Input)
    inMatrix (:, :, :)
    kernelLength (1, 1) double {mustBePositive} = 3
end

arguments (Output)
    outMatrix (:, :, :)
end

if mod(kernelLength, 2) == 0
    error('kernelLength must be an odd integer.');
end

[H, W, C] = size(inMatrix);
padSize = floor(kernelLength / 2);

% padsize = [padH, padW, 0] soalnya channel tidak dipadding, hanya matriks
% gambarnya
padded = padarray(inMatrix, [padSize, padSize, 0], 0, 'both');

outMatrix = zeros(H, W, C, 'like', inMatrix);

for c = 1:C
    for row = 1:H
        for col = 1:W
            % ambil elemen yang ditangkap window/kernel
            region = padded(row : row + kernelLength - 1, col : col + kernelLength - 1, c);
            
            % colon operator (:) flattens 2D matrix into vector
            outMatrix(row, col, c) = median(region(:));
        end
    end
end

end