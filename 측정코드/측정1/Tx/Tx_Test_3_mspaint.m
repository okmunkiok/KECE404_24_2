function draw_and_transmit()

    clear all;
    close all;
    clc;
    % 그림판 초기화
    img_size = [128, 128];
    drawing = ones(img_size);  % 흰색 배경 (1은 흰색)
    
    % 화면 크기 가져오기
    screenSize = get(0, 'ScreenSize');  % [left, bottom, width, height]
    
    % 그림판 생성
    h_fig = figure('Name', '그림판', 'NumberTitle', 'off', ...
        'MenuBar', 'none', 'ToolBar', 'none', ...
        'Units', 'pixels', 'Position', [0, 0, screenSize(3), screenSize(4)]);
    
    % 축 생성 및 설정
    h_axes = axes('Parent', h_fig);
    
    % 확대 배율 설정
    magnification = 800;  % 원하는 확대 배율
    
    % 이미지 표시
    h_img = imshow(drawing, 'Parent', h_axes, 'InitialMagnification', magnification);
    colormap(h_axes, gray);
    
    % 축의 좌표계 설정
    set(h_axes, 'Units', 'normalized', 'Position', [0 0 1 1]);
    axis(h_axes, 'tight', 'off');
    
    % 마우스 이벤트 설정
    set(h_fig, 'WindowButtonDownFcn', @mouseDown);
    set(h_fig, 'WindowButtonUpFcn', @mouseUp);
    
    % 전송 버튼 추가
    h_button_send = uicontrol('Style', 'pushbutton', 'String', '전송', ...
        'Units', 'normalized', 'Position', [0.9 0.01 0.08 0.05], 'Callback', @sendImage);
    
    % 지우개 버튼 추가 (전송 버튼 위에 배치)
    h_button_erase = uicontrol('Style', 'togglebutton', 'String', '지우개', ...
        'Units', 'normalized', 'Position', [0.9 0.07 0.08 0.05], 'Callback', @toggleEraser);
    
    % 전체 지우기 버튼 추가 (지우개 버튼 위에 배치)
    h_button_clear = uicontrol('Style', 'pushbutton', 'String', '전체 지우기', ...
        'Units', 'normalized', 'Position', [0.9 0.13 0.08 0.05], 'Callback', @clearDrawing);
    
    % 펜 굵기 슬라이더 추가
    h_slider = uicontrol('Style', 'slider', 'Min', 2, 'Max', 10, 'Value', 2, ...
        'SliderStep', [1/8, 1/8], ...  % 슬라이더 한 단계당 1씩 이동 (총 9단계)
        'Units', 'normalized', 'Position', [0.01 0.05 0.1 0.03]);
    
    % 슬라이더 레이블 추가
    h_text_penSize = uicontrol('Style', 'text', 'String', '펜 굵기: 2', ...
        'Units', 'normalized', 'Position', [0.01 0.08 0.1 0.03]);
    
    % 슬라이더 값 변경 시 레이블 업데이트
    addlistener(h_slider, 'Value', 'PostSet', @(src, event) updatePenSizeLabel());
    
    drawing_active = false;
    erasing = false;  % 지우개 모드 상태 변수
    
    % 마우스 누름 이벤트 핸들러
    function mouseDown(~, ~)
        drawing_active = true;
        set(h_fig, 'WindowButtonMotionFcn', @mouseMove);
    end
    
    % 마우스 뗌 이벤트 핸들러
    function mouseUp(~, ~)
        drawing_active = false;
        set(h_fig, 'WindowButtonMotionFcn', '');
        clear prev_x prev_y;  % 이전 위치 초기화
    end
    
    % 마우스 이동 이벤트 핸들러
    function mouseMove(~, ~)
        if drawing_active
            % 현재 마우스 위치 가져오기
            C = get(h_axes, 'CurrentPoint');
            x = round(C(1,1));
            y = round(C(1,2));
    
            % 그림판 범위 내인지 확인
            if x >= 1 && x <= img_size(2) && y >= 1 && y <= img_size(1)
                % 이전 위치가 있는지 확인
                if ~exist('prev_x', 'var')
                    prev_x = x;
                    prev_y = y;
                end
    
                % 이전 위치와 현재 위치 사이의 선 좌표 계산
                numPoints = max(abs(x - prev_x), abs(y - prev_y)) + 1;
                x_coords = round(linspace(prev_x, x, numPoints));
                y_coords = round(linspace(prev_y, y, numPoints));
    
                % 펜 굵기 가져오기
                penSize = round(get(h_slider, 'Value'));
    
                % 각 좌표에 대해 픽셀 값 설정
                for idx = 1:length(x_coords)
                    xi = x_coords(idx);
                    yi = y_coords(idx);
    
                    % 펜 또는 지우개 동작 수행
                    [X, Y] = meshgrid(max(1, xi - penSize + 1):min(img_size(2), xi + penSize - 1), ...
                                      max(1, yi - penSize + 1):min(img_size(1), yi + penSize - 1));
                    indices = sub2ind(size(drawing), Y(:), X(:));
                    if erasing
                        drawing(indices) = 1;  % 흰색으로 지우기
                    else
                        drawing(indices) = 0;  % 검정색으로 그리기
                    end
                end
    
                % 이미지 업데이트
                set(h_img, 'CData', drawing);
    
                % 현재 위치를 이전 위치로 저장
                prev_x = x;
                prev_y = y;
            end
        end
    end
    
    % 지우개 버튼 콜백 함수
    function toggleEraser(~, ~)
        erasing = get(h_button_erase, 'Value');  % 버튼 상태에 따라 erasing 값 변경
        if erasing
            set(h_button_erase, 'String', '그리기');
        else
            set(h_button_erase, 'String', '지우개');
        end
    end
    
    % 전체 지우기 버튼 콜백 함수
    function clearDrawing(~, ~)
        drawing = ones(img_size);  % 흰색으로 초기화
        set(h_img, 'CData', drawing);
    end
    
    % 펜 굵기 슬라이더 값 변경 시 레이블 업데이트 함수
    function updatePenSizeLabel()
        currentPenSize = round(get(h_slider, 'Value'));
        set(h_text_penSize, 'String', sprintf('펜 굵기: %d', currentPenSize));
    end
    
    % 전송 버튼 콜백 함수
    function sendImage(~, ~)
        % binarised_img 변수에 현재 그림 저장
        img = drawing;
        % img = imbinarize(img)
        
        % % binarised_img를 기본 워크스페이스에 할당
        % assignin('base', 'binarised_img', binarised_img);

        img = uint8(img * 255);
        imwrite(img, "C:\Users\user\Desktop\졸업드가자\종합설계\테스트\Tx\IMG.PNG");

        Tx_main(false);
        Tx_main(true);
        
        % % 그림판 창 닫기
        % close(h_fig);
    end
end
