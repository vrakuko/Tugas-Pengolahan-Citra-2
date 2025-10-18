% =========================================================================
%           SKRIP PENGUJIAN ROBUST UNTUK FUNGSI tapisFreq.m
% =========================================================================
% Deskripsi:
% Skrip ini dirancang untuk menjadi satu-satunya file uji yang Anda
% perlukan. Ia akan meminta Anda memilih file gambar, secara otomatis
% menangani konversi tipe data, dan menerapkan semua filter frekuensi
% pada citra grayscale dan berwarna.
%
% Cukup jalankan file ini dari Matlab.
% Pastikan file 'tapisFreq.m' ada di folder yang sama.
% =========================================================================

clear;
clc;
close all;

fprintf('--- Skrip Pengujian Robust untuk tapisFreq.m ---\n');

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

    % 2. Tambahkan derau
    imgNoisy = imnoise(imgOri, 'gaussian', 0, 0.01);

    % 3. Buat filter dinamis sesuai ukuran citra
    D0 = 30; % Cutoff frequency
    n_butter = 2; % Orde Butterworth

    [U, V] = meshgrid(1:N, 1:M);
    D = sqrt((U - N/2).^2 + (V - M/2).^2);

    H_ilpf = double(D <= D0);
    H_glpf = exp(-(D.^2) / (2 * D0^2));
    H_blpf = 1 ./ (1 + (D ./ D0).^(2 * n_butter));

    % 4. Terapkan filter
    imgFiltered_ilpf = zeros(size(imgOri), 'uint8');
    imgFiltered_glpf = zeros(size(imgOri), 'uint8');
    imgFiltered_blpf = zeros(size(imgOri), 'uint8');

    if C == 3 % Jika citra berwarna
        fprintf('Menerapkan filter pada 3 channel warna...\n');
        for channel = 1:3
            imgFiltered_ilpf(:,:,channel) = tapisFreq(imgNoisy(:,:,channel), H_ilpf);
            imgFiltered_glpf(:,:,channel) = tapisFreq(imgNoisy(:,:,channel), H_glpf);
            imgFiltered_blpf(:,:,channel) = tapisFreq(imgNoisy(:,:,channel), H_blpf);
        end
    else % Jika citra grayscale
        fprintf('Menerapkan filter pada 1 channel grayscale...\n');
        imgFiltered_ilpf = tapisFreq(imgNoisy, H_ilpf);
        imgFiltered_glpf = tapisFreq(imgNoisy, H_glpf);
        imgFiltered_blpf = tapisFreq(imgNoisy, H_blpf);
    end

    % 5. Tampilkan hasil
    figure('Name', ['Hasil Filter Frekuensi - ' tipe], 'NumberTitle', 'off');
    subplot(2, 3, 1); imshow(imgOri); title('Citra Asli');
    subplot(2, 3, 2); imshow(imgNoisy); title('Citra dengan Derau');
    subplot(2, 3, 3); imshow(H_glpf, []); title('Contoh Mask (GLPF)');
    subplot(2, 3, 4); imshow(imgFiltered_ilpf); title('Hasil ILPF');
    subplot(2, 3, 5); imshow(imgFiltered_glpf); title('Hasil GLPF');
    subplot(2, 3, 6); imshow(imgFiltered_blpf); title('Hasil BLPF');
    sgtitle(['Pengujian pada Citra ' tipe], 'FontSize', 14, 'FontWeight', 'bold');
end

% --- FUNGSI PEMBANTU UNTUK MEMUAT CITRA ---
function [imgOut, M, N, C] = muatDanProsesCitra(pathFile)
    % Fungsi ini memuat citra dan menanganani berbagai kasus (indexed, rgb, gray)
    if ~exist(pathFile, 'file')
        error('File tidak ditemukan: %s', pathFile);
    end
    [imgData, map] = imread(pathFile);

    % Konversi dari indexed image ke RGB jika diperlukan
    if ~isempty(map)
        fprintf('Info: Citra adalah "Indexed", mengonversi ke RGB.\n');
        imgData = ind2rgb(imgData, map);
    end

    % Pastikan tipe data uint8 untuk konsistensi sebelum menambah derau
    if ~isa(imgData, 'uint8')
        imgData = im2uint8(imgData);
    end

    % Jika citra grayscale dibaca sebagai RGB, konversi ke grayscale asli
    if size(imgData,3) == 3 && ...
       isequal(imgData(:,:,1), imgData(:,:,2)) && ...
       isequal(imgData(:,:,2), imgData(:,:,3))
       fprintf('Info: Citra RGB terdeteksi sebagai grayscale, mengonversi ke 2D.\n');
       imgData = rgb2gray(imgData);
    end

    imgOut = imgData;
    [M, N, C] = size(imgOut);
end