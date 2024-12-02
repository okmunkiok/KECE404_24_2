% 100개의 이미지에 대해 Tx_main을 실행하는 스크립트
clearvars;
clc;

% 기본 경로 설정
base_img_path = 'C:\Users\user\Desktop\졸업드가자\종합설계\최종본\100개 선별 및 크기 128x128으로 조정\';
base_wav_path = 'C:\Users\user\Desktop\졸업드가자\종합설계\최종본\Tx\';
base_wav_file = 'C:\Users\user\Desktop\졸업드가자\종합설계\최종본\Base_WAV\Base_3.WAV';

% 전체 시작 시간 기록
total_start_time = datetime("now", "Format", "yyyy-MM-dd HH:mm:ss");
disp(['전체 프로세스 시작 시각: ', char(total_start_time)]);

% 100개 이미지에 대해 반복
for i = 1:100
    disp(['==== Processing image ' num2str(i) ' of 100 ====']);
    
    % 현재 이미지와 WAV 파일 경로 설정
    current_img_path = [base_img_path num2str(i) '.png'];
    current_wav_path = [base_wav_path 'Tx_signal_' num2str(i) '.WAV'];
    
    % Tx_main 함수 호출
    Tx_main(false, current_wav_path, current_img_path, base_wav_file);
    
    disp(['==== Completed image ' num2str(i) ' of 100 ====']);
    disp(' ');
end

% 전체 종료 시간 기록
total_end_time = datetime("now", "Format", "yyyy-MM-dd HH:mm:ss");
disp(['전체 프로세스 종료 시각: ', char(total_end_time)]);
elapsed_time = total_end_time - total_start_time;
disp(['전체 프로세스 총 경과 시간: ', char(elapsed_time)]);