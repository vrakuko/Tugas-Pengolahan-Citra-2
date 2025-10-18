% =========================================================================
%       PROGRAM PENAPISAN HOMOMORFIK UNTUK PENERANGAN CITRA
% =========================================================================
% Deskripsi:
% Skrip ini menerapkan filter homomorfik untuk menyeimbangkan pencahayaan
% (iluminasi) dan menonjolkan detail (reflektansi) pada citra.
% =========================================================================

clear;
clc;
close all;

fprintf('--- Program Penapisan Homomorfik ---\n');

% --- LANGKAH 1: PILIH CITRA ---
[file, path] = uigetfile({'*.png';'*.jpg';'*.tif';'*.bmp';'*.*'}, 'Pilih sebuah Citra untuk Diuji');
if isequal(file, 0)
    disp('Pemilihan file dibatalkan. Skrip berhenti.');
    return;
end
pathLengkapFile = fullfile(path, file);

% --- LANGKAH 2: PROSES CITRA ---
try
    % Muat citra dan konversi ke double untuk perhitungan
    imgOri = im2double(imread(pathLengkapFile));

    % Terapkan filter homomorfik
    imgFiltered = filterHomomorphic(imgOri);

    % Tampilkan Hasil
    figure('Name', 'Hasil Penapisan Homomorfik', 'NumberTitle', 'off');
    subplot(1, 2, 1); imshow(imgOri); title('Citra Asli');
    subplot(1, 2, 2); imshow(imgFiltered); title('Hasil Filter Homomorfik');

catch ME
    fprintf('\nTERJADI ERROR:\n');
    fprintf('Pesan: %s\n', ME.message);
end


