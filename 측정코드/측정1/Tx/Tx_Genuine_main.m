function draw_and_transmit()
    clear all;
    close all;
    clc;
    
    % 기본 설정
    img_size = [128, 128];
    drawing = ones(img_size);
    program_on = 1;
    brush_size = 2;
    current_line = [];
    line_count = 0;
    
    % 화면 설정
    screenSize = get(0, 'ScreenSize');
    
    % 메인 피규어 설정
    h_fig = figure('Name', '그림판', ...
        'NumberTitle', 'off', ...
        'MenuBar', 'none', ...
        'ToolBar', 'none', ...
        'Units', 'normalized', ...
        'Position', [0.1 0.1 0.8 0.8], ...
        'Color', [0.9 0.9 0.9]);
    
    % 축 설정
    h_axes = axes('Parent', h_fig, ...
        'Units', 'normalized', ...
        'Position', [0.05 0.05 0.8 0.9], ...
        'XLim', [1 img_size(2)], ...
        'YLim', [1 img_size(1)], ...
        'YDir', 'reverse');
    
    % 이미지 표시
    h_img = imshow(drawing, 'Parent', h_axes);
    colormap(h_axes, gray);
    hold(h_axes, 'on');
    
    % UI 컨트롤
    uicontrol('Style', 'pushbutton', 'String', '전송', ...
        'Units', 'normalized', 'Position', [0.87 0.1 0.08 0.05], ...
        'Callback', @sendImage);
    
    uicontrol('Style', 'pushbutton', 'String', '전체 지우기', ...
        'Units', 'normalized', 'Position', [0.87 0.3 0.08 0.05], ...
        'Callback', @clearDrawing);
    
    h_slider = uicontrol('Style', 'slider', ...
        'Min', 2, 'Max', 10, 'Value', brush_size, ...
        'SliderStep', [1/8 1/8], ...
        'Units', 'normalized', 'Position', [0.87 0.4 0.08 0.03], ...
        'Callback', @updateBrushSize);
    
    h_text = uicontrol('Style', 'text', ...
        'String', sprintf('펜 굵기: %d', brush_size), ...
        'Units', 'normalized', 'Position', [0.87 0.44 0.08 0.03]);
    
    % 브러시 포인터 설정
    brush_pointer = line('Parent', h_axes, ...
        'XData', [], 'YData', [], ...
        'LineStyle', 'none', ...
        'Marker', 'o', ...
        'MarkerSize', brush_size * 2, ...
        'MarkerEdgeColor', 'black', ...
        'MarkerFaceColor', 'none', ...
        'Visible', 'off');
    
    % 마우스 이벤트 설정
    set(h_fig, 'WindowButtonDownFcn', @mouseDown);
    set(h_fig, 'WindowButtonUpFcn', @mouseUp);
    set(h_fig, 'WindowButtonMotionFcn', @mouseMove);
    
    % 메인 루프
    while program_on
        drawnow;
    end
    
    % 콜백 함수들
    function mouseDown(~, ~)
        cp = get(h_axes, 'CurrentPoint');
        x = round(cp(1,1));
        y = round(cp(1,2));
        
        if x >= 1 && x <= img_size(2) && y >= 1 && y <= img_size(1)
            line_count = line_count + 1;
            current_line = animatedline('Parent', h_axes, ...
                'LineWidth', brush_size * 2, ...
                'Color', [0 0 0]);  % 항상 검은색
            addpoints(current_line, x, y);
            updateDrawing(x, y);
        end
    end
    
    function mouseUp(~, ~)
        current_line = [];
        updateDrawing([], []);
    end
    
    function mouseMove(~, ~)
        cp = get(h_axes, 'CurrentPoint');
        x = round(cp(1,1));
        y = round(cp(1,2));
        
        set(brush_pointer, ...
            'XData', x, 'YData', y, ...
            'MarkerSize', brush_size * 2, ...
            'Visible', 'on');
        
        if ~isempty(current_line) && x >= 1 && x <= img_size(2) && y >= 1 && y <= img_size(1)
            addpoints(current_line, x, y);
            updateDrawing(x, y);
        end
    end
    
    function updateDrawing(x, y)
        persistent prev_x prev_y
        
        if isempty(prev_x)
            prev_x = x;
            prev_y = y;
        end
        
        distance = sqrt((x - prev_x)^2 + (y - prev_y)^2);
        min_spacing = max(1, brush_size/2);
        num_points = max(1, ceil(distance/min_spacing));
        
        if num_points > 1
            x_points = round(linspace(prev_x, x, num_points));
            y_points = round(linspace(prev_y, y, num_points));
            
            for i = 1:num_points
                [X, Y] = meshgrid(max(1,x_points(i)-brush_size):min(img_size(2),x_points(i)+brush_size), ...
                                 max(1,y_points(i)-brush_size):min(img_size(1),y_points(i)+brush_size));
                dist = sqrt((X-x_points(i)).^2 + (Y-y_points(i)).^2);
                mask = dist <= brush_size;
                indices = sub2ind(size(drawing), Y(mask), X(mask));
                drawing(indices) = 0;  % 항상 검은색(0)으로 그리기
            end
            
            set(h_img, 'CData', drawing);
        end
        
        prev_x = x;
        prev_y = y;
    end
    
    function updateBrushSize(src, ~)
        brush_size = round(get(src, 'Value'));
        set(h_text, 'String', sprintf('펜 굵기: %d', brush_size));
        set(brush_pointer, 'MarkerSize', brush_size * 2);
    end
    
    function clearDrawing(~, ~)
        drawing = ones(img_size);
        set(h_img, 'CData', drawing);
        delete(findall(h_axes, 'Type', 'animatedline'));
        line_count = 0;
    end
    
    function sendImage(~, ~)
        img = uint8(drawing * 255);
        imwrite(img, "C:\Users\user\Desktop\졸업드가자\종합설계\최종본\측정1\Tx\IMG.PNG");
        Tx_main(false);
        Tx_main(true);
    end
end