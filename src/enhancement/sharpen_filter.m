function [outMatrix] = sharpen_filter(inMatrix, alpha, sigma)
% SHARPEN_FILTER Penajaman dengan formula Highboost:
% Formula: Highboost = (alpha - 1) * Original + Highpass
%   untuk Highpass = Original - Gaussian_Blur(Original)
% 
%   alpha = 1.0 : Edge extraction
%   alpha = 2.0 : Unsharp Masking
%   alpha > 2.0 : High-Boost Filtering

arguments (Input)
    inMatrix (:, :, :)
    alpha (1, 1) double {mustBeNonnegative} = 2.0
    sigma (1, 1) double {mustBePositive} = 1.0
end
arguments (Output)
    outMatrix (:, :, :)
end

inDouble = double(inMatrix);
lowpass  = double(gaussian_filter(inDouble, sigma));
highpass = inDouble - lowpass;

% Highboost = (alpha - 1) * Original + Highpass
res = (alpha - 1) * inDouble + highpass;

% Cap nilainya ke rentang [0, 255]
outMatrix = max(0, min(255, res));

end