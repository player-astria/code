function [bestacc,bestc,bestg] = SVMcgForClass_NoDisplay_linear(train_label,train_data,cmin,cmax,v,cstep)
% SVMcg cross validation by faruto
% by faruto
% Email:patrick.lee@foxmail.com 
% QQ:516667408 
% http://blog.sina.com.cn/faruto
% last modified 2011.06.08
%
% 若转载请注明：
% faruto and liyang , LIBSVM-farutoUltimateVersion 
% a toolbox with implements for support vector machines based on libsvm, 2011. 
% Software available at http://www.matlabsky.com
% 
% Chih-Chung Chang and Chih-Jen Lin, LIBSVM : a library for
% support vector machines, 2001. Software available at
% http://www.csie.ntu.edu.tw/~cjlin/libsvm

% %% about the parameters of SVMcg 
% if nargin < 10
%     accstep = 4.5;
% end
% if nargin < 8
%     cstep = 0.8;
%     gstep = 0.8;
% end
% if nargin < 7
%     v = 5;
% end
% if nargin < 5
%     gmax = 8;
%     gmin = -8;
% end
% if nargin < 3
%     cmax = 8;
%     cmin = -8;
% end
%% X:c Y:g cg:CVaccuracy
X = cmin:cstep:cmax;
n = length(X);
cg = zeros(1,n);
eps = 1e-1;
%% record acc with different c & g,and find the bestacc with the smallest c
bestc = 1;
% bestg = 0.1;
bestacc = 0;
basenum = 2;

    for j = 1:n
        cmd = ['-t 0 ', ' -v ',num2str(v),' -c ',num2str( basenum^X(j) ),' -q '];
        cg(j) = svmtrain(train_label, train_data, cmd);
        
%         if cg(i,j) <= 55
%             continue;
%         end
        
        if cg(j) > bestacc
            bestacc = cg(j);
            bestc = basenum^X(j);
%             bestg = basenum^Y(i,j);
        end        
        
        if abs( cg(j)-bestacc )<=eps && bestc > basenum^X(j) 
            bestacc = cg(j);
            bestc = basenum^X(j);
%             bestg = basenum^Y(i,j);
        end        
        
    end
%% to draw the acc with different c & g
% figure;
% [C,h] = contour(X,Y,cg,70:accstep:100);
% clabel(C,h,'Color','r');
% xlabel('log2c','FontSize',12);
% ylabel('log2g','FontSize',12);
% firstline = 'SVC参数选择结果图(等高线图)[GridSearchMethod]'; 
% secondline = ['Best c=',num2str(bestc),' g=',num2str(bestg), ...
%     ' CVAccuracy=',num2str(bestacc),'%'];
% title({firstline;secondline},'Fontsize',12);
% grid on; 
% 
% figure;
% % meshc(X,Y,cg);
% % mesh(X,Y,cg);
% % surf(X,Y,cg);
% % axis([cmin,cmax,gmin,gmax,30,100]);
% xlabel('log2c','FontSize',12);
% ylabel('log2g','FontSize',12);
% zlabel('Accuracy(%)','FontSize',12);
% firstline = 'SVC参数选择结果图(3D视图)[GridSearchMethod]'; 
% secondline = ['Best c=',num2str(bestc),' g=',num2str(bestg), ...
%     ' CVAccuracy=',num2str(bestacc),'%'];
% title({firstline;secondline},'Fontsize',12);