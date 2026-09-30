function img_out = my_histmatch(img_input, img_ref)
% MY_HISTMATCH Menyesuaikan histogram citra masukan terhadap citra referensi
% Dapat digunakan di citra Grayscale (1 kanal), Pseudo-Grayscale (3 kanal R=G=B), dan RGB (3 kanal)

% Bersihkan kanal transparansi (Alpha) jika ada
if size(img_input, 3) == 4, img_input = img_input(:, :, 1:3); end
if size(img_input, 3) == 2, img_input = img_input(:, :, 1); end
if size(img_ref, 3) == 4,   img_ref   = img_ref(:, :, 1:3); end
if size(img_ref, 3) == 2,   img_ref   = img_ref(:, :, 1); end

num_in_channels = size(img_input, 3);
num_ref_channels = size(img_ref, 3);

% Deteksi pseudo-grayscale (file 3 kanal dengan nilai R=G=B jadi pada dasarnya grayscale)
is_ref_pseudo_gray = (num_ref_channels == 3) && isequal(img_ref(:,:,1), img_ref(:,:,2), img_ref(:,:,3));
is_in_pseudo_gray  = (num_in_channels == 3) && isequal(img_input(:,:,1), img_input(:,:,2), img_input(:,:,3));

if num_in_channels == 1 && num_ref_channels == 1
    % Kasus 1: Keduanya Grayscale 1 kanal
    img_out = match_single_channel(img_input, img_ref);

elseif num_in_channels == 1 && num_ref_channels == 3
    % Kasus 2: Masukan Grayscale (1 kanal), Referensi 3 kanal (RGB atau Pseudo-Gray)
    if is_ref_pseudo_gray
        ref_gray = img_ref(:, :, 1);
    else
        ref_gray = rgb2gray(img_ref);
    end
    img_out = match_single_channel(img_input, ref_gray);

elseif num_in_channels == 3 && is_in_pseudo_gray && (num_ref_channels == 1 || is_ref_pseudo_gray)
    % Kasus 3: Masukan Pseudo-Gray (3 kanal), Referensi Grayscale (1 kanal atau 3 kanal identik)
    if num_ref_channels == 3
        ref_gray = img_ref(:, :, 1);
    else
        ref_gray = img_ref;
    end
    single_out = match_single_channel(img_input(:, :, 1), ref_gray);
    img_out = repmat(single_out, [1, 1, 3]);

elseif num_in_channels == 3 && (num_ref_channels == 1 || is_ref_pseudo_gray)
    % Kasus 4: Masukan RGB (3 kanal), Referensi Grayscale / Pseudo-Gray
    % Cocokkan kanal V (Luminance) dalam ruang warna HSV agar nuansa warna tidak rusak
    if is_ref_pseudo_gray
        ref_gray = img_ref(:, :, 1);
    else
        ref_gray = img_ref;
    end
    hsv_in = rgb2hsv(img_input);
    v_channel = uint8(hsv_in(:, :, 3) * 255);
    v_matched = match_single_channel(v_channel, ref_gray);
    hsv_in(:, :, 3) = double(v_matched) / 255;
    img_out = uint8(hsv2rgb(hsv_in) * 255);

elseif num_in_channels == 3 && num_ref_channels == 3
    % Kasus 5: Keduanya RGB (3 kanal) murni
    img_out = zeros(size(img_input), 'uint8');
    for c = 1:3
        img_out(:, :, c) = match_single_channel(img_input(:, :, c), img_ref(:, :, c));
    end
else
    error('Format kanal citra tidak didukung untuk histogram matching.');
end
end

% Fungsi helper pencocokan 1 kanal menggunakan Lookup Table (LUT)
function ch_out = match_single_channel(ch_in, ch_ref)
counts_in = my_histogram(ch_in);
cdf_in = cumulative_sum(counts_in) / numel(ch_in);

counts_ref = my_histogram(ch_ref);
cdf_ref = cumulative_sum(counts_ref) / numel(ch_ref);

lut = zeros(256, 1, 'uint8');
for i = 1:256
    [~, min_idx] = min(abs(cdf_in(i) - cdf_ref));
    lut(i) = uint8(min_idx - 1);
end

ch_out = lut(double(ch_in) + 1);
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