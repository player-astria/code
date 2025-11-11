% 这个.m文件是把sd decision的eeg data的数字的marker转换成我们研究的event，比如11对应fixation1
sr_list = readcell('Social roles 93.xlsx');
for i = 1:size(EEG.event,2)
    marker = EEG.event(1,i).type;
    if strcmp(class(marker), 'double')
        if marker >= 101 && marker <= 193
            marker = marker - 100;
            EEG.event(1,i).type = ['sd_sr_info_' sr_list{marker,1}(1:length(sr_list{marker,1})-1)];
            EEG.event(1,i-1).type = ['fixation2_' sr_list{marker,1}(1:length(sr_list{marker,1})-1)];
            EEG.event(1,i-2).type = ['sd_killsoldier_' sr_list{marker,1}(1:length(sr_list{marker,1})-1)];
            EEG.event(1,i-3).type = ['fixation1_' sr_list{marker,1}(1:length(sr_list{marker,1})-1)];
            EEG.event(1,i+1).type = ['fixation3_' sr_list{marker,1}(1:length(sr_list{marker,1})-1)];
            if i+3<size(EEG.event,2)
                if EEG.event(1,i+3).type == 201
                    EEG.event(1,i+2).type = ['sd_decision_launch_onset_' sr_list{marker,1}(1:length(sr_list{marker,1})-1)];
                    EEG.event(1,i+3).type = ['sd_decision_launch_' sr_list{marker,1}(1:length(sr_list{marker,1})-1)];
                elseif EEG.event(1,i+3).type == 202
                    EEG.event(1,i+2).type = ['sd_decision_cancel_onset_' sr_list{marker,1}(1:length(sr_list{marker,1})-1)];
                    EEG.event(1,i+3).type = ['sd_decision_cancel_' sr_list{marker,1}(1:length(sr_list{marker,1})-1)];
                elseif EEG.event(1,i+3).type == 203
                    EEG.event(1,i+2).type = ['sd_decision_non_onset_' sr_list{marker,1}(1:length(sr_list{marker,1})-1)];
                    EEG.event(1,i+3).type = ['sd_decision_non_' sr_list{marker,1}(1:length(sr_list{marker,1})-1)];
                end
            end
        elseif marker == 194
            marker = marker - 100;
            EEG.event(1,i).type = ['sd_sr_info_' 'baseline'];
            EEG.event(1,i-1).type = ['fixation2_' 'baseline'];
            EEG.event(1,i-2).type = ['sd_killsoldier_' 'baseline'];
            EEG.event(1,i-3).type = ['fixation1_' 'baseline'];
            EEG.event(1,i+1).type = ['fixation3_' 'baseline'];
            if EEG.event(1,i+3).type == 201
                EEG.event(1,i+2).type = ['sd_decision_launch_onset_' 'baseline'];
                EEG.event(1,i+3).type = ['sd_decision_launch_' 'baseline'];
            elseif EEG.event(1,i+3).type == 202
                EEG.event(1,i+2).type = ['sd_decision_cancel_onset_' 'baseline'];
                EEG.event(1,i+3).type = ['sd_decision_cancel_' 'baseline'];
            elseif EEG.event(1,i+3).type == 203
                EEG.event(1,i+2).type = ['sd_decision_non_onset_' 'baseline'];
                EEG.event(1,i+3).type = ['sd_decision_non_' 'baseline'];
            end
        end
    end

end
% delete non-relevant number
for i = 1:size(EEG.event,2)
    marker = EEG.event(i).type;
    if class(marker)=="double"
        EEG.event(i).type = 'other';
    end
end
% segmentation
% 分大段，从fixation1到整个trial结束
Relevant_Markers = {};
for i = 1:size(EEG.event,2)
    marker = EEG.event(1,i).type;
    if contains(marker,'sd_sr_info')
        Relevant_Markers = [Relevant_Markers marker];
    end
end
EEG = pop_epoch( EEG, Relevant_Markers , [-3.4 8.2], 'newname', strcat(filenames{VP},'_intchan_avg_filt epochs'), 'epochinfo', 'yes'); % Time window must be adjusted by RT

