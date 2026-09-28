function [outMtarix] = mean_filter(inMatrix,kernelLength)
%MEAN_FILTER Summary of this function goes here
%   Detailed explanation goes here
arguments (Input)
    inMatrix (:, :, :)
    kernelLength (1, 1) double {mustBePositive} = 3
end

arguments (Output)
    outMtarix (:, :, :)
end

if mod(kernelLength, 2) == 0
    error('kernelLength must be an odd integer.');
end

kernel = ones(kernelLength, kernelLength) / (kernelLength)^2;
outMtarix = my_conv(inMatrix, kernel);

end