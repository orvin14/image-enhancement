function main_gui()
    % GUI Perbaikan Citra

    [current_dir, ~, ~] = fileparts(mfilename('fullpath'));
    addpath(genpath(fullfile(current_dir, '..')));
    
    % Main Window
    fig = uifigure('Name', 'IF4073 - Aplikasi Image Enhancement', ...
                    'Position', [50 50 1280 720]);

    % Left Panel
    pnl_control = uipanel(fig, 'Title', 'Perbaikan Citra', ...
                           'Position', [20 20 280 680]);

    % Tombol Muat Citra
    uibutton(pnl_control, 'Text', 'Muat Citra Uji', ...
             'Position', [20 610 240 32], ...
             'ButtonPushedFcn', @(btn, event) cb_load_image(fig));

    uibutton(pnl_control, 'Text', 'Muat Citra Referensi', ...
             'Position', [20 570 240 32], ...
             'ButtonPushedFcn', @(btn, event) cb_load_ref_image(fig));

    % Dropdown Metode Enhancement
    uilabel(pnl_control, 'Text', 'Pilih Kategori Metode:', ...
            'Position', [20 530 240 20]);
    dd_category = uidropdown(pnl_control, ...
        'Items', {'Analisis / Validasi Histogram', 'Intensity Transformation', ...
                  'Histogram Equalization', 'Histogram Matching', 'Image Filtering'}, ...
        'Position', [20 505 240 25], ...
        'ValueChangedFcn', @(dd, event) cb_category_changed(fig));

    % Method Dropdown
    uilabel(pnl_control, 'Text', 'Pilih Teknik Spesifik:', ...
            'Position', [20 470 240 20]);
    dd_method = uidropdown(pnl_control, ...
        'Items', {'Validasi Histogram & Metrik Awal'}, ...
        'Position', [20 445 240 25], ...
        'ValueChangedFcn', @(dd, event) cb_method_changed(fig));

    % Dynamic Parameter Input Panel
    pnl_params = uipanel(pnl_control, 'Title', 'Pengaturan Parameter', ...
                         'Position', [15 315 250 120]);

    % 1. Standard Numeric Parameter (Gamma, Kernel Size, Sigma, Alpha)
    lbl_param = uilabel(pnl_params, 'Text', 'Ukuran Kernel:', ...
                        'Position', [10 65 220 20]);
    ef_param = uieditfield(pnl_params, 'numeric', ...
                          'Value', 3, ...
                          'Position', [10 40 220 24]);

    % 2. Custom Kernel Matrix Input (Multi-line text area)
    lbl_custom = uilabel(pnl_params, 'Text', 'Kernel Matrix (Tiap baris dienter):', ...
                         'Position', [10 65 220 20], ...
                         'Visible', 'off');
    txt_custom = uitextarea(pnl_params, ...
                            'Value', {'-1, 0, 1'; '-2, 0, 2'; '-1, 0, 1'}, ...
                            'Position', [10 10 220 55], ...
                            'Visible', 'off');

    % Action Buttons
    uibutton(pnl_control, 'Text', 'Jalankan Enhancement', ...
             'Position', [20 265 240 38], ...
             'BackgroundColor', [0.2 0.6 0.2], ...
             'FontColor', [1 1 1], ...
             'FontWeight', 'bold', ...
             'ButtonPushedFcn', @(btn, event) cb_process_image(fig));

    uibutton(pnl_control, 'Text', 'Simpan Citra Hasil', ...
             'Position', [20 220 240 32], ...
             'ButtonPushedFcn', @(btn, event) cb_save_image(fig));

    % Statistik Fitur Citra
    uilabel(pnl_control, 'Text', 'Statistik Citra (Output):', ...
            'Position', [20 185 240 20]);
    txt_stats = uitextarea(pnl_control, ...
                'Position', [20 15 240 165], ...
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
    setappdata(fig, 'txt_stats', txt_stats);
end

% ---------------- CALLBACKS FUNCTIONS ----------------- 

function cb_category_changed(fig)
    dd_category = getappdata(fig, 'dd_category');
    dd_method = getappdata(fig, 'dd_method');
    
    switch dd_category.Value
        case 'Analisis / Validasi Histogram'
            dd_method.Items = {'Validasi Histogram & Metrik Awal'};
        case 'Intensity Transformation'
            dd_method.Items = {'Contrast Stretching', 'Log Transformation', 'Gamma Correction'};
        case 'Histogram Equalization'
            dd_method.Items = {'Histogram Equalization Standard'};
        case 'Histogram Matching'
            dd_method.Items = {'Histogram Specification/Matching'};
        case 'Image Filtering'
            dd_method.Items = {'Mean Filter', 'Gaussian Filter', 'Sharpening Filter', ...
                               'Median Filter', 'Min Filter', 'Max Filter', 'Custom Kernel Convolution'};
    end
    cb_method_changed(fig);
end

function cb_method_changed(fig)
    dd_method  = getappdata(fig, 'dd_method');
    lbl_param  = getappdata(fig, 'lbl_param');
    ef_param   = getappdata(fig, 'ef_param');
    lbl_custom = getappdata(fig, 'lbl_custom');
    txt_custom = getappdata(fig, 'txt_custom');
    
    method = dd_method.Value;

    % Toggle between standard scalar parameter and custom 2D matrix box
    if strcmp(method, 'Custom Kernel Convolution')
        lbl_param.Visible  = 'off';
        ef_param.Visible   = 'off';
        lbl_custom.Visible = 'on';
        txt_custom.Visible = 'on';
    else
        lbl_param.Visible  = 'on';
        ef_param.Visible   = 'on';
        lbl_custom.Visible = 'off';
        txt_custom.Visible = 'off';

        switch method
            case 'Gaussian Filter'
                lbl_param.Text = 'Nilai Sigma (σ):';
                ef_param.Value = 1.0;
            case 'Sharpening Filter'
                lbl_param.Text = 'Alpha (0:HPF, 1:UM, >1:Boost):';
                ef_param.Value = 1.0;
            case {'Mean Filter', 'Median Filter', 'Min Filter', 'Max Filter'}
                lbl_param.Text = 'Ukuran Window (Ganjil):';
                ef_param.Value = 3;
            case 'Gamma Correction'
                lbl_param.Text = 'Nilai Gamma (γ):';
                ef_param.Value = 1.0;
            otherwise
                lbl_param.Text = 'Parameter (Opsional):';
                ef_param.Value = 1.0;
        end
    end
end

function cb_load_image(fig)
    [file, path] = uigetfile({'*.png;*.jpg;*.bmp;*.tif', 'Berkas Citra (*.png, *.jpg, *.bmp, *.tif)'});
    if isequal(file, 0), return; end
    
    img = imread(fullfile(path, file));
    setappdata(fig, 'img_in', img);
    
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
end

function cb_load_ref_image(fig)
    [file, path] = uigetfile({'*.png;*.jpg;*.bmp;*.tif', 'Berkas Citra Referensi'});
    if isequal(file, 0), return; end
    
    img_ref = imread(fullfile(path, file));
    setappdata(fig, 'img_ref', img_ref);
    
    ax_ref = getappdata(fig, 'ax_ref');
    display_image(ax_ref, img_ref);
end

function cb_process_image(fig)
    img_in = getappdata(fig, 'img_in');
    if isempty(img_in)
        uialert(fig, 'Silakan muat citra masukan terlebih dahulu!', 'Peringatan');
        return;
    end
    
    dd_category = getappdata(fig, 'dd_category');
    dd_method   = getappdata(fig, 'dd_method');
    ef_param    = getappdata(fig, 'ef_param');
    txt_custom  = getappdata(fig, 'txt_custom');
    
    cat = dd_category.Value;
    method = dd_method.Value;
    param_val = ef_param.Value;
    
    switch cat
        case 'Analisis / Validasi Histogram'
            img_out = img_in;
            
        case 'Intensity Transformation'
            if strcmp(method, 'Contrast Stretching')
                img_out = intensity_transform(img_in, 'contrast_stretching');
            elseif strcmp(method, 'Log Transformation')
                img_out = intensity_transform(img_in, 'log');
            else
                img_out = intensity_transform(img_in, 'gamma', param_val);
            end
            
        case 'Histogram Equalization'
            img_out = my_histeq(img_in);
            
        case 'Histogram Matching'
            img_ref = getappdata(fig, 'img_ref');
            if isempty(img_ref)
                uialert(fig, 'Muat citra referensi terlebih dahulu!', 'Peringatan');
                return;
            end
            img_out = my_histmatch(img_in, img_ref);
            
        case 'Image Filtering'
            switch method
                case 'Mean Filter'
                    kLen = round(param_val);
                    if mod(kLen, 2) == 0, kLen = kLen + 1; end
                    img_out = uint8(mean_filter(img_in, kLen));
                    
                case 'Gaussian Filter'
                    [res, ~] = gaussian_filter(img_in, param_val);
                    img_out = uint8(res);
                    
                case 'Sharpening Filter'
                    res = sharpen_filter(img_in, param_val);
                    img_out = uint8(res);
                    
                case 'Median Filter'
                    kLen = round(param_val);
                    if mod(kLen, 2) == 0, kLen = kLen + 1; end
                    img_out = uint8(median_filter(img_in, kLen));
                    
                case 'Min Filter'
                    kLen = round(param_val);
                    img_out = uint8(min_filter(img_in, kLen));
                    
                case 'Max Filter'
                    kLen = round(param_val);
                    img_out = uint8(max_filter(img_in, kLen));
                    
                case 'Custom Kernel Convolution'
                    try
                        lines = txt_custom.Value;
                        if ischar(lines), lines = cellstr(lines); end
                        
                        % Hapus baris kosong
                        lines = strtrim(lines);
                        lines = lines(~cellfun('isempty', lines));
                        
                        numRows = numel(lines);
                        if numRows < 1
                            error('Matriks kernel tidak boleh kosong.');
                        end
                        
                        % Parse baris pertama untuk menentukan jumlah kolom
                        firstRow = sscanf(strrep(lines{1}, ',', ' '), '%f')';
                        numCols = numel(firstRow);
                        if numCols < 1
                            error('Baris pertama tidak valid.');
                        end
                        
                        user_kernel = zeros(numRows, numCols);
                        user_kernel(1, :) = firstRow;
                        
                        % Parse baris berikutnya dan validasi keseragaman ukuran
                        for r = 2:numRows
                            rowVals = sscanf(strrep(lines{r}, ',', ' '), '%f')';
                            if numel(rowVals) ~= numCols
                                error('Jumlah kolom pada baris %d tidak seragam (%d vs %d).', ...
                                      r, numel(rowVals), numCols);
                            end
                            user_kernel(r, :) = rowVals;
                        end
                    catch ME
                        uialert(fig, sprintf('Format matriks kernel salah:\n%s\n\nContoh:\n-1, 0, 1\n-2, 0, 2\n-1, 0, 1', ME.message), ...
                                'Error Kernel');
                        return;
                    end
                    
                    res = my_conv(double(img_in), user_kernel, 'replicate');
                    img_out = uint8(max(0, min(255, res)));
            end
    end
    
    setappdata(fig, 'img_out', img_out);
    
    % Tampilkan Hasil Citra dan Histogram
    ax_out = getappdata(fig, 'ax_out');
    ax_hist_out = getappdata(fig, 'ax_hist_out');
    
    display_image(ax_out, img_out);
    render_histogram(ax_hist_out, img_out);
    
    % Tampilkan Statistik Fitur Citra
    stats = compute_metrics(img_out);
    txt_stats = getappdata(fig, 'txt_stats');
    
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

function cb_save_image(fig)
    img_out = getappdata(fig, 'img_out');
    if isempty(img_out)
        uialert(fig, 'Belum ada hasil pemrosesan untuk disimpan!', 'Peringatan');
        return;
    end
    
    [file, path] = uiputfile({'*.png', 'PNG Image'; '*.jpg', 'JPEG Image'}, 'Simpan Citra');
    if isequal(file, 0), return; end
    
    imwrite(img_out, fullfile(path, file));
end

% --------------- HELPERS FUNCTIONS ---------------- %

function display_image(ax, img)
    image(ax, img);
    axis(ax, 'image');
    axis(ax, 'off');
end

function render_histogram(ax, img)
    cla(ax);
    counts = my_histogram(img);
    x = 0:255;
    
    hold(ax, 'on');
    if size(img, 3) == 3
        plot(ax, x, counts(:, 1), 'r', 'LineWidth', 1.2);
        plot(ax, x, counts(:, 2), 'g', 'LineWidth', 1.2);
        plot(ax, x, counts(:, 3), 'b', 'LineWidth', 1.2);
    else
        plot(ax, x, counts(:, 1), 'k', 'LineWidth', 1.2);
    end
    hold(ax, 'off');
    
    xlim(ax, [0 255]);
    grid(ax, 'on');
end