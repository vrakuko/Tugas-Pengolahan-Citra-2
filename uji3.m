% =========================================================================
%        SKRIP PENGUJIAN ROBUST UNTUK HIGH-PASS FILTER (IHPF, GHPF, BHPF)
% =========================================================================
% Deskripsi:
% Skrip ini melakukan penapisan high-pass pada ranah frekuensi untuk
% penajaman citra dan deteksi tepi.
%
% Cukup jalankan file ini dari Matlab.
% Pastikan file 'tapisFreq.m' ada di folder yang sama.
% =========================================================================

clear;
clc;
close all;

fprintf('--- Skrip Pengujian High-Pass Filter untuk tapisFreq.m ---\n');

try
    % --- LANGKAH 1: UJI CITRA GRAYSCALE ---
    fprintf('\n[LANGKAH 1 dari 2]\n');
    [fileGray, pathGray] = uigetfile({'*.png';'*.jpg';'*.tif';'*.bmp';'*.*'}, 'Pilih sebuah Citra Grayscale untuk Diuji');
    if isequal(fileGray, 0)
        disp('Pemilihan file dibatalkan. Skrip berhenti.');
        return;
    end
    ujiCitra(fullfile(pathGray, fileGray), 'Grayscale');

    % --- LANGKAH 2: UJI CITRA BERWARNA ---
    fprintf('\n[LANGKAH 2 dari 2]\n');
    [fileColor, pathColor] = uigetfile({'*.png';'*.jpg';'*.tif';'*.bmp';'*.*'}, 'Pilih sebuah Citra Berwarna untuk Diuji');
    if isequal(fileColor, 0)
        disp('Pemilihan file dibatalkan. Skrip berhenti.');
        return;
    end
    ujiCitra(fullfile(pathColor, fileColor), 'Berwarna');
    
    fprintf('\n--- Pengujian Selesai ---\n');

catch ME
    fprintf('\nTERJADI ERROR FATAL:\n');
    fprintf('Pesan: %s\n', ME.message);
    fprintf('Error terjadi di file: %s, baris: %d\n', ME.stack(1).name, ME.stack(1).line);
end


% --- FUNGSI UTAMA PENGUJIAN ---
function ujiCitra(pathLengkapFile, tipe)
    fprintf('\nMemproses citra %s: %s\n', tipe, pathLengkapFile);
    
    % 1. Muat dan siapkan citra secara robust
    [imgOri, M, N, C] = muatDanProsesCitra(pathLengkapFile);
    fprintf('Info: Ukuran citra adalah %d x %d x %d.\n', M, N, C);

    % 2. Buat filter dinamis sesuai ukuran citra
    D0 = 30; % Frekuensi cutoff. Makin TINGGI, makin sedikit fitur yang terdeteksi.
    n_butter = 2; % Orde Butterworth
    
    [U, V] = meshgrid(1:N, 1:M);
    D = sqrt((U - N/2).^2 + (V - M/2).^2);
    
    % Buat filter Low-Pass sebagai dasar
    H_ilpf_base = double(D <= D0);
    H_glpf_base = exp(-(D.^2) / (2 * D0^2));
    H_blpf_base = 1 ./ (1 + (D ./ D0).^(2 * n_butter));

    % Buat High-Pass Filter dengan membalik Low-Pass Filter: H_hpf = 1 - H_lpf
    H_ihpf = 1 - H_ilpf_base;
    H_ghpf = 1 - H_glpf_base;
    H_bhpf = 1 - H_blpf_base;

    % 3. Terapkan filter
    imgFiltered_ihpf = zeros(size(imgOri), 'uint8');
    imgFiltered_ghpf = zeros(size(imgOri), 'uint8');
    imgFiltered_bhpf = zeros(size(imgOri), 'uint8');
    
    if C == 3 % Jika citra berwarna
        fprintf('Menerapkan filter pada 3 channel warna...\n');
        for channel = 1:3
            imgFiltered_ihpf(:,:,channel) = tapisFreq(imgOri(:,:,channel), H_ihpf);
            imgFiltered_ghpf(:,:,channel) = tapisFreq(imgOri(:,:,channel), H_ghpf);
            imgFiltered_bhpf(:,:,channel) = tapisFreq(imgOri(:,:,channel), H_bhpf);
        end
    else % Jika citra grayscale
        fprintf('Menerapkan filter pada 1 channel grayscale...\n');
        imgFiltered_ihpf = tapisFreq(imgOri, H_ihpf);
        imgFiltered_ghpf = tapisFreq(imgOri, H_ghpf);
        imgFiltered_bhpf = tapisFreq(imgOri, H_bhpf);
    end
    
    % 4. Buat contoh citra yang ditajamkan (Sharpened Image) menggunakan High-Boost
    k = 1.5; % Faktor boost, k > 1. Coba ubah antara 1.0 - 2.5
    imgSharpened = imadd(imgOri, imresize(imgFiltered_ghpf, [M N])); % Menambahkan hasil filter ke citra asli
    
    % 5. Tampilkan hasil
    figure('Name', ['Hasil Filter High-Pass - ' tipe], 'NumberTitle', 'off');
    subplot(2, 3, 1); imshow(imgOri); title('Citra Asli');
    subplot(2, 3, 2); imshow(H_ghpf, []); title('Contoh Mask (GHPF)');
    subplot(2, 3, 3); imshow(imgSharpened); title(['Citra Ditajamkan (k=' num2str(k) ')']);
    subplot(2, 3, 4); imshow(imgFiltered_ihpf); title('Hasil IHPF');
    subplot(2, 3, 5); imshow(imgFiltered_ghpf); title('Hasil GHPF');
    subplot(2, 3, 6); imshow(imgFiltered_bhpf); title('Hasil BHPF');
    sgtitle(['Pengujian High-Pass pada Citra ' tipe], 'FontSize', 14, 'FontWeight', 'bold');
end

% --- FUNGSI PEMBANTU UNTUK MEMUAT CITRA ---
function [imgOut, M, N, C] = muatDanProsesCitra(pathFile)
    % Fungsi ini memuat citra dan menanganani berbagai kasus (indexed, rgb, gray)
    if ~exist(pathFile, 'file')
        error('File tidak ditemukan: %s', pathFile);
    end
    [imgData, map] = imread(pathFile);

    if ~isempty(map)
        fprintf('Info: Citra adalah "Indexed", mengonversi ke RGB.\n');
        imgData = ind2rgb(imgData, map);
    end
    
    if ~isa(imgData, 'uint8')
        imgData = im2uint8(imgData);
    end
    
    [M, N, C] = size(imgData);
    
    % Untuk uji high-pass, kita tidak perlu memaksa konversi ke grayscale
    % jika citra aslinya memang RGB yang terlihat abu-abu.
    
    imgOut = imgData;
end