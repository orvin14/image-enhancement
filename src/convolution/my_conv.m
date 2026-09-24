function [outMatrix] = my_conv(inMatrix, kernel)
%MY_CONV Summary of this function goes here
%   Melakukan konvolusi dengan sebuah kernel dengan padding 0 ke input
%   matrix
arguments (Input)
    inMatrix (:, :)
    kernel (:, :)
end

arguments (Output)
    outMatrix (:, :)
end

[H, W] = size(inMatrix);
[kH, kW] = size(kernel);
padH = floorDiv(kH, 2);
padW = floorDiv(kW, 2);

padded = padarray(inMatrix, [padH, padW], 0, "both")

outMatrix = zeros(H, W, "like", inMatrix);
for row = 1:H
    for col = 1:W
        region = padded(row:row + kH - 1, col:col + kW - 1);
        % Operator .* artinya perkalian element-wise, bukan aljabar linear.
        % "all" artinya hasilnya dijumlahkan jadi 1 angka, bukan jadi
        % matriks/vektor lagi.
        outMatrix(row, col) = sum(region .* kernel, "all");
    end
end

end