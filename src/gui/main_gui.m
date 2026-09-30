function main_gui()
    % GUI Perbaikan Citra

    [current_dir, ~, ~] = fileparts(mfilename('fullpath'));
    addpath(genpath(fullfile(current_dir, '..')));
    
    % Main Window
    fig = uifigure('Name', 'IF4073 - Aplikasi Image Enhancement', ...
        'Position', [50 50 1280 720]);

    % Left Panel
    pnl_control = uipanel(fig, 'Title', 'Perbaikan Citra', ...
        'Position', [20 15 285 710]);

    % Tombol Muat Citra
    uibutton(pnl_control, 'Text', 'Muat Citra Uji', ...
        'Position', [15 645 255 30], ...
        'ButtonPushedFcn', @(btn, event) cb_load_image(fig));

    uibutton(pnl_control, 'Text', 'Muat Citra Referensi', ...
        'Position', [15 610 255 30], ...
        'ButtonPushedFcn', @(btn, event) cb_load_ref_image(fig));

    % Dropdown Metode Enhancement
    uilabel(pnl_control, 'Text', 'Pilih Kategori Metode:', ...
        'Position', [15 580 255 18]);
    dd_category = uidropdown(pnl_control, ...
        'Items', {'Analisis / Validasi Histogram', 'Intensity Transformation', ...
            'Histogram Equalization', 'Histogram Matching', 'Image Filtering'}, ...
        'Position', [15 555 255 24], ...
        'ValueChangedFcn', @(dd, event) cb_category_changed(fig));

    % Method Dropdown
    uilabel(pnl_control, 'Text', 'Pilih Teknik Spesifik:', ...
        'Position', [15 528 255 18]);
    dd_method = uidropdown(pnl_control, ...
        'Items', {'Validasi Histogram & Metrik Awal'}, ...
        'Position', [15 503 255 24], ...
        'ValueChangedFcn', @(dd, event) cb_method_changed(fig));

    % Dynamic Parameter Input Panel
    pnl_params = uipanel(pnl_control, 'Title', 'Pengaturan Parameter', ...
        'Position', [15 410 255 85]);

    % 1. Standard Numeric Parameter (Gamma, Kernel Size, Sigma, Alpha)
    lbl_param = uilabel(pnl_params, 'Text', 'Ukuran Window (Ganjil):', ...
        'Position', [10 38 235 18]);
    ef_param = uieditfield(pnl_params, 'numeric', ...
        'Value', 3, ...
        'Position', [10 12 235 24]);

    % 2. Custom Kernel Matrix Input (Multi-line text area)
    lbl_custom = uilabel(pnl_params, 'Text', 'Kernel Matrix (Enter per baris):', ...
        'Position', [10 42 235 18], ...
        'Visible', 'off');
    txt_custom = uitextarea(pnl_params, ...
        'Value', {'-1, 0, 1'; '-2, 0, 2'; '-1, 0, 1'}, ...
        'Position', [10 6 235 36], ...
        'Visible', 'off');

    % Pipeline / Sequential Mode Controls
    chk_sequential = uicheckbox(pnl_control, ...
        'Text', 'Mode Sekuensial (Chaining)', ...
        'Value', false, ...
        'Position', [15 378 255 22]);

    uibutton(pnl_control, 'Text', 'Reset ke Citra Asli', ...
        'Position', [15 344 255 28], ...
        'BackgroundColor', [0.8 0.3 0.3], ...
        'FontColor', [1 1 1], ...
        'ButtonPushedFcn', @(btn, event) cb_reset_image(fig));

    % Action Buttons
    uibutton(pnl_control, 'Text', 'Jalankan Enhancement', ...
        'Position', [15 298 255 38], ...
        'BackgroundColor', [0.2 0.6 0.2], ...
        'FontColor', [1 1 1], ...
        'FontWeight', 'bold', ...
        'ButtonPushedFcn', @(btn, event) cb_process_image(fig));

    uibutton(pnl_control, 'Text', 'Simpan Citra Hasil', ...
        'Position', [15 260 255 30], ...
        'ButtonPushedFcn', @(btn, event) cb_save_image(fig));

    % Statistik Fitur Citra
    uilabel(pnl_control, 'Text', 'Statistik Citra (Output):', ...
        'Position', [15 230 255 18]);
    txt_stats = uitextarea(pnl_control, ...
        'Position', [15 15 255 210], ...
        'Editable', 'off');

    % Visualisasi Citra dan Histogram
    ax_in = uiaxes(fig, 'Position', [320 380 270 270]);
    title(ax_in, 'Citra Masukan');

    ax_out = uiaxes(fig, 'Position', [620 380 270 270]);
    title(ax_out, 'Citra Hasil');

    ax_ref = uiaxes(fig, 'Position', [920 380 270 270]);
    title(ax_ref, 'Citra Referensi');

    ax_hist_in = uiaxes(fig, 'Position', [320 50 420 280]);
    title(ax_hist_in, 'Histogram Masukan');

    ax_hist_out = uiaxes(fig, 'Position', [770 50 420 280]);
    title(ax_hist_out, 'Histogram Hasil');

    % Simpan objek UI ke appdata
    setappdata(fig, 'pnl_params', pnl_params);
    setappdata(fig, 'ax_in', ax_in);
    setappdata(fig, 'ax_out', ax_out);
    setappdata(fig, 'ax_ref', ax_ref);
    setappdata(fig, 'ax_hist_in', ax_hist_in);
    setappdata(fig, 'ax_hist_out', ax_hist_out);
    setappdata(fig, 'dd_category', dd_category);
    setappdata(fig, 'dd_method', dd_method);
    setappdata(fig, 'lbl_param', lbl_param);
    setappdata(fig, 'ef_param', ef_param);
    setappdata(fig, 'lbl_custom', lbl_custom);
    setappdata(fig, 'txt_custom', txt_custom);
    setappdata(fig, 'chk_sequential', chk_sequential);
    setappdata(fig, 'txt_stats', txt_stats);

    % Inisialisasi tampilan parameter berdasarkan metode default
    cb_category_changed(fig);
end

% ---------------- CALLBACKS FUNCTIONS ----------------- 

function cb_category_changed(fig)
    dd_category = getappdata(fig, 'dd_category');
    dd_method = getappdata(fig, 'dd_method');
    
    switch dd_category.Value
        case 'Analisis / Validasi Histogram'
            dd_method.Items = {'Validasi Histogram & Metrik Awal'};
        case 'Intensity Transformation'
            dd_method.Items = {'Brightness Adjustment (Linear)', 'Contrast Stretching', 'Log Transformation', 'Gamma Correction'};
        case 'Histogram Equalization'
            dd_method.Items = {'Histogram Equalization Standard'};
        case 'Histogram Matching'
            dd_method.Items = {'Histogram Specification/Matching'};
        case 'Image Filtering'
            dd_method.Items = {'Mean Filter', 'Gaussian Filter', 'Sharpening Filter (High Boost/Unsharp Masking)', ...
                               'Median Filter', 'Min Filter', 'Max Filter', 'Custom Kernel Convolution'};
    end
    cb_method_changed(fig);
end

function cb_method_changed(fig)
    dd_method  = getappdata(fig, 'dd_method');
    pnl_params = getappdata(fig, 'pnl_params');
    lbl_param  = getappdata(fig, 'lbl_param');
    ef_param   = getappdata(fig, 'ef_param');
    lbl_custom = getappdata(fig, 'lbl_custom');
    txt_custom = getappdata(fig, 'txt_custom');
    
    method = dd_method.Value;

    switch method
        case 'Brightness Adjustment (Linear)'
            pnl_params.Visible = 'on';
            lbl_param.Visible  = 'on';
            ef_param.Visible   = 'on';
            lbl_custom.Visible = 'off';
            txt_custom.Visible = 'off';
            lbl_param.Text     = 'Nilai Bias / Offset (-255 s.d. 255):';
            ef_param.Value     = 30;

        case 'Custom Kernel Convolution'
            pnl_params.Visible = 'on';
            lbl_param.Visible  = 'off';
            ef_param.Visible   = 'off';
            lbl_custom.Visible = 'on';
            txt_custom.Visible = 'on';

        case 'Gaussian Filter'
            pnl_params.Visible = 'on';
            lbl_param.Visible  = 'on';
            ef_param.Visible   = 'on';
            lbl_custom.Visible = 'off';
            txt_custom.Visible = 'off';
            lbl_param.Text     = 'Nilai Sigma (σ):';
            ef_param.Value     = 1.0;

        case 'Sharpening Filter (High Boost/Unsharp Masking)'
            pnl_params.Visible = 'on';
            lbl_param.Visible  = 'on';
            ef_param.Visible   = 'on';
            lbl_custom.Visible = 'off';
            txt_custom.Visible = 'off';
            lbl_param.Text     = 'Alpha α (1: HPF, 2: UM, >2: Boost):';
            ef_param.Value     = 2.0;

        case {'Mean Filter', 'Median Filter', 'Min Filter', 'Max Filter'}
            pnl_params.Visible = 'on';
            lbl_param.Visible  = 'on';
            ef_param.Visible   = 'on';
            lbl_custom.Visible = 'off';
            txt_custom.Visible = 'off';
            lbl_param.Text     = 'Ukuran Window (Ganjil):';
            ef_param.Value     = 3;

        case 'Gamma Correction'
            pnl_params.Visible = 'on';
            lbl_param.Visible  = 'on';
            ef_param.Visible   = 'on';
            lbl_custom.Visible = 'off';
            txt_custom.Visible = 'off';
            lbl_param.Text     = 'Nilai Gamma (γ):';
            ef_param.Value     = 1.0;

        otherwise
            % Sembunyikan panel parameter untuk metode tanpa parameter:
            % - Validasi Histogram & Metrik Awal
            % - Contrast Stretching
            % - Log Transformation
            % - Histogram Equalization Standard
            % - Histogram Specification/Matching
            pnl_params.Visible = 'off';
            lbl_param.Visible  = 'off';
            ef_param.Visible   = 'off';
            lbl_custom.Visible = 'off';
            txt_custom.Visible = 'off';
    end
end

function cb_load_image(fig)
    [file, path] = uigetfile({'*.png;*.jpg;*.bmp;*.tif', 'Berkas Citra (*.png, *.jpg, *.bmp, *.tif)'});
    figure(fig);
    if isequal(file, 0), return; end
    
    try
        img = imread(fullfile(path, file));
        % Store both original and active working image
        setappdata(fig, 'img_orig', img);
        setappdata(fig, 'img_current', img);
        setappdata(fig, 'img_out', []);
        
        ax_in = getappdata(fig, 'ax_in');
        ax_hist_in = getappdata(fig, 'ax_hist_in');
        txt_stats = getappdata(fig, 'txt_stats');
        
        display_image(ax_in, img);
        render_histogram(ax_hist_in, img);
        
        stats = compute_metrics(img);
        txt_stats.Value = {
            '--- METRIK CITRA MASUKAN ---';
            sprintf('Kanal : %d', size(img, 3));
            sprintf('Min   : %s', num2str(stats.min));
            sprintf('Max   : %s', num2str(stats.max));
            sprintf('Mean  : %s', num2str(round(stats.mean, 2)));
            sprintf('StdDev: %s', num2str(round(stats.std, 2)));
            sprintf('Entropy: %s', num2str(round(stats.entropy, 2)));
        };
    catch ME
        uialert(fig, sprintf('Gagal memuat citra:\n%s', ME.message), 'Kesalahan Berkas');
    end
end

function cb_load_ref_image(fig)
    [file, path] = uigetfile({'*.png;*.jpg;*.bmp;*.tif', 'Berkas Citra Referensi'});
    figure(fig);
    if isequal(file, 0), return; end
    
    try
        img_ref = imread(fullfile(path, file));
        setappdata(fig, 'img_ref', img_ref);
        
        ax_ref = getappdata(fig, 'ax_ref');
        display_image(ax_ref, img_ref);
    catch ME
        uialert(fig, sprintf('Gagal memuat citra referensi:\n%s', ME.message), 'Kesalahan Berkas');
    end
end

function cb_reset_image(fig)
    img_orig = getappdata(fig, 'img_orig');
    if isempty(img_orig)
        uialert(fig, 'Belum ada citra yang dimuat untuk di-reset!', 'Peringatan');
        return;
    end
    setappdata(fig, 'img_current', img_orig);
    setappdata(fig, 'img_out', []);
    
    ax_out = getappdata(fig, 'ax_out');
    ax_hist_out = getappdata(fig, 'ax_hist_out');
    txt_stats = getappdata(fig, 'txt_stats');
    
    cla(ax_out);
    title(ax_out, 'Citra Hasil');
    cla(ax_hist_out);
    title(ax_hist_out, 'Histogram Hasil');
    
    stats = compute_metrics(img_orig);
    txt_stats.Value = {
        '--- CITRA DI-RESET KE AWAL ---';
        sprintf('Kanal : %d', size(img_orig, 3));
        sprintf('Min   : %s', num2str(stats.min));
        sprintf('Max   : %s', num2str(stats.max));
        sprintf('Mean  : %s', num2str(round(stats.mean, 2)));
        sprintf('StdDev: %s', num2str(round(stats.std, 2)));
        sprintf('Entropy: %s', num2str(round(stats.entropy, 2)));
    };
end

function cb_process_image(fig)
    img_current = getappdata(fig, 'img_current');
    if isempty(img_current)
        uialert(fig, 'Silakan muat citra masukan terlebih dahulu!', 'Peringatan');
        return;
    end
    
    dd_category    = getappdata(fig, 'dd_category');
    dd_method      = getappdata(fig, 'dd_method');
    ef_param       = getappdata(fig, 'ef_param');
    txt_custom     = getappdata(fig, 'txt_custom');
    chk_sequential = getappdata(fig, 'chk_sequential');
    
    cat = dd_category.Value;
    method = dd_method.Value;
    param_val = ef_param.Value;
    
    try
        switch cat
            case 'Analisis / Validasi Histogram'
                img_out = img_current;
                
            case 'Intensity Transformation'
                if strcmp(method, 'Brightness Adjustment (Linear)')
                    img_out = intensity_transform(img_current, 'brightness', param_val);
                elseif strcmp(method, 'Contrast Stretching')
                    img_out = intensity_transform(img_current, 'contrast_stretching');
                elseif strcmp(method, 'Log Transformation')
                    img_out = intensity_transform(img_current, 'log');
                else
                    img_out = intensity_transform(img_current, 'gamma', param_val);
                end
                
            case 'Histogram Equalization'
                img_out = my_histeq(img_current);
                
            case 'Histogram Matching'
                img_ref = getappdata(fig, 'img_ref');
                if isempty(img_ref)
                    uialert(fig, 'Muat citra referensi terlebih dahulu!', 'Peringatan');
                    return;
                end
                img_out = my_histmatch(img_current, img_ref);
                
            case 'Image Filtering'
                switch method
                    case {'Mean Filter', 'Median Filter', 'Min Filter', 'Max Filter'}
                        if param_val < 1 || floor(param_val) ~= param_val || mod(param_val, 2) == 0
                            uialert(fig, sprintf('Ukuran window harus berupa bilangan bulat positif GANJIL (contoh: 3, 5, 7, ...).\nNilai yang dimasukkan: %g', param_val), ...
                                    'Ukuran Window Tidak Valid');
                            return;
                        end
                        kLen = int32(param_val);
                        if strcmp(method, 'Mean Filter')
                            img_out = uint8(mean_filter(img_current, kLen));
                        elseif strcmp(method, 'Median Filter')
                            img_out = uint8(median_filter(img_current, kLen));
                        elseif strcmp(method, 'Min Filter')
                            img_out = uint8(min_filter(img_current, kLen));
                        else
                            img_out = uint8(max_filter(img_current, kLen));
                        end
                        
                    case 'Gaussian Filter'
                        [res, ~] = gaussian_filter(img_current, param_val);
                        img_out = uint8(res);
                        
                    case 'Sharpening Filter (High Boost/Unsharp Masking)'
                        res = sharpen_filter(img_current, param_val);
                        img_out = uint8(res);
                        
                    case 'Custom Kernel Convolution'
                        lines = txt_custom.Value;
                        if ischar(lines), lines = cellstr(lines); end
                        
                        lines = strtrim(lines);
                        lines = lines(~cellfun('isempty', lines));
                        
                        numRows = numel(lines);
                        if numRows < 1
                            error('Matriks kernel tidak boleh kosong.');
                        end
                        
                        firstRow = sscanf(strrep(lines{1}, ',', ' '), '%f')';
                        numCols = numel(firstRow);
                        if numCols < 1
                            error('Baris pertama tidak valid.');
                        end
                        
                        user_kernel = zeros(numRows, numCols);
                        user_kernel(1, :) = firstRow;
                        
                        for r = 2:numRows
                            rowVals = sscanf(strrep(lines{r}, ',', ' '), '%f')';
                            if numel(rowVals) ~= numCols
                                error('Jumlah kolom baris %d tidak konsisten (%d vs %d).', ...
                                      r, numel(rowVals), numCols);
                            end
                            user_kernel(r, :) = rowVals;
                        end
                        
                        res = my_conv(double(img_current), user_kernel, 'replicate');
                        img_out = uint8(max(0, min(255, res)));
                end
        end
        
        setappdata(fig, 'img_out', img_out);
        
        % Tampilkan Hasil Citra dan Histogram
        ax_out = getappdata(fig, 'ax_out');
        ax_hist_out = getappdata(fig, 'ax_hist_out');
        
        display_image(ax_out, img_out);
        title(ax_out, sprintf('Hasil: %s', method));
        render_histogram(ax_hist_out, img_out);
        
        % Tampilkan Statistik Fitur Citra
        if chk_sequential.Value
            setappdata(fig, 'img_current', img_out);
        end
        
        % Hitung Metrik
        stats = compute_metrics(img_out);
        txt_stats = getappdata(fig, 'txt_stats');
        
        if strcmp(method, 'Validasi Histogram & Metrik Awal')
            [is_valid, diff_val, report] = verify_histogram(img_out);
            if report.pixel_check
                px_status = 'Sesuai';
            else
                px_status = 'Tidak Sesuai';
            end
            
            if report.exact_match
                match_status = 'Identik (0 Deviasi)';
            else
                match_status = sprintf('Beda (Selisih: %d)', diff_val);
            end
            
            if is_valid
                overall_status = 'VALID (100% Akurat)';
            else
                overall_status = 'TIDAK VALID';
            end
            
            txt_stats.Value = {
                '--- HASIL VALIDASI HISTOGRAM ---';
                sprintf('Total Piksel : %d', report.total_pixels);
                sprintf('Jumlah Piksel: %s', px_status);
                sprintf('Uji imhist   : %s', match_status);
                sprintf('Status       : %s', overall_status);
                '';
                '--- METRIK AWAL CITRA ---';
                sprintf('Kanal : %d', size(img_out, 3));
                sprintf('Min   : %s', num2str(stats.min));
                sprintf('Max   : %s', num2str(stats.max));
                sprintf('Mean  : %s', num2str(round(stats.mean, 2)));
                sprintf('StdDev: %s', num2str(round(stats.std, 2)));
                sprintf('Entropy: %s', num2str(round(stats.entropy, 2)));
            };
        else
            txt_stats.Value = {
                sprintf('--- HASIL (%s) ---', method);
                sprintf('Kanal : %d', size(img_out, 3));
                sprintf('Min   : %s', num2str(stats.min));
                sprintf('Max   : %s', num2str(stats.max));
                sprintf('Mean  : %s', num2str(round(stats.mean, 2)));
                sprintf('StdDev: %s', num2str(round(stats.std, 2)));
                sprintf('Entropy: %s', num2str(round(stats.entropy, 2)));
            };
        end
    catch ME
        uialert(fig, sprintf('Terjadi kesalahan pemrosesan:\n\n%s', ME.message), 'Kesalahan Pemrosesan');
    end
end

function cb_save_image(fig)
    img_out = getappdata(fig, 'img_out');
    if isempty(img_out)
        uialert(fig, 'Belum ada hasil pemrosesan untuk disimpan!', 'Peringatan');
        return;
    end
    
    [file, path] = uiputfile({'*.png', 'PNG Image'; '*.jpg', 'JPEG Image'}, 'Simpan Citra');
    figure(fig);
    if isequal(file, 0), return; end
    
    try
        imwrite(img_out, fullfile(path, file));
    catch ME
        uialert(fig, sprintf('Gagal menyimpan berkas citra:\n%s', ME.message), 'Kesalahan Penyimpanan');
    end
end

% --------------- HELPERS FUNCTIONS ---------------- %

function display_image(ax, img)
    if size(img, 3) == 1
        % Citra Grayscale (2D) perlu direplikasi ke 3 kanal agar dirender sebagai TrueColor Grayscale
        % dan tidak terpengaruh oleh default colormap (Parula / Jet) pada uiaxes
        image(ax, repmat(img, [1, 1, 3]));
    else
        image(ax, img);
    end
    axis(ax, 'image');
    axis(ax, 'off');
end

function render_histogram(ax, img)
    cla(ax);
    counts = my_histogram(img);
    x = 0:255;
    
    % Deteksi kecerahan background axes untuk memilih warna dengan kontras tinggi
    bg_color = ax.Color;
    is_dark_bg = false;
    if isnumeric(bg_color) && numel(bg_color) == 3
        is_dark_bg = (mean(bg_color) < 0.5);
    end
    
    hold(ax, 'on');
    if size(img, 3) == 3
        % Warna kurva RGB yang cerah dan kontras tinggi
        if is_dark_bg
            plot(ax, x, counts(:, 1), 'Color', [1.0 0.3 0.3], 'LineWidth', 1.5); % Merah Cerah
            plot(ax, x, counts(:, 2), 'Color', [0.3 0.9 0.3], 'LineWidth', 1.5); % Hijau Cerah
            plot(ax, x, counts(:, 3), 'Color', [0.3 0.6 1.0], 'LineWidth', 1.5); % Biru Cerah
        else
            plot(ax, x, counts(:, 1), 'Color', [0.85 0.1 0.1], 'LineWidth', 1.5); % Merah Pekat
            plot(ax, x, counts(:, 2), 'Color', [0.1 0.7 0.2], 'LineWidth', 1.5); % Hijau Pekat
            plot(ax, x, counts(:, 3), 'Color', [0.1 0.3 0.9], 'LineWidth', 1.5); % Biru Pekat
        end
    else
        % Citra Grayscale: gunakan warna biru royal / cyan yang kontras tinggi (bukan hitam polos)
        if is_dark_bg
            gray_curve_color = [0.2 0.85 1.0]; % Cyan cerah untuk background gelap
        else
            gray_curve_color = [0.0 0.45 0.85]; % Royal blue untuk background terang
        end
        plot(ax, x, counts(:, 1), 'Color', gray_curve_color, 'LineWidth', 1.6);
    end
    hold(ax, 'off');
    
    xlim(ax, [0 255]);
    grid(ax, 'on');
    ax.GridAlpha = 0.25;
end