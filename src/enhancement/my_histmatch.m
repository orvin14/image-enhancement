function img_out = my_histmatch(img_input, img_ref)

if size(img_input, 3) ~= size(img_ref, 3)
    error('Citra masukan dan citra referensi harus memiliki jumlah kanal yang sama.');
end

num_channels = size(img_input, 3);
img_out = zeros(size(img_input), 'uint8');

for c = 1:num_channels
    ch_in = img_input(:, :, c);
    ch_ref = img_ref(:, :, c);

    % Hitung CDF citra masukan
    counts_in = my_histogram(ch_in);
    cdf_in = cumulative_sum(counts_in) / numel(ch_in); % Normalisasi [0, 1]

    % Hitung CDF citra referensi
    counts_ref = my_histogram(ch_ref);
    cdf_ref = cumulative_sum(counts_ref) / numel(ch_ref); % Normalisasi [0, 1]

    % Buat Lookup Table
    lut = zeros(256, 1, 'uint8');
    for i = 1:256
        % Cari indeks pada cdf_ref yang selisih nilainya paling minimal dengan cdf_in(i)
        [~, min_idx] = min(abs(cdf_in(i) - cdf_ref));
        lut(i) = uint8(min_idx - 1);
    end

    % Petakan piksel citra masukan menggunakan LUT
    img_out(:, :, c) = lut(double(ch_in) + 1);
end
end

% Fungsi internal penjumlahan kumulatif
function cdf = cumulative_sum(counts)
cdf = zeros(256, 1);
current_sum = 0;
for i = 1:256
    current_sum = current_sum + counts(i);
    cdf(i) = current_sum;
end
end