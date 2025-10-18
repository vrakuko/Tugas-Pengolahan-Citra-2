function imgFiltered = filterSpasialManual(img, n, tipeFilter, varargin)
    % Fungsi inti yang melakukan pemrosesan neighborhood (sliding window)
    % untuk semua jenis filter yang diminta.

    [M, N, C] = size(img);
    imgFiltered = zeros(M, N, C, 'like', img);
    padSize = floor(n/2);

    for c = 1:C % Loop untuk setiap channel warna (jika ada)
        
        channel = img(:, :, c);
        channelPadded = padarray(channel, [padSize padSize], 'replicate');
        channelFiltered = zeros(M, N, 'double');
        
        % Konversi ke double untuk perhitungan
        channelPadded = im2double(channelPadded);

        for i = 1:M
            for j = 1:N
                % Ekstrak neighborhood (window) n x n
                window = channelPadded(i : i+n-1, j : j+n-1);
                vec = window(:); % Ubah window menjadi vektor 1D
                
                % Terapkan operasi filter yang dipilih
                switch lower(tipeFilter)
                    case 'min'
                        channelFiltered(i,j) = min(vec);
                    case 'max'
                        channelFiltered(i,j) = max(vec);
                    case 'median'
                        channelFiltered(i,j) = median(vec);
                    case 'midpoint'
                        channelFiltered(i,j) = (min(vec) + max(vec)) / 2;
                    case 'alpha'
                        d = varargin{1};
                        if (n*n - 2*d <= 0), d = 0; end % Safety check
                        s = sort(vec);
                        trimmed_vec = s(d+1 : end-d);
                        channelFiltered(i,j) = mean(trimmed_vec);
                    case 'arithmetic'
                        channelFiltered(i,j) = mean(vec);
                    case 'geometric'
                        % Tambah epsilon kecil untuk menghindari log(0)
                        channelFiltered(i,j) = exp(mean(log(vec + 1e-6)));
                    case 'harmonic'
                        % Tambah epsilon kecil untuk menghindari pembagian dengan nol
                        channelFiltered(i,j) = n*n / sum(1 ./ (vec + 1e-6));
                    case 'contraharmonic'
                        Q = varargin{1};
                        % Tambah epsilon kecil untuk menghindari pembagian dengan nol
                        num = sum(vec.^(Q+1));
                        den = sum(vec.^Q);
                        channelFiltered(i,j) = num / (den + 1e-6);
                    otherwise
                        error('Tipe filter tidak dikenal: %s', tipeFilter);
                end
            end
        end
        % Konversi kembali ke tipe data asli (misal, uint8)
        imgFiltered(:,:,c) = im2uint8(channelFiltered);
    end
end