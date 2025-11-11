function [y_s, p_s] = plot_ERP(zoom,titlename, line_type,legendname)
%% zoom is brain zoom; titlename is the title of picture; line_type is the line you want to draw

%% load file
load("D:\LHD\oddball\LHD程序20250320\data_analyze\oddball_ERP_50.mat")
%% only use it
% FronElec = [8:12 17:21];
% zoom = FronEle
% titlename = 'child vs no-collateral damage';
% line_type = [5 6];
% legendname = 'test';
%% Plot parameter
EEG.srate = 250;
display_time_start_from_zero_in_ms = -200; %Note that one can also go into - : this means it is left from 0, being a display of the baseline. Note also that you cannot display data that is not in your segmentation.
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
subjectnum = 1:50;

child_info = squeeze(nanmean(nanmean(nanmean(subjs_oddball_ERP(subjectnum,child_cond,zoom,:)-subjs_oddball_ERP(subjectnum,none_cond,zoom,:),1),2),3));
pregnant_info = squeeze(nanmean(nanmean(nanmean(subjs_oddball_ERP(subjectnum,pregnant_cond,zoom,:)-subjs_oddball_ERP(subjectnum,none_cond,zoom,:),1),2),3));
civilian_info = squeeze(nanmean(nanmean(nanmean(subjs_oddball_ERP(subjectnum,civilian_cond,zoom,:)-subjs_oddball_ERP(subjectnum,none_cond,zoom,:),1),2),3));
drug_info = squeeze(nanmean(nanmean(nanmean(subjs_oddball_ERP(subjectnum,drug_cond,zoom,:)-subjs_oddball_ERP(subjectnum,none_cond,zoom,:),1),2),3));
criminal_info = squeeze(nanmean(nanmean(nanmean(subjs_oddball_ERP(subjectnum,criminal_cond,zoom,:)-subjs_oddball_ERP(subjectnum,none_cond,zoom,:),1),2),3));
none_info = squeeze(nanmean(nanmean(nanmean(subjs_oddball_ERP(subjectnum,none_cond,zoom,:)-subjs_oddball_ERP(subjectnum,none_cond,zoom,:),1),2),3));

used_typenum = size(line_type,2);
y_s(:,:,:) = nan(used_typenum,50,301);
current_layer = 0; %y_s已经被使用的层数
%% plot
%%%%%%%%%%%%%%%%%%% all different collateral damage info vs baseline() %%%%%%%%%%%%%%%%%%%
% elec:Central 
% social roles: all different social roles vs baseline
% condition: collateral damage
% subplot(plot_type(1),plot_type(2),plot_pos)
if any(ismember(line_type,1))
        x1 = 1:display_time_end-display_time_start+1;
        y1 = double(child_info(display_time_start:display_time_end))';
        e1 = double(squeeze(nanstd(nanmean(nanmean(subjs_oddball_ERP(subjectnum,child_cond ,zoom,display_time_start:display_time_end),2),3), 0, 1)/sqrt(size(subjs_oddball_ERP,1))))';
        boundedline(x1, y1, e1, '-r', 'alpha','linewidth',2); %#ok<*NANSTD>
        hold on
        current_layer = current_layer + 1;
        temdata = squeeze(nanmean(subjs_oddball_ERP(subjectnum,child_cond,zoom,display_time_start:display_time_end)-subjs_oddball_ERP(subjectnum,none_cond,zoom,display_time_start:display_time_end),3));
        y_s(current_layer,:,:) = reshape(temdata,1,50,[]);
end
if any(ismember(line_type,2))
        x2 = 1:display_time_end-display_time_start+1;
        y2 = double(pregnant_info(display_time_start:display_time_end))';
        e2 = double(squeeze(nanstd(nanmean(nanmean(subjs_oddball_ERP(subjectnum,pregnant_cond ,zoom,display_time_start:display_time_end),2),3), 0, 1)/sqrt(size(subjs_oddball_ERP,1))))';
        boundedline(x2, y2, e2,'color',[1 0.6 0.2], 'alpha','linewidth',2); %#ok<*NANSTD>
        hold on
        current_layer = current_layer + 1;
        temdata = squeeze(nanmean(subjs_oddball_ERP(subjectnum,pregnant_cond,zoom,display_time_start:display_time_end)-subjs_oddball_ERP(subjectnum,none_cond,zoom,display_time_start:display_time_end),3));
        y_s(current_layer,:,:) = reshape(temdata,1,50,[]);
end
if any(ismember(line_type,3))
        x3 = 1:display_time_end-display_time_start+1;
        y3 = double(civilian_info(display_time_start:display_time_end))';
        e3 = double(squeeze(nanstd(nanmean(nanmean(subjs_oddball_ERP(subjectnum,civilian_cond ,zoom,display_time_start:display_time_end),2),3), 0, 1)/sqrt(size(subjs_oddball_ERP,1))))';
        boundedline(x3, y3, e3, '-k', 'alpha','linewidth',2); %#ok<*NANSTD>
        hold on
        current_layer = current_layer + 1;
        temdata = squeeze(nanmean(subjs_oddball_ERP(subjectnum,civilian_cond,zoom,display_time_start:display_time_end)-subjs_oddball_ERP(subjectnum,none_cond,zoom,display_time_start:display_time_end),3));
        y_s(current_layer,:,:) = reshape(temdata,1,50,[]);
end
if any(ismember(line_type,4))
        x4 = 1:display_time_end-display_time_start+1;
        y4 = double(drug_info(display_time_start:display_time_end))';
        e4 = double(squeeze(nanstd(nanmean(nanmean(subjs_oddball_ERP(subjectnum,drug_cond ,zoom,display_time_start:display_time_end),2),3), 0, 1)/sqrt(size(subjs_oddball_ERP,1))))';
        boundedline(x4, y4, e4, '-b', 'alpha','linewidth',2); %#ok<*NANSTD>
        hold on
        current_layer = current_layer + 1;
        temdata = squeeze(nanmean(subjs_oddball_ERP(subjectnum,drug_cond,zoom,display_time_start:display_time_end)-subjs_oddball_ERP(subjectnum,none_cond,zoom,display_time_start:display_time_end),3));
        y_s(current_layer,:,:) = reshape(temdata,1,50,[]);
end
if any(ismember(line_type,5))
        x5 = 1:display_time_end-display_time_start+1;
        y5 = double(criminal_info(display_time_start:display_time_end))';
        e5 = double(squeeze(nanstd(nanmean(nanmean(subjs_oddball_ERP(subjectnum,criminal_cond ,zoom,display_time_start:display_time_end),2),3), 0, 1)/sqrt(size(subjs_oddball_ERP,1))))';
        boundedline(x5, y5, e5, '-g', 'alpha','linewidth',2); %#ok<*NANSTD>
        hold on
        current_layer = current_layer + 1;
        temdata = squeeze(nanmean(subjs_oddball_ERP(subjectnum,criminal_cond,zoom,display_time_start:display_time_end)-subjs_oddball_ERP(subjectnum,none_cond,zoom,display_time_start:display_time_end),3));
        y_s(current_layer,:,:) = reshape(temdata,1,50,[]);
end
if any(ismember(line_type,6))
        x6 = 1:display_time_end-display_time_start+1;
        y6 = double(none_info(display_time_start:display_time_end))';
        e6 = double(squeeze(nanstd(nanmean(nanmean(subjs_oddball_ERP(subjectnum,none_cond ,zoom,display_time_start:display_time_end),2),3), 0, 1)/sqrt(size(subjs_oddball_ERP,1))))';
        boundedline(x6, y6, e6, '-m', 'alpha','linewidth',2); %#ok<*NANSTD>
        hold on 
        current_layer = current_layer + 1;
        temdata = squeeze(nanmean(subjs_oddball_ERP(subjectnum,none_cond,zoom,display_time_start:display_time_end)-subjs_oddball_ERP(subjectnum,none_cond,zoom,display_time_start:display_time_end),3));
        y_s(current_layer,:,:) = reshape(temdata,1,50,[]);
end
% set(gca,'XTick',[0 (display_time_end-display_time_start)/5 (display_time_end-display_time_start)*2/5 (display_time_end-display_time_start)*3/5 (display_time_end-display_time_start)*4/5 display_time_end-display_time_start] ); %This are going to be the only values affected. Here, always 1/5 of the chosen time will be marked. If you want to change this, feel free to...
% set(gca,'XTickLabel',[display_time_start_from_zero_in_ms ((display_time_end_from_zero_in_ms-display_time_start_from_zero_in_ms)/5)+display_time_start_from_zero_in_ms ((display_time_end_from_zero_in_ms-display_time_start_from_zero_in_ms)*2/5)+display_time_start_from_zero_in_ms ((display_time_end_from_zero_in_ms-display_time_start_from_zero_in_ms)*3/5)+display_time_start_from_zero_in_ms ((display_time_end_from_zero_in_ms-display_time_start_from_zero_in_ms)*4/5)+display_time_start_from_zero_in_ms display_time_end_from_zero_in_ms] ); %This is what it's going to appear in those places.´
legend(legendname);

p_s = [];
for l = 1:(display_time_end-display_time_start)
    [~,p] = ttest(y_s(1,:,l),y_s(2,:,l));
    p_s = [p_s p];
end

%画显著条
idx = p_s<0.001;
x7 = 1:(display_time_end-display_time_start);
y7 = 9*ones(size(x7));
plot (x7(idx), y7(idx), 'r-', 'LineWidth', 4,'HandleVisibility', 'off');
hold on

y_conditional = y7;
y_conditional (idx) = NaN;
plot (x7, y_conditional,'color',[1 1 1], 'LineWidth', 4,'HandleVisibility', 'off');
hold on;

xlim([0 display_time_end-display_time_start])
ylim([-10 10]);

y=-10:0.2:10;
plot((-display_time_start_from_zero_in_ms/(1000/EEG.srate))*ones(size(y)), y,'color',[0.4 0.4 0.4], 'LineWidth', 1,'HandleVisibility', 'off') %plot a line on 0
hold on

x_=0:300;
y_=0*ones(size(x_));
plot(x_,y_, 'color',[0.4 0.4 0.4],'LineWidth', 1,'HandleVisibility', 'off');

set(gca, 'YDir', 'reverse');
xticks([0 25 50 75 100 125 150 175 200 225 250 275 300]);
xticklabels({'-200' '-100' '0'  '100' '200' '300' '400' '500' '600' '700' '800' '900' '1000'});
% axis ij
% legend('','child','','pregnant','','civilian','','drug','','criminal','','none')
% 

title(titlename);
end
