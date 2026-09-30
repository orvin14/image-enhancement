function [is_valid, diff_val, report] = verify_histogram(img)

[rows, cols, num_channels] = size(img);
total_pixels = rows * cols;

% Hitung histogram menggunakan implementasi manual
counts_custom = my_histogram(img);

% Hitung histogram menggunakan fungsi bawaan imhist
counts_builtin = zeros(256, num_channels);
for c = 1:num_channels
    counts_builtin(:, c) = imhist(img(:, :, c));
end

% Verifikasi total jumlah piksel per kanal
pixel_check = true;
for c = 1:num_channels
    if sum(counts_custom(:, c)) ~= total_pixels
        pixel_check = false;
        break;
    end
end

% Membandingkan selisih elemen terhadap imhist
diff_val = sum(abs(counts_custom(:) - counts_builtin(:)));
exact_match = (diff_val == 0);

% Keputusan Validasi
is_valid = pixel_check && exact_match;

% Struct rincian laporan
report = struct();
report.pixel_check  = pixel_check;
report.exact_match  = exact_match;
report.diff_val     = diff_val;
report.is_valid     = is_valid;
report.total_pixels = total_pixels;

% Cetak Laporan Hasil Validasi ke Command Window
fprintf('=== HASIL VALIDASI HISTOGRAM ===\n');
fprintf('Jumlah Piksel Sesuai  : %s\n', mat2str(pixel_check));
fprintf('Identik dengan imhist : %s\n', mat2str(exact_match));
fprintf('Total Selisih Nilai   : %d\n', diff_val);

if is_valid
    fprintf('Status                : VALID\n');
else
    fprintf('Status                : TIDAK VALID\n');
end
fprintf('================================\n');
end