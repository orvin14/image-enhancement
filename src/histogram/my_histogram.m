function counts = my_histogram(img)
% MY_HISTOGRAM Menghitung histogram 256 tingkat intensitas secara manual.
% Input : img - Citra uint8 (Grayscale 2D atau RGB 3D)
% Output: counts - Matriks 256x1 (Grayscale) atau 256x3 (RGB)

% Memeriksa dimensi citra
[num_rows, num_cols, num_channels] = size(img);
total_pixels = num_rows * num_cols;

% Inisialisasi matriks hasil histogram dengan nilai 0
counts = zeros(256, num_channels);

% Proses iterasi untuk setiap kanal warna
for c = 1:num_channels
    channel_data = img(:, :, c);

    % Iterasi untuk setiap tingkat intensitas dari 0 hingga 255
    for val = 0:255
        % Menghitung jumlah pixel yang memiliki intensitas bernilai 'val'
        counts(val + 1, c) = sum(channel_data(:) == val);
    end
end
end