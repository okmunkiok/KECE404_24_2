function [Recording_Time_Sec, Estimated_Img] = Rx_Step_2_Get_Estimated_Img(Rx_Setting_MAT_path_and_File_Name, Tx_signal, Base_WAV_Path_and_File_Name, Whether_median_filter, Whether_OCR, Whether_Use_Base_WAV_Changing_through_minute, Recording_Time_Sec, buffer_for_recording_time_sec)

    close all;
    load(Rx_Setting_MAT_path_and_File_Name);
    % spectrogram(Tx_signal, 256, 128, 256, Sampling_Freq, 'yaxis');

    disp('## Tx_signal 분석 중입니다');
    start_time = datetime("now", "Format", "yyyy-MM-dd HH:mm:ss");
    disp(['## 시작 시각: ', char(start_time)]);

    if Whether_Use_Base_WAV_Changing_through_minute == true
            % 현재 시간의 '분'을 숫자로 추출
            current_minute = minute(start_time);  % 53이 저장됨
            
            % 20으로 나눈 나머지를 숫자로 저장
            remainder_num = mod(current_minute, 20) + 1;  % 13이 저장됨
            remainder_num_spare = mod(current_minute, 20);  % 12이 저장됨
            if remainder_num_spare == 0
                remainder_num_spare = 20;
            end
            
            % 나머지를 문자열로 변환
            remainder_str = num2str(remainder_num);   % '13'이 저장됨
            remainder_str_spare = num2str(remainder_num_spare);   % '12'이 저장됨
            
            % 파일 경로에 나머지 값 추가
            Base_WAV_Path_and_File_Name = "C:\Users\okmun\OneDrive\대외 공개 가능\고려대학교 전기전자공학부\24_2\종합설계II (신원재 교수님)\Base_WAV\Base_" + remainder_str + ".WAV";
            Base_WAV_Path_and_File_Name_spare = "C:\Users\okmun\OneDrive\대외 공개 가능\고려대학교 전기전자공학부\24_2\종합설계II (신원재 교수님)\Base_WAV\Base_" + remainder_str_spare + ".WAV";
    else
        Base_WAV_Path_and_File_Name = "C:\Users\okmun\OneDrive\대외 공개 가능\고려대학교 전기전자공학부\24_2\종합설계II (신원재 교수님)\Base_WAV\Base_3.WAV";
    end

    [Base_WAV, Fs] = audioread(Base_WAV_Path_and_File_Name);
    [xC, lags] = xcorr(Tx_signal, Base_WAV);
    [max_1, idx] = max(xC);
    start_pt = lags(idx);
    if Whether_Use_Base_WAV_Changing_through_minute == true
        [Base_WAV_spare, Fs_spare] = audioread(Base_WAV_Path_and_File_Name_spare);
        [xC_spare, lags_spare] = xcorr(Tx_signal, Base_WAV_spare);
        [max_spare, idx_spare] = max(xC_spare);
        if max_1 < max_spare
            start_pt = lags_spare(idx_spare);
        end
    end

    Tx_signal = Tx_signal(start_pt + 1 : end);

    % Serial to Parallel
    OFDM_blks = {};
    for i = 1 : Total_OFDM_symbols_Number_that_is_including_Pilot
        OFDM_blks{end + 1} = Tx_signal(N_cp__that_is__Cyclic_Prefix_Length + 1 : (N + 2) + N_cp__that_is__Cyclic_Prefix_Length);
        Tx_signal = Tx_signal(N_cp__that_is__Cyclic_Prefix_Length + (N + 2) + 1 : end);
    end
    
    % Discrete Fourier Transform (DFT)
    demode_OFDM_blks = {};
    for i = 1 : length(OFDM_blks)
        demode_OFDM_blks{end + 1} = fft(OFDM_blks{i} / sqrt(N + 2));
    end

    % Channel Estimation & Equalisation. Pilot 여기서 활용됨
    symbols_eq = {};
    if Whether_Basic_Pilot__OR__PAPR_improved_Pilot == true
        pilot_freq = ones(N + 2, 1);
    else
        rng('default');
        if Whether_Pilot_Use_all_freq__OR__High_freq_only == true
            temp_pilot = 2 * (randi([0, 1], N/2, 1) - 0.5);  % N/2 개만 생성
        else
            temp_pilot_1 = zeros(floor(N*(1-2*(1/Subcarrier_Freq_Divided_by)))/2, 1);
            temp_pilot_2 = 2 * (randi([0, 1], floor(N/Subcarrier_Freq_Divided_by)/2, 1) - 0.5);
            temp_pilot_3 = zeros(floor(N/Subcarrier_Freq_Divided_by/2), 1);
            temp_pilot = [temp_pilot_1; temp_pilot_2; temp_pilot_3];
        end
        pilot_freq = [0; temp_pilot; 0; flip(conj(temp_pilot))];  % DC, 중간, 허미션 처리
    end
    for i = 1 : length(demode_OFDM_blks)
        if rem(i, 5) == 1
            channel = demode_OFDM_blks{i} ./ pilot_freq;
        else
            symbols_eq{end + 1} = demode_OFDM_blks{i} ./ channel;
        end
    end

    % Detection
    symbols_detect = {};
    for i = 1 : length(symbols_eq)
        symbols_detect{end + 1} = symbols_eq{i};
    end
    
    % Demodulation
    symbols_est = [];
    for i = 1 : length(symbols_detect)
        symbols_est = [symbols_est; symbols_detect{i}(2+floor(N*(1-2*(1/Subcarrier_Freq_Divided_by)))/2:1+floor(N*(1-1*(1/Subcarrier_Freq_Divided_by)))/2)];
    end
    
    % QPSK Demodulation
    decoded_symbols = pskdemod(symbols_est, 4, pi/4);
    decoded_bits = int2bit(decoded_symbols, 2);
    
    % 동일한 interleaver_order 생성
    rng('default'); % 동일한 시드로 초기화하여 Tx와 같은 순서 생성
    interleaver_order = randperm(length(decoded_bits));
    
    % Disinterleaving
    [~, deinterleaver_order] = sort(interleaver_order); % 원래 순서를 찾기 위해 역순서를 계산
    decoded_bits = decoded_bits(deinterleaver_order); % 원래 순서로 복원

    if Whether_NOT_Repetition_coding__OR__Repetition_How_Many ~= 1
        % Repetition Decoding
        % 3개씩 묶어서 reshape
        decoded_bits_reshaped = reshape(decoded_bits, Whether_NOT_Repetition_coding__OR__Repetition_How_Many, []);
        
        % 각 열의 합을 계산 (다수결 원칙 적용)
        sums = sum(decoded_bits_reshaped);
        
        % 합이 2 이상이면 1, 미만이면 0으로 판정
        decoded_bits = (sums > (Whether_NOT_Repetition_coding__OR__Repetition_How_Many / 2)).';
    end
    
    % Source Decoding & Show img
    % 이미지 크기 계산 시 repetition decoding으로 인한 크기 변화 고려
    if Whether_NOT_Repetition_coding__OR__Repetition_How_Many == 1
        img_size = sqrt(length(decoded_bits));
        Estimated_Img = reshape(decoded_bits, [Fixed_Img_Size(1), Fixed_Img_Size(2)]);
    else
        img_size = sqrt(length(decoded_bits));
        Estimated_Img = reshape(decoded_bits, [Fixed_Img_Size(1), Fixed_Img_Size(2)]);
    end
    Estimated_Img = imresize(Estimated_Img, Fixed_Img_Size);
    if Whether_median_filter == true
        Estimated_Img = medfilt2(Estimated_Img, [3 3], 'symmetric');
    end

    % 문자열 변수 설정
    a = 'asdf';
    
    % OCR 조건 확인 (예: Whether_OCR이 true일 때만 수행)
    if Whether_OCR == true
        recognizedText = performEasyOCR(Estimated_Img);
    else
        recognizedText = '';
    end
    
    % 숫자 입력 받기
    prompt = '비교할 원본 이미지 번호를 입력하세요 (1-100): ';
    img_number = input(prompt);

    % 원본 이미지 경로
    original_img_path = ['C:\Users\okmun\OneDrive\대외 공개 가능\고려대학교 전기전자공학부\24_2\종합설계II (신원재 교수님)\논문 작성 등\images\100개 선별 및 크기 128x128으로 조정\' num2str(img_number) '.png'];

    % 원본 이미지 읽기 및 전처리
    original_img = imread(original_img_path);
    original_img = im2gray(original_img);
    original_img = imresize(original_img, Fixed_Img_Size);
    original_img = imbinarize(original_img); % 이진화

    % BER 계산
    [number_of_errors, ber] = biterr(original_img(:), Estimated_Img(:));
    disp(['BER: ' num2str(ber)]);

    % MAT 파일에 BER 저장
    disp('a');
    S.(['BER_' num2str(img_number)]) = ber;
    disp('b');
    
    % 파일 존재 여부 확인 후 저장
    if exist('Rx_signal.mat', 'file')
        save('Rx_signal.mat', '-struct', 'S', '-append');
    else
        save('Rx_signal.mat', '-struct', 'S');
    end
    disp('c');
    disp('d');
    % disp('a');
    % ber_variable_name = [num2str(img_number) '_BER'];
    % disp('b');
    % assignin('base', ber_variable_name, ber);
    % disp('c');
    % save('Rx_signal.mat', ber_variable_name, '-append');
    % disp('d');

    % % Figure 창 생성 및 크기 설정
    % figure('WindowState', 'maximized'); % 창을 최대화
    % 
    % % 서브플롯 구성
    % subplot(2,2,1); % 좌상단
    % imshow(original_img);
    % title(['Original Image #' num2str(img_number)]);
    % 
    % subplot(2,2,2); % 우상단
    % imshow(Estimated_Img);
    % title(['Estimated Image (BER: ' num2str(ber) ')']);
    % 
    % % 서브플롯 2행 1열 중 두 번째에 텍스트 표시
    % subplot(2,1,2); % 하단 전체
    % axis off; % 축 숨기기
    % % if ~isempty(recognizedText)
    % %     % 텍스트 박스에 인식된 텍스트 표시
    % %     text(0.5, 0.5, recognizedText, ...
    % %         'Units', 'normalized', ...           % 정규화된 단위 사용
    % %         'FontSize', 24, ...                  % 글씨 크기
    % %         'FontWeight', 'bold', ...            % 글씨 두께
    % %         'HorizontalAlignment', 'center', ... % 수평 정렬
    % %         'VerticalAlignment', 'middle', ...   % 수직 정렬
    % %         'Color', 'red');                      % 글씨 색상
    % %     title('인식된 텍스트');
    % % else
    % %     title('인식된 텍스트가 없습니다.');
    % % end
    % 
    % drawnow;

    end_time = datetime("now", "Format", "yyyy-MM-dd HH:mm:ss");
    disp(['## Tx_signal 분석 완료 시각: ', char(end_time)]);
    elapsed_time = end_time - start_time;
    disp(['## Tx_signal 분석 경과 시간[s]: ', char(elapsed_time)]);
end