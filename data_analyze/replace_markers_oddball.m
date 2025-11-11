% 这个.m文件选择如何分析不同的cd_type
%% 所有child作为一个条件（不考虑数量），所有pregnant、drug、criminal、civilian、none各作为一个条件，即六种类型

for i = 1:size(EEG.event,2)
    marker = EEG.event(1,i).type;
    if contains(marker,'_line_')
        if contains(marker,'child')
            EEG.event(1,i).type = 'cd_child';
        elseif contains(marker,'pregnant') || contains(marker,'pregmant') %%% !!因为预处理输入错误所以修改为'pregmant'，在预实验数据处理结束后改回去！！
            EEG.event(1,i).type = 'cd_pregnant';
        elseif contains(marker,'civilian')
            EEG.event(1,i).type = 'cd_civilian';
        elseif contains(marker,'drug')
            EEG.event(1,i).type = 'cd_drug';
        elseif contains(marker,'criminal')
            EEG.event(1,i).type = 'cd_crinimal';
        elseif contains(marker,'none') && ~contains(marker,'target')
            EEG.event(1,i).type = 'sd_none';
        end
    end
end

oddball_cdtype = {'cd_child' 'cd_pregnant' 'cd_civilian' 'cd_drug' 'cd_crinimal' 'sd_none'};

EEG = pop_epoch( EEG,oddball_cdtype , [-0.5 1], 'newname', strcat(filenames{P},'_intchan_avg_filt epochs'), 'epochinfo', 'yes'); %selection: 0 to 1.5 seconds
