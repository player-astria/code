%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% STEP 13a: Topoplot peak window
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;
clear;


%%%"THE GREAT CHANGE": Load EEGlab new if not done so in this script. Might not be necessary if loaded previously. Note that all in EEG struct will be overwritten.
%check whether your matlab knows the EEGlab topoplot function... therefore just load it once more...
eeglab
%load a montage to plot in. This montage should be saved during STEP 16 in preprocessing to ICA

load("oddball_ERP_30.mat")
load('montage_for_topoplot.mat') % montage file
%%%"THE GREAT CHANGE": Choose your scaling: Adjust it to the data: If you see all green, blue or all red, it is not appropriate.
%Scaling of topoplot: Has to be adjusted ! Automatical borders are not chosen in order to get comparable topographical maps if more time steps or conditions are chosen.
Grenz = 4;
minmax = [-Grenz Grenz];
%%%"THE GREAT CHANGE": Choose which time window to display (r1,r2,r3...)

%画380-460ms和560-640ms，[145 165],[190 210]
%choose the time window
windowlength = 20;
Peak_window_start_t = 200-windowlength/2; 
Peak_fenster_ende_t = 200+windowlength/2; 

display_time_start_from_zero_in_ms_GIF_topo = 560; %Note that one can also go into - : this means it is left from 0, being a display of the baseline. Note also that you cannot display data that is not in your segmentation.
display_time_end_from_zero_in_ms_GIF_topo = 640; %Note also that you cannot display data that is not in your segmentation.
Segementation_time_start = -0.2;
display_time_start_GIF_topo = display_time_start_from_zero_in_ms_GIF_topo/(1000/EEG.srate)-(Segementation_time_start*EEG.srate); % dependent on the starting point of segement and sampling rate
display_time_end_GIF_topo = display_time_end_from_zero_in_ms_GIF_topo/(1000/EEG.srate)-(Segementation_time_start*EEG.srate); % dependent on the starting point of segement and sampling rate
timesteps_in_ms = 20;
timesteps = timesteps_in_ms/(1000/EEG.srate);
types = {'child','pregnant','civilian','drug','criminal'};
for i=1:5
%%%"THE GREAT CHANGE": Choose which conditions to display or whether all is displayed. Also choose whether your conditions where equally often
%conditions_of_interest2 = [condition_of_interest1A condition_of_interest1B condition_of_interest2A condition_of_interest2B condition_of_interest3A condition_of_interest3B];
datavector = double(squeeze(nanmean(nanmean(nanmean(subjs_oddball_ERP(:,i,:,Peak_window_start_t:Peak_fenster_ende_t),1),2),4))); 

%create topoplot figure:

figure
topoplot(datavector, EEG.chanlocs,'maplimits', minmax )
%%%"THE GREAT CHANGE": Choose a title for the plot and the font size
%%name the plot appropriate
pictruename = ['Topography of ' types{i} ' ' num2str(Peak_window_start_t*1000/EEG.srate+Segementation_time_start*1000),'ms to ' num2str(Peak_fenster_ende_t*1000/EEG.srate+Segementation_time_start*1000) 'ms'];
title(pictruename, 'FontSize', 14)
colorbar
set(gcf, 'color', [1 1 1])

saveas(gcf, [pictruename '.png']);
end
%
%%%"THE GREAT CHANGE": Change the name of the exported file or its´ resolution or its´ format
%%Export this plot automatically
% export_fig 'Wuhuhutopographyofpeakwindow' '-tif' '-r400'

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%END OF STEP 13a
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% STEP 13b: Topoplot Gif
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%"THE GREAT CHANGE": Choose your scaling: Adjust it to the data: If you see all green, blue or all red, it is not appropriate.
%Scaling of topoplot: Has to be adjusted ! Automatical borders are not chosen in order to get comparable topographical maps if more time steps or conditions are chosen.
Grenz = 4;
minmax = [-Grenz Grenz];

%%%"THE GREAT CHANGE": Choose which conditions to display or whether all is displayed (note: the second dimension are the conditions)
%create the different plots
%%%"THE GREAT CHANGE": Choose which conditions to display or whether all is displayed
%conditions_of_interest2 = [condition_of_interest1A condition_of_interest1B condition_of_interest2A condition_of_interest2B condition_of_interest3A condition_of_interest3B];
%Plot_quick = squeeze(nanmean(nanmean(Total_mean_signal_array(:,conditions_of_interest2,:,:),2),1)),;	%make short helping array	
%Plot_quick = squeeze(nanmean(nanmean(Total_mean_signal_array(:,conditions_of_interest2,:,:),2),1)/mean(nonzeros(Casecheck(:,conditions_of_interest2)'))),;	%make short helping array	
Plot_quick = squeeze(nanmean(nanmean(subjs_oddball_ERP(:,:,:,:),2),1));	%make short helping array	
%Plot_quick = squeeze(nanmean(nanmean(wTotal_mean_signal_array(:,:,:,:),2),1)/mean(nonzeros(Casecheck'))),;	%make short helping array	

fig = figure;
for idx = display_time_start_GIF_topo:timesteps:display_time_end_GIF_topo
	Peak_window_start_topo = idx;
	Peak_fenster_ende_topo = idx+timesteps-1;
	datavector = squeeze(nanmean(Plot_quick(:,Peak_window_start_topo:Peak_fenster_ende_topo),2));
	topoplot(datavector, EEG.chanlocs, 'style', 'map', 'maplimits',  minmax )
    %%%"THE GREAT CHANGE": Choose a title for the plot and control the font size
    title(['Topography during time window ',num2str(Peak_window_start_topo*1000/EEG.srate+Segementation_time_start*1000),'ms to ' num2str(Peak_fenster_ende_topo*1000/EEG.srate+Segementation_time_start*1000+4) 'ms'], 'FontSize', 14)
	colorbar
	drawnow
	set(gcf, 'color', [1 1 1])
	frame = getframe(fig);
	im{idx} = frame2im(frame);
end
close

%put all plots together

%%%"THE GREAT CHANGE": Change the name of the exported file 
%%Export this plot automatically

filename = 'oddball_all_0-800.gif'; % Specify the output file name
for idx = display_time_start_GIF_topo:timesteps:display_time_end_GIF_topo
    [A,map] = rgb2ind(im{idx},256);
    if idx == display_time_start_GIF_topo
        imwrite(A,map,filename,'gif','LoopCount',Inf,'DelayTime',1);
    else
        imwrite(A,map,filename,'gif','WriteMode','append','DelayTime',1);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%END OF STEP 13b
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
