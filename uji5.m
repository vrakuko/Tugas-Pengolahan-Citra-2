% =========================================================================
%       PROGRAM PENGHILANGAN DERAU (DENOISING) DENGAN BERBAGAI FILTER
% =========================================================================
% Deskripsi:
% Skrip ini menerapkan 9 jenis filter spasial untuk menghilangkan derau
% Salt & Pepper dan Gaussian pada citra grayscale dan berwarna.
%
% Constraint: Tidak menggunakan fungsi filter bawaan seperti medfilt2.
%
% Cukup jalankan file ini dari Matlab.
% =========================================================================

clear;
clc;
close all;

fprintf('--- Program Uji Filter Denoising ---\n');

% --- LANGKAH 1: PILIH CITRA ---
[file, path] = uigetfile({'*.png';'*.jpg';'*.tif';'*.bmp';'*.*'}, 'Pilih sebuah Citra untuk Diuji');
if isequal(file, 0)
    disp('Pemilihan file dibatalkan. Skrip berhenti.');
    return;
end
pathLengkapFile = fullfile(path, file);

try
    % --- LANGKAH 2: UJI DENGAN DERAU SALT & PEPPER ---
    fprintf('\n[SESI 1] Menguji penghilangan derau "Salt & Pepper"...\n');
    jalankanUjiFilter(pathLengkapFile, 'salt & pepper');

    % --- LANGKAH 3: UJI DENGAN DERAU GAUSSIAN ---
    fprintf('\n[SESI 2] Menguji penghilangan derau "Gaussian"...\n');
    jalankanUjiFilter(pathLengkapFile, 'gaussian');
    
    fprintf('\n--- Semua pengujian selesai ---\n');
catch ME
    fprintf('\nTERJADI ERROR FATAL:\n');
    fprintf('Pesan: %s\n', ME.message);
    fprintf('Error terjadi di file: %s, baris: %d\n', ME.stack(1).name, ME.stack(1).line);
end


% =========================================================================
%                     FUNGSI-FUNGSI PEMBANTU (LOKAL)
% =========================================================================

function jalankanUjiFilter(pathLengkapFile, tipeNoise)
    % Fungsi ini menjalankan seluruh proses: memuat, memberi derau, 
    % memfilter, dan menampilkan hasil untuk satu jenis derau.

    % Pengaturan Filter
    n = 3; % Ukuran filter n x n (coba 3, 5, atau 7)
    Q = 1.5; % Parameter untuk Contraharmonic filter
    d = 2;   % Parameter untuk Alpha-trimmed filter (harus (n*n-1)/2 > d)

    % 1. Muat Citra
    imgOri = imread(pathLengkapFile);

    % 2. Tambah Derau
    if strcmp(tipeNoise, 'salt & pepper')
        density = 0.05; % Kepadatan derau
        imgNoisy = imnoise(imgOri, 'salt & pepper', density);
    elseif strcmp(tipeNoise, 'gaussian')
        mean_val = 0;
        variance = 0.01;
        imgNoisy = imnoise(imgOri, 'gaussian', mean_val, variance);
    else
        error('Tipe derau tidak dikenal.');
    end

    % 3. Terapkan semua 9 Filter
    fprintf('Menerapkan filter untuk derau %s...\n', tipeNoise);
    
    % Order-Statistic Filters
    img_min      = filterSpasialManual(imgNoisy, n, 'min');
    img_max      = filterSpasialManual(imgNoisy, n, 'max');
    img_median   = filterSpasialManual(imgNoisy, n, 'median');
    img_midpoint = filterSpasialManual(imgNoisy, n, 'midpoint');
    img_alpha    = filterSpasialManual(imgNoisy, n, 'alpha', d);
    
    % Mean Filters
    img_arith    = filterSpasialManual(imgNoisy, n, 'arithmetic');
    img_geo      = filterSpasialManual(imgNoisy, n, 'geometric');
    img_harmo    = filterSpasialManual(imgNoisy, n, 'harmonic');
    img_contra   = filterSpasialManual(imgNoisy, n, 'contraharmonic', Q);
    
    fprintf('Filter selesai diterapkan.\n');

    % 4. Tampilkan Hasil
    % Window 1: Order-Statistic Filters
    figure('Name', ['Hasil Filter Statistik Urutan (Derau: ' tipeNoise ')'], 'NumberTitle', 'off');
    subplot(3, 3, 1); imshow(imgOri); title('Citra Asli');
    subplot(3, 3, 2); imshow(imgNoisy); title(['Derau ' tipeNoise]);
    subplot(3, 3, 3); imshow(img_median); title('Median Filter');
    subplot(3, 3, 4); imshow(img_min); title('Min Filter');
    subplot(3, 3, 5); imshow(img_max); title('Max Filter');
    subplot(3, 3, 6); imshow(img_midpoint); title('Midpoint Filter');
    subplot(3, 3, 7); imshow(img_alpha); title(['Alpha-Trimmed (d=' num2str(d) ')']);
    
    % Window 2: Mean Filters
    figure('Name', ['Hasil Filter Rata-Rata (Derau: ' tipeNoise ')'], 'NumberTitle', 'off');
    subplot(2, 3, 1); imshow(imgOri); title('Citra Asli');
    subplot(2, 3, 2); imshow(imgNoisy); title(['Derau ' tipeNoise]);
    subplot(2, 3, 3); imshow(img_arith); title('Arithmetic Mean');
    subplot(2, 3, 4); imshow(img_geo); title('Geometric Mean');
    subplot(2, 3, 5); imshow(img_harmo); title('Harmonic Mean');
    subplot(2, 3, 6); imshow(img_contra); title(['Contraharmonic (Q=' num2str(Q) ')']);
end


