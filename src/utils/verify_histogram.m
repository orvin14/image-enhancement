function [is_valid, diff_val] = verify_histogram(img)
% VERIFY_HISTOGRAM Memvalidasi kebenaran output my_histogram terhadap imhist bawaan
% Input : img - Citra uint8 (Grayscale atau RGB)
% Output: is_valid - Status kebenaran (true/false)
%         diff_val - Total akumulasi selisih nilai histogram

[rows, cols, num_channels] = size(img);
total_pixels = rows * cols;

% Hitung histogram
counts_custom = my_histogram(img);

% Hitung histogram menggunakan imhist
counts_builtin = zeros(256, num_channels);
for c = 1:num_channels
    counts_builtin(:, c) = imhist(img(:, :, c));
end

% Verifikasi total jumlah piksel
pixel_check = true;
for c = 1:num_channels
    if sum(counts_custom(:, c)) ~= total_pixels
        pixel_check = false;
        break;
    end
end

% Membandingkan selisih elemen dengan imhist
diff_val = sum(abs(counts_custom(:) - counts_builtin(:)));
exact_match = (diff_val == 0);

% Keputusan Validasi
is_valid = pixel_check && exact_match;

% Cetak Laporan Hasil Validasi
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