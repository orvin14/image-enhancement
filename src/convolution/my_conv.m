function [outMatrix] = my_conv(inMatrix, kernel, padType)
%MY_CONV Summary of this function goes here
%   Melakukan konvolusi dengan sebuah kernel dengan padding 0 ke input
%   matrix
arguments (Input)
    inMatrix (:, :, :)
    kernel (:, :)
    padType = 'replicate'
end

arguments (Output)
    outMatrix (:, :, :)
end

inDouble = double(inMatrix);
kernelDouble = double(kernel);

[H, W, C] = size(inDouble);
[kH, kW] = size(kernelDouble);
padH = floorDiv(kH, 2);
padW = floorDiv(kW, 2);

% padsize = [padH, padW, 0] soalnya channel tidak dipadding, hanya matriks
% gambarnya
padded = padarray(inDouble, [padH, padW, 0], padType, "both");

outMatrix = zeros(H, W, C, "double");
for c = 1:C
    for row = 1:H
        for col = 1:W
            region = padded(row : (row + kH-1), col : (col + kW-1), c);
            % Operator .* artinya perkalian element-wise, bukan aljabar linear.
            % "all" artinya hasilnya dijumlahkan jadi 1 angka, bukan jadi
            % matriks/vektor lagi.
            outMatrix(row, col, c) = sum(region .* kernelDouble, "all");
        end
    end
end

end