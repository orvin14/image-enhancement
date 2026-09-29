function img_out = my_histeq(img)

if size(img, 3) == 1
    % Citra Grayscale
    img_out = process_single_channel_eq(img);
else
    % Citra RGB
    % Konversi ke ruang warna HSV agar enhancement fokus pada komponen kecerahan (V)
    hsv_img = rgb2hsv(img);
    v_channel = uint8(hsv_img(:, :, 3) * 255);

    % Terapkan Equalization hanya pada kanal V
    v_eq = process_single_channel_eq(v_channel);

    % Kembalikan kanal V ke rentang [0, 1] dan gabungkan kembali ke RGB
    hsv_img(:, :, 3) = double(v_eq) / 255;
    img_out = hsv2rgb(hsv_img);
    img_out = uint8(img_out * 255);
end
end

% Fungsi untuk memproses pemerataan 1 channel
function ch_out = process_single_channel_eq(ch_in)
[rows, cols] = size(ch_in);
total_pixels = rows * cols;

% Hitung histogram
counts = my_histogram(ch_in);

% Hitung CDF
cdf = cumulative_sum(counts);

% Cari nilai CDF terkecil yang bukan nol
cdf_min = min(cdf(cdf > 0));

% Buat Lookup Table pemetaan intensitas baru
lut = zeros(256, 1, 'uint8');
for v = 1:256
    if cdf(v) >= cdf_min
        val_mapped = round(((cdf(v) - cdf_min) / (total_pixels - cdf_min)) * 255);
        lut(v) = uint8(max(0, min(255, val_mapped)));
    end
end

% Terapkan pemetaan LUT ke seluruh piksel
ch_out = lut(double(ch_in) + 1);
end

% Fungsi internal untuk penjumlahan kumulatif
function cdf = cumulative_sum(counts)
cdf = zeros(256, 1);
current_sum = 0;
for i = 1:256
    current_sum = current_sum + counts(i);
    cdf(i) = current_sum;
end
end