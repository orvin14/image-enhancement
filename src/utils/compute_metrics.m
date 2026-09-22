function metrics = compute_metrics(img)
% COMPUTE_METRICS Menghitung fitur dan statistik citra
% Input : img - Citra masukan uint8 (Grayscale 2D atau RGB 3D)
% Output: metrics - Struct berisi nilai min, max, mean, std, dan entropy

img_double = double(img);
[rows, cols, num_channels] = size(img);
total_pixels = rows * cols;

% Inisialisasi struktur data untuk menyimpan metrik setiap kanal
metrics = struct();
metrics.min = zeros(1, num_channels);
metrics.max = zeros(1, num_channels);
metrics.mean = zeros(1, num_channels);
metrics.std = zeros(1, num_channels);
metrics.entropy = zeros(1, num_channels);

for c = 1:num_channels
    channel_data = img_double(:, :, c);
    channel_uint8 = img(:, :, c);

    % Nilai Minimum dan Maksimum Intensitas
    metrics.min(c) = min(channel_data(:));
    metrics.max(c) = max(channel_data(:));

    % Nilai Rata-Rata
    % Formula: Sum(X) / Total_Pixel
    metrics.mean(c) = sum(channel_data(:)) / total_pixels;

    % Standar Deviasi
    % Formula: sqrt( Sum((X - Mean)^2) / Total_Pixel )
    variance = sum((channel_data(:) - metrics.mean(c)).^2) / total_pixels;
    metrics.std(c) = sqrt(variance);

    % Entropy
    % Formula: -Sum( P(i) * log2(P(i)) )
    counts = my_histogram(channel_uint8);
    p = counts / total_pixels;

    p_nonzero = p(p > 0);
    metrics.entropy(c) = -sum(p_nonzero .* log2(p_nonzero));
end
end