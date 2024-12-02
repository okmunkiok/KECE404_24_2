% 녹음 설정
fs = 44100;          % 샘플링 주파수 (Hz)
nBits = 16;          % 비트 깊이
nChannels = 1;       % 모노 녹음
recDuration = 60;    % 녹음 시간 (초)

% 오디오 레코더 객체 생성
recObj = audiorecorder(fs, nBits, nChannels);

% 녹음 시작 안내
disp('녹음을 시작합니다. 1분 동안 녹음합니다.');

% 녹음 시작 (블로킹 모드)
recordblocking(recObj, recDuration);

% 녹음 완료 안내
disp('녹음이 완료되었습니다.');

% 녹음된 데이터 가져오기
audioData = getaudiodata(recObj);

% 스펙트로그램 그리기
figure;
spectrogram(audioData, 1024, 512, 1024, fs, 'yaxis');
% title('녹음된 채널의 스펙트로그램');
xlabel('시간 (초)');
ylabel('주파수 (kHz)');
ylim([0 fs/2000]);  % 주파수 범위를 0 ~ fs/2000 kHz로 설정
