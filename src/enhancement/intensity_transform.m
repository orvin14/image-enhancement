function img_out = intensity_transform(img, type, param)
img_double = double(img);
img_out_double = zeros(size(img_double));
[~, ~, num_channels] = size(img);

switch lower(type)
    case {'brightness'}
        % Penyesuaian Kecerahan Linear: s = r + b
        if nargin < 3 || isempty(param)
            param = 0; % Nilai default penambahan kecerahan
        end
        bias = param;
        img_out_double = img_double + bias;

    case 'contrast_stretching'
        % Pemetaan nilai intensitas dari rentang [r_min, r_max] ke [0, 255]
        for c = 1:num_channels
            ch = img_double(:, :, c);
            r_min = min(ch(:));
            r_max = max(ch(:));

            % Mencegah pembagian dengan nol jika citra memiliki intensitas seragam
            if r_max == r_min
                img_out_double(:, :, c) = ch;
            else
                img_out_double(:, :, c) = 255 * (ch - r_min) / (r_max - r_min);
            end
        end

    case 'log'
        % Transformasi Logaritma: s = c * log(1 + r)
        c_factor = 255 / log(1 + 255);
        img_out_double = c_factor * log(1 + img_double);

    case 'gamma'
        % Power-Law / Gamma Correction: s = c * r^gamma
        if nargin < 3 || isempty(param)
            param = 1.0; % Nilai default gamma jika tidak diisi
        end
        gamma_val = param;

        % Skala normalisasi [0, 1] sebelum dipangkatkan
        norm_img = img_double / 255;
        img_out_double = 255 * (norm_img .^ gamma_val);

    otherwise
        error('Jenis transformasi tidak dikenali.');
end

% Membatasi nilai piksel pada rentang valid [0, 255] dan konversi kembali ke uint8
img_out_double = max(0, min(255, img_out_double));
img_out = uint8(img_out_double);
end