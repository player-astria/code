function anova_analyze_odd(zoom,timewindow)
load("oddball_ERP_30.mat")
subjectnum = 1:30;
%% anova
anodatas = [];
for i =1:6
    anodata = double(squeeze(nanmean(nanmean(subjs_oddball_ERP(subjectnum,i,zoom,timewindow(1):timewindow(2)),3),4)))';
    anodatas= [anodatas;anodata];
end
[p, tbl, stats]  = anova1(anodatas');
if p < 0.05
    % 执行Tukey's HSD检验
    c = multcompare(stats, 'CType', 'hsd');
    
    % 显示结果
    disp('多重比较结果(Tukey HSD):');
    disp(array2table(c, 'VariableNames',{'组1','组2','置信下限','差值','置信上限','p值'}));
    
    % 可视化比较结果
    title('Tukey HSD多重比较');
    xlabel('组别');
    ylabel('均值估计');
end