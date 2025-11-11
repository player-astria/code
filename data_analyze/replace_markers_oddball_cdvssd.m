% 这个.m文件选择如何分析不同的cd_type
%% 所有child作为一个条件（不考虑数量），所有pregnant、drug、criminal、civilian、none各作为一个条件，即六种类型

for i = 1:size(EEG.event,2)
    marker = EEG.event(1,i).type;
    if contains(marker,'_line_')
        if contains(marker,'none') && ~contains(marker,'target')
            EEG.event(1,i).type = 'sd';
        elseif contains(marker,'target')
        else
            EEG.event(1,i).type = 'cd';
        end
    end
end

oddball_cdtype = {'cd' 'sd'};