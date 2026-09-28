function [outMatrix] = sharpen_filter(inMatrix, A)

% A = 0 : High-Pass Filter (edge-detection, sum = 0, pusat = 8)
% A = 1 : Unsharp Masking standar (kernel: sum = 1, pusat = 9)
% A > 1 : High-Boost Filter (sum = A)

arguments (Input)
    inMatrix (:, :, :)
    A (1, 1) double {mustBeNonnegative} = 1.0
end
arguments (Output)
    outMatrix (:, :, :)
end

kernel = [-1, -1, -1; ...
          -1, A + 8, -1; ...
          -1, -1, -1];

convResult = my_conv(double(inMatrix), kernel, 'replicate');

% cap nilainya ke range [0, 255]
outMatrix = max(0, min(255, convResult));

end