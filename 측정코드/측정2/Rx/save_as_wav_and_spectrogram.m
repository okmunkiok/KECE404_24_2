% % MP3 파일 읽기
% [mp3Data, mp3Fs] = audioread('mahler.mp3');
% 
% % 샘플링 주파수를 48,000 Hz로 변경하기 위해 리샘플링
% targetFs = 48000; % 목표 샘플링 주파수
% if mp3Fs ~= targetFs
%     mp3Data = resample(mp3Data, targetFs, mp3Fs);
% end
% 
% % WAV 파일로 저장
% audiowrite('mahler.wav', mp3Data, targetFs);

clear;
close all;
clc;
% % WAV 파일 읽기 (확인용)
% [wavData, wavFs] = audioread('mahler.wav');
% 
% % 스펙트로그램 그리기
% figure;
% spectrogram(wavData, 1024, 512, 1024, wavFs, 'yaxis');
% title('mahler.wav의 스펙트로그램');
% xlabel('시간 (초)');
% ylabel('주파수 (kHz)');
% ylim([0 wavFs/2000]); % 주파수 범위를 0 ~ 24 kHz로 설정

% WAV 파일 읽기 (확인용)
[wavData, wavFs] = audioread('mahler.wav');

% 스테레오인 경우 모노로 변환
if size(wavData, 2) > 1
    wavData = mean(wavData, 2);
end

% 스펙트로그램 그리기
figure;
spectrogram(wavData, 1024, 512, 1024, wavFs, 'yaxis');
title('mahler.wav의 스펙트로그램');
xlabel('시간 (h)');
ylabel('주파수 (kHz)');
ylim([0 wavFs/2000]); % 주파수 범위를 0 ~ 24 kHz로 설정
