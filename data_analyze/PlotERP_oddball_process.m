%% Load ERP Matrix
close all;clear;clc;
load('oddball_ERP_26.mat');%选择要画ERP的数据
%% interest electrodes
FronElec = [8:12 17:21]; %frontal regions: Fz,F1,F3,F2,F4,FCz,FC1,FC3,FC2,FC4
CentElec = 26:30; %central regions: Cz,C1,C3,C2,C4
PariElec= 44:48; %parietal regions: Pz,P1,P3,P2,P4
OctrElec = [42 50 51 57]; %occipito-trmporal regions:PO7,PO8,P7,P8
all = 1:64;
%% Plot parameter
EEG.srate = 250;
display_time_start_from_zero_in_ms = -496; %Note that one can also go into - : this means it is left from 0, being a display of the baseline. Note also that you cannot display data that is not in your segmentation.
display_time_end_from_zero_in_ms = 1000; %Note also that you cannot display data that is not in your segmentation.
%display parameter for ERP:
display_time_start = display_time_start_from_zero_in_ms/(1000/EEG.srate)-(Segementation_time_start*EEG.srate); % dependent on the starting point of segement and sampling rate
display_time_end = display_time_end_from_zero_in_ms/(1000/EEG.srate)-(Segementation_time_start*EEG.srate); % dependent on the starting point of segement and sampling rate
%% set conditions
% social role condition
child_cond = 1;
pregnant_cond = 2;
civilian_cond = 3;
drug_cond = 4;
criminal_cond = 5;
none_cond = 6;
% subjectnum
subjectnum = 1:26;

%% calculate ERP
% basic condition
child_info = squeeze(nanmean(nanmean(nanmean(subjs_oddball_ERP(subjectnum,child_cond,CentElec,:),1),2),3));
pregnant_info = squeeze(nanmean(nanmean(nanmean(subjs_oddball_ERP(subjectnum,pregnant_cond,CentElec,:),1),2),3));
civilian_info = squeeze(nanmean(nanmean(nanmean(subjs_oddball_ERP(subjectnum,civilian_cond,CentElec,:),1),2),3));
drug_info = squeeze(nanmean(nanmean(nanmean(subjs_oddball_ERP(subjectnum,drug_cond,CentElec,:),1),2),3));
criminal_info = squeeze(nanmean(nanmean(nanmean(subjs_oddball_ERP(subjectnum,criminal_cond,CentElec,:),1),2),3));
none_info = squeeze(nanmean(nanmean(nanmean(subjs_oddball_ERP(subjectnum,none_cond,CentElec,:),1),2),3));
%% plot
%%%%%%%%%%%%%%%%%%% all different collateral damage info vs baseline(central) %%%%%%%%%%%%%%%%%%%
% elec:Central 
% social roles: all different social roles vs baseline
% condition: collateral damage
figure
x1 = 1:display_time_end-display_time_start+1;
y1 = double(child_info(display_time_start:display_time_end))';
e1 = double(squeeze(nanstd(nanmean(nanmean(subjs_oddball_ERP(subjectnum,child_cond ,CentElec,display_time_start:display_time_end),2),3), 0, 1)/sqrt(size(subjs_oddball_ERP,1))))';
boundedline(x1, y1, e1, '-r', 'alpha','linewidth',2); %#ok<*NANSTD>

hold on
x2 = 1:display_time_end-display_time_start+1;
y2 = double(pregnant_info(display_time_start:display_time_end))';
e2 = double(squeeze(nanstd(nanmean(nanmean(subjs_oddball_ERP(subjectnum,pregnant_cond ,CentElec,display_time_start:display_time_end),2),3), 0, 1)/sqrt(size(subjs_oddball_ERP,1))))';
boundedline(x2, y2, e2, '-y', 'alpha','linewidth',2); %#ok<*NANSTD>

hold on
x3 = 1:display_time_end-display_time_start+1;
y3 = double(civilian_info(display_time_start:display_time_end))';
e3 = double(squeeze(nanstd(nanmean(nanmean(subjs_oddball_ERP(subjectnum,civilian_cond ,CentElec,display_time_start:display_time_end),2),3), 0, 1)/sqrt(size(subjs_oddball_ERP,1))))';
boundedline(x3, y3, e3, '-k', 'alpha','linewidth',2); %#ok<*NANSTD>

hold on
x4 = 1:display_time_end-display_time_start+1;
y4 = double(drug_info(display_time_start:display_time_end))';
e4 = double(squeeze(nanstd(nanmean(nanmean(subjs_oddball_ERP(subjectnum,drug_cond ,CentElec,display_time_start:display_time_end),2),3), 0, 1)/sqrt(size(subjs_oddball_ERP,1))))';
boundedline(x4, y4, e4, '-b', 'alpha','linewidth',2); %#ok<*NANSTD>

hold on
x5 = 1:display_time_end-display_time_start+1;
y5 = double(criminal_info(display_time_start:display_time_end))';
e5 = double(squeeze(nanstd(nanmean(nanmean(subjs_oddball_ERP(subjectnum,criminal_cond ,CentElec,display_time_start:display_time_end),2),3), 0, 1)/sqrt(size(subjs_oddball_ERP,1))))';
boundedline(x5, y5, e5, '-g', 'alpha','linewidth',2); %#ok<*NANSTD>

hold on
x6 = 1:display_time_end-display_time_start+1;
y6 = double(none_info(display_time_start:display_time_end))';
e6 = double(squeeze(nanstd(nanmean(nanmean(subjs_oddball_ERP(subjectnum,none_cond ,CentElec,display_time_start:display_time_end),2),3), 0, 1)/sqrt(size(subjs_oddball_ERP,1))))';
boundedline(x6, y6, e6, '-m', 'alpha','linewidth',2); %#ok<*NANSTD>

% set(gca,'XTick',[0 (display_time_end-display_time_start)/5 (display_time_end-display_time_start)*2/5 (display_time_end-display_time_start)*3/5 (display_time_end-display_time_start)*4/5 display_time_end-display_time_start] ); %This are going to be the only values affected. Here, always 1/5 of the chosen time will be marked. If you want to change this, feel free to...
% set(gca,'XTickLabel',[display_time_start_from_zero_in_ms ((display_time_end_from_zero_in_ms-display_time_start_from_zero_in_ms)/5)+display_time_start_from_zero_in_ms ((display_time_end_from_zero_in_ms-display_time_start_from_zero_in_ms)*2/5)+display_time_start_from_zero_in_ms ((display_time_end_from_zero_in_ms-display_time_start_from_zero_in_ms)*3/5)+display_time_start_from_zero_in_ms ((display_time_end_from_zero_in_ms-display_time_start_from_zero_in_ms)*4/5)+display_time_start_from_zero_in_ms display_time_end_from_zero_in_ms] ); %This is what it's going to appear in those places.´

xlim([0 display_time_end-display_time_start])

% yl = ylim;
ylim([-10 10]);
% y=yl(1,1):0.2:yl(1,2);subjs_oddball_ERP
y=-10:0.2:10;
plot((-display_time_start_from_zero_in_ms/(1000/EEG.srate))*ones(size(y)), y, 'LineWidth', 1) %plot a line on 0
xticks([0 100 125 150 175 200 225 250 375]);
xticklabels({'-500' '-100' '0'  '100' '200' '300' '400' '500' '1000'});
axis ij
legend('','child','','pregnant','','civilian','','drug','','criminal','','none')
title('all different collateral damage info vs baseline (central)')
%% plot
%%%%%%%%%%%%%%%%%%% all different collateral damage info vs baseline (frontal)%%%%%%%%%%%%%%%%%%%
% elec:Frontal 
child_info = squeeze(nanmean(nanmean(nanmean(subjs_oddball_ERP(subjectnum,child_cond,FronElec,:),1),2),3));
pregnant_info = squeeze(nanmean(nanmean(nanmean(subjs_oddball_ERP(subjectnum,pregnant_cond,FronElec,:),1),2),3));
civilian_info = squeeze(nanmean(nanmean(nanmean(subjs_oddball_ERP(subjectnum,civilian_cond,FronElec,:),1),2),3));
drug_info = squeeze(nanmean(nanmean(nanmean(subjs_oddball_ERP(subjectnum,drug_cond,FronElec,:),1),2),3));
criminal_info = squeeze(nanmean(nanmean(nanmean(subjs_oddball_ERP(subjectnum,criminal_cond,FronElec,:),1),2),3));
none_info = squeeze(nanmean(nanmean(nanmean(subjs_oddball_ERP(subjectnum,none_cond,FronElec,:),1),2),3));
% social roles: all different social roles vs baseline
% condition: collateral damage
figure
x1 = 1:display_time_end-display_time_start+1;
y1 = double(child_info(display_time_start:display_time_end))';
e1 = double(squeeze(nanstd(nanmean(nanmean(subjs_oddball_ERP(subjectnum,child_cond ,FronElec,display_time_start:display_time_end),2),3), 0, 1)/sqrt(size(subjs_oddball_ERP,1))))';
boundedline(x1, y1, e1, '-r', 'alpha','linewidth',2); %#ok<*NANSTD>

hold on
x2 = 1:display_time_end-display_time_start+1;
y2 = double(pregnant_info(display_time_start:display_time_end))';
e2 = double(squeeze(nanstd(nanmean(nanmean(subjs_oddball_ERP(subjectnum,pregnant_cond ,FronElec,display_time_start:display_time_end),2),3), 0, 1)/sqrt(size(subjs_oddball_ERP,1))))';
boundedline(x2, y2, e2, '-y', 'alpha','linewidth',2); %#ok<*NANSTD>

hold on
x3 = 1:display_time_end-display_time_start+1;
y3 = double(civilian_info(display_time_start:display_time_end))';
e3 = double(squeeze(nanstd(nanmean(nanmean(subjs_oddball_ERP(subjectnum,civilian_cond ,FronElec,display_time_start:display_time_end),2),3), 0, 1)/sqrt(size(subjs_oddball_ERP,1))))';
boundedline(x3, y3, e3, '-k', 'alpha','linewidth',2); %#ok<*NANSTD>

hold on
x4 = 1:display_time_end-display_time_start+1;
y4 = double(drug_info(display_time_start:display_time_end))';
e4 = double(squeeze(nanstd(nanmean(nanmean(subjs_oddball_ERP(subjectnum,drug_cond ,FronElec,display_time_start:display_time_end),2),3), 0, 1)/sqrt(size(subjs_oddball_ERP,1))))';
boundedline(x4, y4, e4, '-b', 'alpha','linewidth',2); %#ok<*NANSTD>

hold on
x5 = 1:display_time_end-display_time_start+1;
y5 = double(criminal_info(display_time_start:display_time_end))';
e5 = double(squeeze(nanstd(nanmean(nanmean(subjs_oddball_ERP(subjectnum,criminal_cond ,FronElec,display_time_start:display_time_end),2),3), 0, 1)/sqrt(size(subjs_oddball_ERP,1))))';
boundedline(x5, y5, e5, '-g', 'alpha','linewidth',2); %#ok<*NANSTD>

hold on
x6 = 1:display_time_end-display_time_start+1;
y6 = double(none_info(display_time_start:display_time_end))';
e6 = double(squeeze(nanstd(nanmean(nanmean(subjs_oddball_ERP(subjectnum,none_cond ,FronElec,display_time_start:display_time_end),2),3), 0, 1)/sqrt(size(subjs_oddball_ERP,1))))';
boundedline(x6, y6, e6, '-m', 'alpha','linewidth',2); %#ok<*NANSTD>

% set(gca,'XTick',[0 (display_time_end-display_time_start)/5 (display_time_end-display_time_start)*2/5 (display_time_end-display_time_start)*3/5 (display_time_end-display_time_start)*4/5 display_time_end-display_time_start] ); %This are going to be the only values affected. Here, always 1/5 of the chosen time will be marked. If you want to change this, feel free to...
% set(gca,'XTickLabel',[display_time_start_from_zero_in_ms ((display_time_end_from_zero_in_ms-display_time_start_from_zero_in_ms)/5)+display_time_start_from_zero_in_ms ((display_time_end_from_zero_in_ms-display_time_start_from_zero_in_ms)*2/5)+display_time_start_from_zero_in_ms ((display_time_end_from_zero_in_ms-display_time_start_from_zero_in_ms)*3/5)+display_time_start_from_zero_in_ms ((display_time_end_from_zero_in_ms-display_time_start_from_zero_in_ms)*4/5)+display_time_start_from_zero_in_ms display_time_end_from_zero_in_ms] ); %This is what it's going to appear in those places.´
xlim([0 display_time_end-display_time_start]);
% yl = ylim;
ylim([-10 10]);
% 
% y=yl(1,1):0.2:yl(1,2);
y=-10:0.2:10;
plot((-display_time_start_from_zero_in_ms/(1000/EEG.srate))*ones(size(y)), y, 'LineWidth', 1) %plot a line on 0
xticks([0 100 125 150 175 200 225 250 375]);
xticklabels({'-500' '-100' '0'  '100' '200' '300' '400' '500' '1000'});
axis ij
legend('','child','','pregnant','','civilian','','drug','','criminal','','none')
title('all different collateral damage info vs baseline (frontal)')

%% plot
%%%%%%%%%%%%%%%%%%% all different collateral damage info vs baseline(all) %%%%%%%%%%%%%%%%%%%
% elec:Central 
% social roles: all different social roles vs baseline
% condition: collateral damage
child_info = squeeze(nanmean(nanmean(nanmean(subjs_oddball_ERP(subjectnum,child_cond,all,:),1),2),3));
pregnant_info = squeeze(nanmean(nanmean(nanmean(subjs_oddball_ERP(subjectnum,pregnant_cond,all,:),1),2),3));
civilian_info = squeeze(nanmean(nanmean(nanmean(subjs_oddball_ERP(subjectnum,civilian_cond,all,:),1),2),3));
drug_info = squeeze(nanmean(nanmean(nanmean(subjs_oddball_ERP(subjectnum,drug_cond,all,:),1),2),3));
criminal_info = squeeze(nanmean(nanmean(nanmean(subjs_oddball_ERP(subjectnum,criminal_cond,all,:),1),2),3));
none_info = squeeze(nanmean(nanmean(nanmean(subjs_oddball_ERP(subjectnum,none_cond,all,:),1),2),3));
figure
x1 = 1:display_time_end-display_time_start+1;
y1 = double(child_info(display_time_start:display_time_end))';
e1 = double(squeeze(nanstd(nanmean(nanmean(subjs_oddball_ERP(subjectnum,child_cond ,all,display_time_start:display_time_end),2),3), 0, 1)/sqrt(size(subjs_oddball_ERP,1))))';
boundedline(x1, y1, e1, '-r', 'alpha','linewidth',2); %#ok<*NANSTD>

hold on
x2 = 1:display_time_end-display_time_start+1;
y2 = double(pregnant_info(display_time_start:display_time_end))';
e2 = double(squeeze(nanstd(nanmean(nanmean(subjs_oddball_ERP(subjectnum,pregnant_cond ,all,display_time_start:display_time_end),2),3), 0, 1)/sqrt(size(subjs_oddball_ERP,1))))';
boundedline(x2, y2, e2, '-y', 'alpha','linewidth',2); %#ok<*NANSTD>

hold on
x3 = 1:display_time_end-display_time_start+1;
y3 = double(civilian_info(display_time_start:display_time_end))';
e3 = double(squeeze(nanstd(nanmean(nanmean(subjs_oddball_ERP(subjectnum,civilian_cond ,all,display_time_start:display_time_end),2),3), 0, 1)/sqrt(size(subjs_oddball_ERP,1))))';
boundedline(x3, y3, e3, '-k', 'alpha','linewidth',2); %#ok<*NANSTD>

hold on
x4 = 1:display_time_end-display_time_start+1;
y4 = double(drug_info(display_time_start:display_time_end))';
e4 = double(squeeze(nanstd(nanmean(nanmean(subjs_oddball_ERP(subjectnum,drug_cond ,all,display_time_start:display_time_end),2),3), 0, 1)/sqrt(size(subjs_oddball_ERP,1))))';
boundedline(x4, y4, e4, '-b', 'alpha','linewidth',2); %#ok<*NANSTD>

hold on
x5 = 1:display_time_end-display_time_start+1;
y5 = double(criminal_info(display_time_start:display_time_end))';
e5 = double(squeeze(nanstd(nanmean(nanmean(subjs_oddball_ERP(subjectnum,criminal_cond ,all,display_time_start:display_time_end),2),3), 0, 1)/sqrt(size(subjs_oddball_ERP,1))))';
boundedline(x5, y5, e5, '-g', 'alpha','linewidth',2); %#ok<*NANSTD>

hold on
x6 = 1:display_time_end-display_time_start+1;
y6 = double(none_info(display_time_start:display_time_end))';
e6 = double(squeeze(nanstd(nanmean(nanmean(subjs_oddball_ERP(subjectnum,none_cond ,all,display_time_start:display_time_end),2),3), 0, 1)/sqrt(size(subjs_oddball_ERP,1))))';
boundedline(x6, y6, e6, '-m', 'alpha','linewidth',2); %#ok<*NANSTD>

% set(gca,'XTick',[0 (display_time_end-display_time_start)/5 (display_time_end-display_time_start)*2/5 (display_time_end-display_time_start)*3/5 (display_time_end-display_time_start)*4/5 display_time_end-display_time_start] ); %This are going to be the only values affected. Here, always 1/5 of the chosen time will be marked. If you want to change this, feel free to...
% set(gca,'XTickLabel',[display_time_start_from_zero_in_ms ((display_time_end_from_zero_in_ms-display_time_start_from_zero_in_ms)/5)+display_time_start_from_zero_in_ms ((display_time_end_from_zero_in_ms-display_time_start_from_zero_in_ms)*2/5)+display_time_start_from_zero_in_ms ((display_time_end_from_zero_in_ms-display_time_start_from_zero_in_ms)*3/5)+display_time_start_from_zero_in_ms ((display_time_end_from_zero_in_ms-display_time_start_from_zero_in_ms)*4/5)+display_time_start_from_zero_in_ms display_time_end_from_zero_in_ms] ); %This is what it's going to appear in those places.´

xlim([0 display_time_end-display_time_start]);
% yl = ylim;
ylim([-10 10]);
% y=yl(1,1):0.2:yl(1,2);subjs_oddball_ERP
y=-10:0.2:10;
plot((-display_time_start_from_zero_in_ms/(1000/EEG.srate))*ones(size(y)), y, 'LineWidth', 1) %plot a line on 0
xticks([0 100 125 150 175 200 225 250 375]);
xticklabels({'-500' '-100' '0'  '100' '200' '300' '400' '500' '1000'});
axis ij
legend('','child','','pregnant','','civilian','','drug','','criminal','','none')
title('all different collateral damage info vs baseline (all)')

%% plot
%%%%%%%%%%%%%%%%%%% all different collateral damage info vs baseline(PariElec) %%%%%%%%%%%%%%%%%%%
% elec:Central 
% social roles: all different social roles vs baseline
% condition: collateral damage
child_info = squeeze(nanmean(nanmean(nanmean(subjs_oddball_ERP(subjectnum,child_cond,PariElec,:),1),2),3));
pregnant_info = squeeze(nanmean(nanmean(nanmean(subjs_oddball_ERP(subjectnum,pregnant_cond,PariElec,:),1),2),3));
civilian_info = squeeze(nanmean(nanmean(nanmean(subjs_oddball_ERP(subjectnum,civilian_cond,PariElec,:),1),2),3));
drug_info = squeeze(nanmean(nanmean(nanmean(subjs_oddball_ERP(subjectnum,drug_cond,PariElec,:),1),2),3));
criminal_info = squeeze(nanmean(nanmean(nanmean(subjs_oddball_ERP(subjectnum,criminal_cond,PariElec,:),1),2),3));
none_info = squeeze(nanmean(nanmean(nanmean(subjs_oddball_ERP(subjectnum,none_cond,PariElec,:),1),2),3));
figure
x1 = 1:display_time_end-display_time_start+1;
y1 = double(child_info(display_time_start:display_time_end))';
e1 = double(squeeze(nanstd(nanmean(nanmean(subjs_oddball_ERP(subjectnum,child_cond,PariElec,display_time_start:display_time_end),2),3), 0, 1)/sqrt(size(subjs_oddball_ERP,1))))';
boundedline(x1, y1, e1, '-r', 'alpha','linewidth',2); %#ok<*NANSTD>

hold on
x2 = 1:display_time_end-display_time_start+1;
y2 = double(pregnant_info(display_time_start:display_time_end))';
e2 = double(squeeze(nanstd(nanmean(nanmean(subjs_oddball_ERP(subjectnum,pregnant_cond ,PariElec,display_time_start:display_time_end),2),3), 0, 1)/sqrt(size(subjs_oddball_ERP,1))))';
boundedline(x2, y2, e2, '-y', 'alpha','linewidth',2); %#ok<*NANSTD>

hold on
x3 = 1:display_time_end-display_time_start+1;
y3 = double(civilian_info(display_time_start:display_time_end))';
e3 = double(squeeze(nanstd(nanmean(nanmean(subjs_oddball_ERP(subjectnum,civilian_cond ,PariElec,display_time_start:display_time_end),2),3), 0, 1)/sqrt(size(subjs_oddball_ERP,1))))';
boundedline(x3, y3, e3, '-k', 'alpha','linewidth',2); %#ok<*NANSTD>

hold on
x4 = 1:display_time_end-display_time_start+1;
y4 = double(drug_info(display_time_start:display_time_end))';
e4 = double(squeeze(nanstd(nanmean(nanmean(subjs_oddball_ERP(subjectnum,drug_cond ,PariElec,display_time_start:display_time_end),2),3), 0, 1)/sqrt(size(subjs_oddball_ERP,1))))';
boundedline(x4, y4, e4, '-b', 'alpha','linewidth',2); %#ok<*NANSTD>

hold on
x5 = 1:display_time_end-display_time_start+1;
y5 = double(criminal_info(display_time_start:display_time_end))';
e5 = double(squeeze(nanstd(nanmean(nanmean(subjs_oddball_ERP(subjectnum,criminal_cond ,PariElec,display_time_start:display_time_end),2),3), 0, 1)/sqrt(size(subjs_oddball_ERP,1))))';
boundedline(x5, y5, e5, '-g', 'alpha','linewidth',2); %#ok<*NANSTD>

hold on
x6 = 1:display_time_end-display_time_start+1;
y6 = double(none_info(display_time_start:display_time_end))';
e6 = double(squeeze(nanstd(nanmean(nanmean(subjs_oddball_ERP(subjectnum,none_cond ,PariElec,display_time_start:display_time_end),2),3), 0, 1)/sqrt(size(subjs_oddball_ERP,1))))';
boundedline(x6, y6, e6, '-m', 'alpha','linewidth',2); %#ok<*NANSTD>

% set(gca,'XTick',[0 (display_time_end-display_time_start)/5 (display_time_end-display_time_start)*2/5 (display_time_end-display_time_start)*3/5 (display_time_end-display_time_start)*4/5 display_time_end-display_time_start] ); %This are going to be the only values affected. Here, always 1/5 of the chosen time will be marked. If you want to change this, feel free to...
% set(gca,'XTickLabel',[display_time_start_from_zero_in_ms ((display_time_end_from_zero_in_ms-display_time_start_from_zero_in_ms)/5)+display_time_start_from_zero_in_ms ((display_time_end_from_zero_in_ms-display_time_start_from_zero_in_ms)*2/5)+display_time_start_from_zero_in_ms ((display_time_end_from_zero_in_ms-display_time_start_from_zero_in_ms)*3/5)+display_time_start_from_zero_in_ms ((display_time_end_from_zero_in_ms-display_time_start_from_zero_in_ms)*4/5)+display_time_start_from_zero_in_ms display_time_end_from_zero_in_ms] ); %This is what it's going to appear in those places.´

xlim([0 display_time_end-display_time_start]);
% yl = ylim;
ylim([-10 10]);
% y=yl(1,1):0.2:yl(1,2);subjs_oddball_ERP
y=-10:0.2:10;
plot((-display_time_start_from_zero_in_ms/(1000/EEG.srate))*ones(size(y)), y, 'LineWidth', 1) %plot a line on 0
xticks([0 100 125 150 175 200 225 250 375]);
xticklabels({'-500' '-100' '0'  '100' '200' '300' '400' '500' '1000'});
axis ij
legend('','child','','pregnant','','civilian','','drug','','criminal','','none')
title('all different collateral damage info vs baseline (Pari)')

%% plot
%%%%%%%%%%%%%%%%%%% all different collateral damage info vs baseline(OctrElec) %%%%%%%%%%%%%%%%%%%
% elec:Central 
% social roles: all different social roles vs baseline
% condition: collateral damage
child_info = squeeze(nanmean(nanmean(nanmean(subjs_oddball_ERP(subjectnum,child_cond,OctrElec,:),1),2),3));
pregnant_info = squeeze(nanmean(nanmean(nanmean(subjs_oddball_ERP(subjectnum,pregnant_cond,OctrElec,:),1),2),3));
civilian_info = squeeze(nanmean(nanmean(nanmean(subjs_oddball_ERP(subjectnum,civilian_cond,OctrElec,:),1),2),3));
drug_info = squeeze(nanmean(nanmean(nanmean(subjs_oddball_ERP(subjectnum,drug_cond,OctrElec,:),1),2),3));
criminal_info = squeeze(nanmean(nanmean(nanmean(subjs_oddball_ERP(subjectnum,criminal_cond,OctrElec,:),1),2),3));
none_info = squeeze(nanmean(nanmean(nanmean(subjs_oddball_ERP(subjectnum,none_cond,OctrElec,:),1),2),3));
figure
x1 = 1:display_time_end-display_time_start+1;
y1 = double(child_info(display_time_start:display_time_end))';
e1 = double(squeeze(nanstd(nanmean(nanmean(subjs_oddball_ERP(subjectnum,child_cond,OctrElec,display_time_start:display_time_end),2),3), 0, 1)/sqrt(size(subjs_oddball_ERP,1))))';
boundedline(x1, y1, e1, '-r', 'alpha','linewidth',2); %#ok<*NANSTD>

hold on
x2 = 1:display_time_end-display_time_start+1;
y2 = double(pregnant_info(display_time_start:display_time_end))';
e2 = double(squeeze(nanstd(nanmean(nanmean(subjs_oddball_ERP(subjectnum,pregnant_cond ,OctrElec,display_time_start:display_time_end),2),3), 0, 1)/sqrt(size(subjs_oddball_ERP,1))))';
boundedline(x2, y2, e2, '-y', 'alpha','linewidth',2); %#ok<*NANSTD>

hold on
x3 = 1:display_time_end-display_time_start+1;
y3 = double(civilian_info(display_time_start:display_time_end))';
e3 = double(squeeze(nanstd(nanmean(nanmean(subjs_oddball_ERP(subjectnum,civilian_cond ,OctrElec,display_time_start:display_time_end),2),3), 0, 1)/sqrt(size(subjs_oddball_ERP,1))))';
boundedline(x3, y3, e3, '-k', 'alpha','linewidth',2); %#ok<*NANSTD>

hold on
x4 = 1:display_time_end-display_time_start+1;
y4 = double(drug_info(display_time_start:display_time_end))';
e4 = double(squeeze(nanstd(nanmean(nanmean(subjs_oddball_ERP(subjectnum,drug_cond ,OctrElec,display_time_start:display_time_end),2),3), 0, 1)/sqrt(size(subjs_oddball_ERP,1))))';
boundedline(x4, y4, e4, '-b', 'alpha','linewidth',2); %#ok<*NANSTD>

hold on
x5 = 1:display_time_end-display_time_start+1;
y5 = double(criminal_info(display_time_start:display_time_end))';
e5 = double(squeeze(nanstd(nanmean(nanmean(subjs_oddball_ERP(subjectnum,criminal_cond ,OctrElec,display_time_start:display_time_end),2),3), 0, 1)/sqrt(size(subjs_oddball_ERP,1))))';
boundedline(x5, y5, e5, '-g', 'alpha','linewidth',2); %#ok<*NANSTD>

hold on
x6 = 1:display_time_end-display_time_start+1;
y6 = double(none_info(display_time_start:display_time_end))';
e6 = double(squeeze(nanstd(nanmean(nanmean(subjs_oddball_ERP(subjectnum,none_cond ,OctrElec,display_time_start:display_time_end),2),3), 0, 1)/sqrt(size(subjs_oddball_ERP,1))))';
boundedline(x6, y6, e6, '-m', 'alpha','linewidth',2); %#ok<*NANSTD>

% set(gca,'XTick',[0 (display_time_end-display_time_start)/5 (display_time_end-display_time_start)*2/5 (display_time_end-display_time_start)*3/5 (display_time_end-display_time_start)*4/5 display_time_end-display_time_start] ); %This are going to be the only values affected. Here, always 1/5 of the chosen time will be marked. If you want to change this, feel free to...
% set(gca,'XTickLabel',[display_time_start_from_zero_in_ms ((display_time_end_from_zero_in_ms-display_time_start_from_zero_in_ms)/5)+display_time_start_from_zero_in_ms ((display_time_end_from_zero_in_ms-display_time_start_from_zero_in_ms)*2/5)+display_time_start_from_zero_in_ms ((display_time_end_from_zero_in_ms-display_time_start_from_zero_in_ms)*3/5)+display_time_start_from_zero_in_ms ((display_time_end_from_zero_in_ms-display_time_start_from_zero_in_ms)*4/5)+display_time_start_from_zero_in_ms display_time_end_from_zero_in_ms] ); %This is what it's going to appear in those places.´

xlim([0 display_time_end-display_time_start]);
% yl = ylim;
ylim([-10 10]);
% y=yl(1,1):0.2:yl(1,2);subjs_oddball_ERP
y=-10:0.2:10;
plot((-display_time_start_from_zero_in_ms/(1000/EEG.srate))*ones(size(y)), y, 'LineWidth', 1) %plot a line on 0
xticks([0 100 125 150 175 200 225 250 375]);
xticklabels({'-500' '-100' '0'  '100' '200' '300' '400' '500' '1000'});
axis ij
legend('','child','','pregnant','','civilian','','drug','','criminal','','none')
title('all different collateral damage info vs baseline (Octr)')
