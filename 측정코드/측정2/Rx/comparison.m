% BER 데이터를 저장할 배열 초기화
ber_values_1 = zeros(1, 100);
ber_values_2 = zeros(1, 100);

% 첫 번째 MAT 파일 로드
load('Rx_signal_1.mat');
for i = 1:100
    var_name = ['BER_' num2str(i)];
    if exist(var_name, 'var')
        ber_values_1(i) = eval(var_name);
    end
end

% 두 번째 MAT 파일 로드
load('Rx_signal_2.mat');
for i = 1:100
    var_name = ['BER_' num2str(i)];
    if exist(var_name, 'var')
        ber_values_2(i) = eval(var_name);
    end
end

% 그래프 생성
figure('Position', [100, 100, 1200, 600]);

% 이미지 번호 배열 생성
x = 1:100;

% 두 데이터 플롯
plot(x, ber_values_1, '.-', 'Color', [0.3010 0.7450 0.9330], 'LineWidth', 1.0, 'MarkerSize', 12, 'DisplayName', '통상환경');
hold on;
plot(x, ber_values_2, '.-', 'Color', [0.8500 0.3250 0.0980], 'LineWidth', 1.0, 'MarkerSize', 12, 'DisplayName', '잡음환경');

% 그래프 꾸미기
grid on;
xlabel('이미지 번호');
ylabel('BER 값');
title('통상환경과 잡음환경의 BER 비교');
legend('show');

% x축 눈금 설정
xticks(0:10:100);

% y축을 로그 스케일로 설정
set(gca, 'YScale', 'log');

% 평균값 계산 및 표시
mean_ber_1 = mean(ber_values_1);
mean_ber_2 = mean(ber_values_2);

% 텍스트로 평균값 표시
text(5, max([ber_values_1, ber_values_2]), sprintf('통상환경 평균 BER: %.2e', mean_ber_1), 'Color', [0.3010 0.7450 0.9330]);
text(5, max([ber_values_1, ber_values_2])*0.7, sprintf('잡음환경 평균 BER: %.2e', mean_ber_2), 'Color', [0.8500 0.3250 0.0980]);