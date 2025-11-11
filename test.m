function CheckKeyPress()
    fprintf('开始检测按键状态...\n');
    fprintf('按下任意键查看信息，按ESC退出\n\n');
    
    % 创建隐藏图形窗口
    fig = figure('Visible', 'off', 'KeyPressFcn', @keyDetect);
    
    fprintf('检测中...\n');
    
    % 等待按键
    uiwait(fig);
end

function keyDetect(src, event)
    fprintf('检测到按键: %s\n', event.Key);
    fprintf('字符: %s\n', event.Character);
    fprintf('修饰键: %s\n', strjoin(event.Modifier, ', '));
    fprintf('---\n');
    
    % 如果按下ESC键，退出
    if strcmp(event.Key, 'escape')
        delete(src);
    end
end