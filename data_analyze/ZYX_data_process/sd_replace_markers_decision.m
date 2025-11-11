% 这个.m文件选择如何分析soldier damage条件下的93个different social roles
%% 所有social roles作为一个条件，3个baselines作为一个条件
sr_list = readcell('Social roles 93.xlsx');
for i = 1:size(EEG.event,2)
    marker = EEG.event(1,i).type;
    if contains(marker,'_onset_')
        idxs = strfind(marker,'_');
        idx = max(idxs);
        sr = marker(idx+1:length(marker));
        if strcmp(sr,'baseline')
            EEG.event(1,i).type = 'sd_decision_all_baseline';
        else
            EEG.event(1,i).type = 'sd_decision_all_different_social_roles';
        end
    end
end