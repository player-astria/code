%% Load ERP Matrix
close all;clear;clc;
load('Decision_ERP_sd.mat');%选择要画ERP的数据
%% interest electrodes
FronElec = [8:12 17:21]; %frontal regions: Fz,F1,F3,F2,F4,FCz,FC1,FC3,FC2,FC4
CentElec = 26:30; %central regions: Cz,C1,C3,C2,C4
PariElec= 44:48; %parietal regions: Pz,P1,P3,P2,P4
OctrElec = [42 50 51 57]; %occipito-trmporal regions:PO7,PO8,P7,P8
%% Plot parameter
EEG.srate = 250;
display_time_start_from_zero_in_ms = -500; %Note that one can also go into - : this means it is left from 0, being a display of the baseline. Note also that you cannot display data that is not in your segmentation.
display_time_end_from_zero_in_ms = 1500; %Note also that you cannot display data that is not in your segmentation.
%display parameter for ERP:
display_time_start = display_time_start_from_zero_in_ms/(1000/EEG.srate)-(Segementation_time_start*EEG.srate); % dependent on the starting point of segement and sampling rate
display_time_end = display_time_end_from_zero_in_ms/(1000/EEG.srate)-(Segementation_time_start*EEG.srate); % dependent on the starting point of segement and sampling rate
%% set conditions
% social role condition
all_different_social_roles_cond = 2;
all_baseline_cond = 1;
% damage condition
collateral_damage_cond = 1:SubjectNum;
soldier_damage_cond = 1:SubjectNum;
%% calculate ERP
% basic condition
cd_all_different_social_roles_info = squeeze(nanmean(nanmean(nanmean(subjs_decision_ERP(collateral_damage_cond,all_different_social_roles_cond,CentElec,:),1),2),3));
cd_all_baseline_info = squeeze(nanmean(nanmean(nanmean(subjs_decision_ERP(collateral_damage_cond,all_baseline_cond,CentElec,:),1),2),3));

sd_all_different_social_roles_info = squeeze(nanmean(nanmean(nanmean(subjs_decision_ERP(soldier_damage_cond,all_different_social_roles_cond,CentElec,:),1),2),3));
sd_all_baseline_info = squeeze(nanmean(nanmean(nanmean(subjs_decision_ERP(soldier_damage_cond,all_baseline_cond,CentElec,:),1),2),3));

%% plot
%%%%%%%%%%%%%%%%%%% collateral damage all different social roles info vs baseline %%%%%%%%%%%%%%%%%%%
% elec:Central 
% social roles: all different social roles vs baseline
% condition: collateral damage
figure
x1 = 1:display_time_end-display_time_start+1;
y1 = double(cd_all_different_social_roles_info(display_time_start:display_time_end))';
e1 = double(squeeze(nanstd(nanmean(nanmean(subjs_decision_ERP(collateral_damage_cond,all_different_social_roles_cond ,CentElec,display_time_start:display_time_end),2),3), 0, 1)/sqrt(size(subjs_decision_ERP,1))))';
boundedline(x1, y1, e1, '-r', 'alpha'); %#ok<*NANSTD>
hold on
set(gca,'XTick',[0 (display_time_end-display_time_start)/5 (display_time_end-display_time_start)*2/5 (display_time_end-display_time_start)*3/5 (display_time_end-display_time_start)*4/5 display_time_end-display_time_start] ); %This are going to be the only values affected. Here, always 1/5 of the chosen time will be marked. If you want to change this, feel free to...
set(gca,'XTickLabel',[display_time_start_from_zero_in_ms ((display_time_end_from_zero_in_ms-display_time_start_from_zero_in_ms)/5)+display_time_start_from_zero_in_ms ((display_time_end_from_zero_in_ms-display_time_start_from_zero_in_ms)*2/5)+display_time_start_from_zero_in_ms ((display_time_end_from_zero_in_ms-display_time_start_from_zero_in_ms)*3/5)+display_time_start_from_zero_in_ms ((display_time_end_from_zero_in_ms-display_time_start_from_zero_in_ms)*4/5)+display_time_start_from_zero_in_ms display_time_end_from_zero_in_ms] ); %This is what it's going to appear in those places.´
x2 = 1:display_time_end-display_time_start+1;
y2 = double(cd_all_baseline_info(display_time_start:display_time_end))';
e2 = double(squeeze(nanstd(nanmean(nanmean(subjs_decision_ERP(collateral_damage_cond,all_baseline_cond ,CentElec,display_time_start:display_time_end),2),3), 0, 1)/sqrt(size(subjs_decision_ERP,1))))';
boundedline(x2, y2, e2, '-b', 'alpha');
xlim([0 display_time_end-display_time_start])
% yl = ylim;
ylim([-10 10]);
% y=yl(1,1):0.2:yl(1,2);
y=-10:0.2:10;
plot((-display_time_start_from_zero_in_ms/(1000/EEG.srate))*ones(size(y)), y, 'LineWidth', 1) %plot a line on 0
axis ij
legend('','All different social roles','','Baseline')
title('collateral damage all different social roles decision vs baseline (central)')

%%%%%%%%%%%%%%%%%%% soldier damage all different social roles info vs baseline %%%%%%%%%%%%%%%%%%%
% elec:Central 
% social roles: all different social roles vs baseline
% condition: soldier damage
figure
x1 = 1:display_time_end-display_time_start+1;
y1 = double(sd_all_different_social_roles_info(display_time_start:display_time_end))';
e1 = double(squeeze(nanstd(nanmean(nanmean(subjs_decision_ERP(soldier_damage_cond,all_different_social_roles_cond ,CentElec,display_time_start:display_time_end),2),3), 0, 1)/sqrt(size(subjs_decision_ERP,1))))';
boundedline(x1, y1, e1, '-r', 'alpha'); %#ok<*NANSTD>
hold on
set(gca,'XTick',[0 (display_time_end-display_time_start)/5 (display_time_end-display_time_start)*2/5 (display_time_end-display_time_start)*3/5 (display_time_end-display_time_start)*4/5 display_time_end-display_time_start] ); %This are going to be the only values affected. Here, always 1/5 of the chosen time will be marked. If you want to change this, feel free to...
set(gca,'XTickLabel',[display_time_start_from_zero_in_ms ((display_time_end_from_zero_in_ms-display_time_start_from_zero_in_ms)/5)+display_time_start_from_zero_in_ms ((display_time_end_from_zero_in_ms-display_time_start_from_zero_in_ms)*2/5)+display_time_start_from_zero_in_ms ((display_time_end_from_zero_in_ms-display_time_start_from_zero_in_ms)*3/5)+display_time_start_from_zero_in_ms ((display_time_end_from_zero_in_ms-display_time_start_from_zero_in_ms)*4/5)+display_time_start_from_zero_in_ms display_time_end_from_zero_in_ms] ); %This is what it's going to appear in those places.´
x2 = 1:display_time_end-display_time_start+1;
y2 = double(sd_all_baseline_info(display_time_start:display_time_end))';
e2 = double(squeeze(nanstd(nanmean(nanmean(subjs_decision_ERP(soldier_damage_cond,all_baseline_cond ,CentElec,display_time_start:display_time_end),2),3), 0, 1)/sqrt(size(subjs_decision_ERP,1))))';
boundedline(x2, y2, e2, '-b', 'alpha');
xlim([0 display_time_end-display_time_start])
% yl = ylim;
ylim([-10 10]);
% y=yl(1,1):0.2:yl(1,2);
y=-10:0.2:10;
plot((-display_time_start_from_zero_in_ms/(1000/EEG.srate))*ones(size(y)), y, 'LineWidth', 1) %plot a line on 0
axis ij
legend('','All different social roles','','Baseline')
title('soldier damage all different social roles decision vs baseline (central)')

%% plot
%%%%%%%%%%%%%%%%%%% collateral damage all different social roles info vs baseline %%%%%%%%%%%%%%%%%%%
% elec:Frontal 
cd_all_different_social_roles_info = squeeze(nanmean(nanmean(nanmean(subjs_decision_ERP(collateral_damage_cond,all_different_social_roles_cond,FronElec,:),1),2),3));
cd_all_baseline_info = squeeze(nanmean(nanmean(nanmean(subjs_decision_ERP(collateral_damage_cond,all_baseline_cond,FronElec,:),1),2),3));
% social roles: all different social roles vs baseline
% condition: collateral damage
figure
x1 = 1:display_time_end-display_time_start+1;
y1 = double(cd_all_different_social_roles_info(display_time_start:display_time_end))';
e1 = double(squeeze(nanstd(nanmean(nanmean(subjs_decision_ERP(collateral_damage_cond,all_different_social_roles_cond ,FronElec,display_time_start:display_time_end),2),3), 0, 1)/sqrt(size(subjs_decision_ERP,1))))';
boundedline(x1, y1, e1, '-r', 'alpha'); %#ok<*NANSTD>
hold on
set(gca,'XTick',[0 (display_time_end-display_time_start)/5 (display_time_end-display_time_start)*2/5 (display_time_end-display_time_start)*3/5 (display_time_end-display_time_start)*4/5 display_time_end-display_time_start] ); %This are going to be the only values affected. Here, always 1/5 of the chosen time will be marked. If you want to change this, feel free to...
set(gca,'XTickLabel',[display_time_start_from_zero_in_ms ((display_time_end_from_zero_in_ms-display_time_start_from_zero_in_ms)/5)+display_time_start_from_zero_in_ms ((display_time_end_from_zero_in_ms-display_time_start_from_zero_in_ms)*2/5)+display_time_start_from_zero_in_ms ((display_time_end_from_zero_in_ms-display_time_start_from_zero_in_ms)*3/5)+display_time_start_from_zero_in_ms ((display_time_end_from_zero_in_ms-display_time_start_from_zero_in_ms)*4/5)+display_time_start_from_zero_in_ms display_time_end_from_zero_in_ms] ); %This is what it's going to appear in those places.´
x2 = 1:display_time_end-display_time_start+1;
y2 = double(cd_all_baseline_info(display_time_start:display_time_end))';
e2 = double(squeeze(nanstd(nanmean(nanmean(subjs_decision_ERP(collateral_damage_cond,all_baseline_cond ,FronElec,display_time_start:display_time_end),2),3), 0, 1)/sqrt(size(subjs_decision_ERP,1))))';
boundedline(x2, y2, e2, '-b', 'alpha');
xlim([0 display_time_end-display_time_start])
% yl = ylim;
ylim([-10 10]);
% y=yl(1,1):0.2:yl(1,2);
y=-10:0.2:10;
plot((-display_time_start_from_zero_in_ms/(1000/EEG.srate))*ones(size(y)), y, 'LineWidth', 1) %plot a line on 0
axis ij
legend('','All different social roles','','Baseline')
title('collateral damage all different social roles decision vs baseline (frontal)')

%%%%%%%%%%%%%%%%%%%soldier damage all different social roles info vs baseline %%%%%%%%%%%%%%%%%%%
% elec:Frontal 
sd_all_different_social_roles_info = squeeze(nanmean(nanmean(nanmean(subjs_decision_ERP(collateral_damage_cond,all_different_social_roles_cond,FronElec,:),1),2),3));
sd_all_baseline_info = squeeze(nanmean(nanmean(nanmean(subjs_decision_ERP(collateral_damage_cond,all_baseline_cond,FronElec,:),1),2),3));
% social roles: all different social roles vs baseline
% condition: collateral damage
figure
x1 = 1:display_time_end-display_time_start+1;
y1 = double(sd_all_different_social_roles_info(display_time_start:display_time_end))';
e1 = double(squeeze(nanstd(nanmean(nanmean(subjs_decision_ERP(collateral_damage_cond,all_different_social_roles_cond ,FronElec,display_time_start:display_time_end),2),3), 0, 1)/sqrt(size(subjs_decision_ERP,1))))';
boundedline(x1, y1, e1, '-r', 'alpha'); %#ok<*NANSTD>
hold on
set(gca,'XTick',[0 (display_time_end-display_time_start)/5 (display_time_end-display_time_start)*2/5 (display_time_end-display_time_start)*3/5 (display_time_end-display_time_start)*4/5 display_time_end-display_time_start] ); %This are going to be the only values affected. Here, always 1/5 of the chosen time will be marked. If you want to change this, feel free to...
set(gca,'XTickLabel',[display_time_start_from_zero_in_ms ((display_time_end_from_zero_in_ms-display_time_start_from_zero_in_ms)/5)+display_time_start_from_zero_in_ms ((display_time_end_from_zero_in_ms-display_time_start_from_zero_in_ms)*2/5)+display_time_start_from_zero_in_ms ((display_time_end_from_zero_in_ms-display_time_start_from_zero_in_ms)*3/5)+display_time_start_from_zero_in_ms ((display_time_end_from_zero_in_ms-display_time_start_from_zero_in_ms)*4/5)+display_time_start_from_zero_in_ms display_time_end_from_zero_in_ms] ); %This is what it's going to appear in those places.´
x2 = 1:display_time_end-display_time_start+1;
y2 = double(sd_all_baseline_info(display_time_start:display_time_end))';
e2 = double(squeeze(nanstd(nanmean(nanmean(subjs_decision_ERP(collateral_damage_cond,all_baseline_cond ,FronElec,display_time_start:display_time_end),2),3), 0, 1)/sqrt(size(subjs_decision_ERP,1))))';
boundedline(x2, y2, e2, '-b', 'alpha');
xlim([0 display_time_end-display_time_start])
% yl = ylim;
ylim([-10 10]);
% y=yl(1,1):0.2:yl(1,2);
y=-10:0.2:10;
plot((-display_time_start_from_zero_in_ms/(1000/EEG.srate))*ones(size(y)), y, 'LineWidth', 1) %plot a line on 0
axis ij
legend('','All different social roles','','Baseline')
title('soldier damage all different social roles decision vs baseline (frontal)')
