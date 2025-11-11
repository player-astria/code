%% 
clear

load('oddball_ERP_50.mat');

ps = [];
p1s =[];
cors = [];
for t = 1:371
ERPs = squeeze(nanmean(nanmean(subjs_oddball_ERP(:,1:5,:,t:t+4),1),4));
ERPs = reshape(ERPs,5,[]);
ERPs = zscore(ERPs);
ERPs_rdm = cosmo_pdist(ERPs(:,:),'correlation');

% theory_rdm = [0,0,0,0,0.5,0.5,0.5,0.5,0.5,0.5];
theory_rdm = [0,0,0,0,0.5,0.5,0.5,0.5,0.5,0.7];
lm = fitlm(theory_rdm,ERPs_rdm);
p = lm.Coefficients.pValue(2);
ps = [ps p];

[cor,p1] = corr([ERPs_rdm;theory_rdm]');
p1s = [p1s p1];
cors = [cors cor(1,2)]; 

end
salient1 = ps(ps<0.05);
salient2 = p1s(p1s<0.05);
plot(1:371,cors);

%% original code
% load inter.mat
% a=1;
% RT=zscore(RT);beta=zscore(beta);SP=zscore(SP);theta=zscore(theta);
% RT_rdm1=cosmo_pdist(RT(:,a),'euclidean');%'euclidean'£¬'correlation','mahalanobis(ÂíÊÏ¾àÀë£¬ÐÞÕýºóµÄÅ·ÊÏ¾àÀë)','cityblock'
% beta_rdm1=cosmo_pdist(beta(:,a),'euclidean');%'euclidean'£¬'correlation','mahalanobis(ÂíÊÏ¾àÀë£¬ÐÞÕýºóµÄÅ·ÊÏ¾àÀë)','cityblock'
% theta_rdm1=cosmo_pdist(theta(:,a),'euclidean');%'euclidean'£¬'correlation','mahalanobis(ÂíÊÏ¾àÀë£¬ÐÞÕýºóµÄÅ·ÊÏ¾àÀë)','cityblock'
% Sp_rdm1=cosmo_pdist(SP(:,a),'euclidean');%'euclidean'£¬'correlation','mahalanobis(ÂíÊÏ¾àÀë£¬ÐÞÕýºóµÄÅ·ÊÏ¾àÀë)','cityblock'
% 
% RT_rdm1=RT_rdm1';
% beta_rdm1=beta_rdm1';
% theta_rdm1=theta_rdm1';
% Sp_rdm1=Sp_rdm1';
% 
% X=[beta_rdm1,theta_rdm1,Sp_rdm1];
% lm = fitlm(X,RT_rdm1);
