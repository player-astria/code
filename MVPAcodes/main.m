clear; 
clc;
type1s = [2,3,4,5]; % pregnant
type2 = 1; % child
zoom = 38;%(CPZ)
zoom = [1 3 6 10 14 24 30 46 52 55 61 63];
for i = 1
    type1 = type1s(i);
    oddball_classify_trial_interaction(type1,type2,zoom);
end

type1 = 1;
type2 =2;
zoom = 1;

acc_raw = [];
all_acc_raw = nan(4,371,5);
k=1;
specifics = [];
sense = [];
i=2;
for i = 2:5
    filename1 = [num2str(i) '_acc_final_beta.mat'];
    load(filename1);
    filename2 = [num2str(i) '_all_acc_beta.mat'];
    load(filename2);
    filename3 = [num2str(i) '_specificity_beta.mat'];
    load(filename3);
    filename4 = [num2str(i) '_sensitivity_beta.mat'];
    load(filename4);
    acc_raw = [acc_raw; acc_final];
    all_acc_raw(k,:,:) = all_acc;
    specifics = [specifics specificity];
    sense = [sense sensitivity];
    k=k+1;
end

titlenames = {'pregnant vs child','civilian vs chils','drug vs child','criminal vs child'};
for i =1:4
figure
plot(1:371,acc_raw(i,:));
hold on 
    ps= [];
    for t = 1:371  
    [~,p] = ttest(all_acc_raw(i,t,:), 50, 'Tail', 'right');
    ps = [ps p];
    end
idx = ps<0.01;
x = 1:371;
y = 45*ones(size(x));
x(~idx) = nan;
y(~idx) = nan;
plot(x,y, 'r-', 'LineWidth', 4,'HandleVisibility', 'off');
hold on
plot(1:371,50*ones(371),'color',[0.4 0.4 0.4],'LineWidth', 1,'HandleVisibility', 'off');
xlim([1,371]);
ylim([40,60]);
xticks([0 75 100 125 150 175 200 225 250 275 300 325 350 375]);
xticklabels({'-500' '-200' '-100' '0' '100' '200' '300' '400' '500' '600' '700' '800' '900' '1000'});
titlename =titlenames(i);
title(titlenames(i));
picturename = string(strcat(titlename, '.png'));
saveas(gcf, picturename)
end

