function main_gui()
    % MAIN_GUI Aplikasi utama Pemrosesan Citra Digital berbasis MATLAB GUI.
    
    % Main Window
    fig = uifigure('Name', 'IF4073 - Aplikasi Image Enhancement', ...
                    'Position', [50 50 1200 680]);

    % Left Panel
    pnl_control = uipanel(fig, 'Title', 'Panel Kontrol', ...
                           'Position', [20 20 280 640]);

    % Tombol Muat Citra
    uibutton(pnl_control, 'Text', 'Muat Citra Uji', ...
             'Position', [20 570 240 35], ...
             'ButtonPushedFcn', @(btn, event) cb_load_image(fig));

    uibutton(pnl_control, 'Text', 'Muat Citra Referensi', ...
             'Position', [20 525 240 35], ...
             'ButtonPushedFcn', @(btn, event) cb_load_ref_image(fig));

    % Dropdown Metode Enhancement
    uilabel(pnl_control, 'Text', 'Pilih Kategori Metode:', ...
            'Position', [20 480 240 22]);
    dd_category = uidropdown(pnl_control, ...
        'Items', {'Analisis / Validasi Histogram', 'Intensity Transformation', ...
                  'Histogram Equalization', 'Histogram Matching', 'Image Filtering'}, ...
        'Position', [20 455 240 25], ...
        'ValueChangedFcn', @(dd, event) cb_category_changed(fig));

    uilabel(pnl_control, 'Text', 'Pilih Teknik Spesifik:', ...
            'Position', [20 415 240 22]);
    dd_method = uidropdown(pnl_control, ...
        'Items', {'Validasi Histogram & Metrik Awal'}, ...
        'Position', [20 390 240 25]);

    % Input Parameter
    lbl_param = uilabel(pnl_control, 'Text', 'Parameter (Gamma/Kernel):', ...
                        'Position', [20 350 240 22]);
    ef_param = uieditfield(pnl_control, 'numeric', ...
                          'Value', 1.0, ...
                          'Position', [20 325 240 25]);

    % Tombol Eksekusi
    uibutton(pnl_control, 'Text', 'Jalankan Enhancement', ...
             'Position', [20 260 240 40], ...
             'BackgroundColor', [0.2 0.6 0.2], ...
             'FontColor', [1 1 1], ...
             'ButtonPushedFcn', @(btn, event) cb_process_image(fig));

    % Tombol Simpan Hasil
    uibutton(pnl_control, 'Text', 'Simpan Citra Hasil', ...
             'Position', [20 210 240 35], ...
             'ButtonPushedFcn', @(btn, event) cb_save_image(fig));

    % Statistik Fitur Citra
    uilabel(pnl_control, 'Text', 'Statistik Citra (Output):', ...
            'Position', [20 170 240 22]);
    txt_stats = uitextarea(pnl_control, ...
                'Position', [20 20 240 145], ...
                'Editable', 'off');

    % Visualisasi Citra dan Histogram
    ax_in = uiaxes(fig, 'Position', [320 360 260 260]);
    title(ax_in, 'Citra Masukan');

    ax_out = uiaxes(fig, 'Position', [600 360 260 260]);
    title(ax_out, 'Citra Hasil');

    ax_ref = uiaxes(fig, 'Position', [880 360 260 260]);
    title(ax_ref, 'Citra Referensi');

    ax_hist_in = uiaxes(fig, 'Position', [320 50 410 260]);
    title(ax_hist_in, 'Histogram Masukan');

    ax_hist_out = uiaxes(fig, 'Position', [750 50 410 260]);
    title(ax_hist_out, 'Histogram Hasil');

    % Simpan objek UI ke appdata
    setappdata(fig, 'ax_in', ax_in);
    setappdata(fig, 'ax_out', ax_out);
    setappdata(fig, 'ax_ref', ax_ref);
    setappdata(fig, 'ax_hist_in', ax_hist_in);
    setappdata(fig, 'ax_hist_out', ax_hist_out);
    setappdata(fig, 'dd_category', dd_category);
    setappdata(fig, 'dd_method', dd_method);
    setappdata(fig, 'ef_param', ef_param);
    setappdata(fig, 'txt_stats', txt_stats);
end

% CALLBACK FUNCTIONS

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
            dd_method.Items = {'Mean Filter', 'Gaussian Filter', 'Sharpening Filter', 'Median Filter'};
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
    
    % Hitung & tampilkan fitur/metrik awal citra masukan
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
    dd_method = getappdata(fig, 'dd_method');
    ef_param = getappdata(fig, 'ef_param');
    
    cat = dd_category.Value;
    method = dd_method.Value;
    param_val = ef_param.Value;
    
    % Pemrosesan berdasarkan kategori
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
            if strcmp(method, 'Mean Filter')
                img_out = image_filtering(img_in, 'mean', param_val);
            elseif strcmp(method, 'Gaussian Filter')
                img_out = image_filtering(img_in, 'gaussian', 5, param_val);
            elseif strcmp(method, 'Sharpening Filter')
                img_out = image_filtering(img_in, 'sharpen', 3);
            else
                img_out = image_filtering(img_in, 'median', param_val);
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

% HELPER FUNCTIONS

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