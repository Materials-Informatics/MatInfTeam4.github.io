function spatialstats()

close all;
N = 500;   % use bottom N pixels
Np = 100;  % plot bottom Np pixels    Np <= N
Nw = 5;    % number of principal components
rsz = 1.0; % resize 
avg = 0;

% load cell images
load('Alpha.mat');
% load('Alpha_good.mat'); % just the good pictures

% get rid of final 2 of each set
DCropped = {DCropped{1},DCropped{2},DCropped{3},DCropped{6},DCropped{7},DCropped{8},DCropped{11},DCropped{12},DCropped{13},DCropped{16},DCropped{17},DCropped{18},DCropped{21},DCropped{22},DCropped{23},DCropped{26},DCropped{27},DCropped{28},DCropped{31},DCropped{32},DCropped{33},DCropped{36}};

if length(DCropped) == 8
    mm = 1;
else
    mm = 3;
end

X = [];

col = {'k','b','r','g','c','m','y'}; % colors for plotting
jjj = 0;

% %% virgin
BW = DCropped{length(DCropped)};
BW = imresize(BW,2.5);
BW = double(BW)./255;
BW = BW(1:size(DCropped{1},1),1:size(DCropped{1},2));
BW = imresize(BW,rsz);
EDG = edge(BW,'canny',0.2);

EDG = EDG(3:size(EDG,1)-2,3:size(EDG,2)-2);
% figure; subplot(1,2,1); imshow(BW); subplot(1,2,2); imshow(EDG);
mysize = size(BW);

[cords,Ncounts] = getchords(EDG,1,mysize(2));
cordsN = cords([1,3],:,:);
if avg == 1
    m = size(cordsN,3);
    cordsN = sum(cordsN,3);
    cordsN(1,:) = cordsN(1,:)./m;
end
% cordsN = sum(cords,2);
[cordsN, NcountsN] = getpdf(cordsN);
if avg == 1
    Y = cordsN(2,:);
else
    Y = squeeze(cordsN(2,:,:))';
end
% f1 = figure;
% f2 = figure;
%% processed
for ii = 1:7
    
    for i = 1:mm
        jjj = jjj + 1;
        % generate the correct path and get the right cropped filename
    %     file{i} = [path,'\Pic',num2str(i,'%1.0d'),'\',num2str(i,'%1.0d'),'c.tif'];
    %     info = imfinfo(file{i});

        % get a subimage in BW

    %     topleft = [info.Height-mysize(1), floor(info.Width*0.5) - floor(mysize(2)*0.5)];
    %     BW = getsubimage(file{i},mysize, topleft,0.25);


        
        % get edges
        
        BW = imadjust(DCropped{jjj});
        
        
%         figure;
%         imshow(DCropped{jjj});

        
        BW = double(BW)./255;  
        
        
        
        
        BW = BW(size(BW,1)-N+1:size(BW,1),:);
%         
%         figure(f1); subplot(5,7,7*(i-1)+ii); imshow(BW(:,(floor(size(BW,2)*0.5-Np*0.5)):(floor(size(BW,2)*0.5+Np*0.5))));
%         
        BW = imresize(BW,rsz);
        mysize = size(BW);
        EDG = edge(BW,'canny');
%         figure; subplot(1,2,1); imshow(BW);subplot(1,2,2); imshow(EDG);
        % cut off the edges
        EDG = EDG(3:size(EDG,1)-2,3:size(EDG,2)-2);
%         
%         figure(f2); subplot(5,7,7*(i-1)+ii); imshow(EDG(:,(floor(size(EDG,2)*0.5-Np*0.5)):(floor(size(EDG,2)*0.5+Np*0.5))));
%         
        % compute just the chordlength on a line-by-line basis (in height dir)
        binw = 1; % pixels
        [cords,Ncounts] = getchords(EDG,binw,mysize(2));

        if i == 1
            cordsN = cords([1,3],:,:);
        else
            cordsN(2,:,:) = cordsN(2,:,:) + cords(3,:,:);
        end

        % plotting routine
%         h = figure;
%         myplotter(h,BW,EDG,cords,Ncounts);
%         5;
        if avg == 0
            [cordsN2, NcountsN] = getpdf(cords([1 3],:,:));
            X = [X;squeeze(cordsN2(2,:,:))'];
        end
    end

    
    if avg == 1
        [cordsN2, NcountsN] = getpdf(cordsN);
        X = [X;squeeze(cordsN2(2,:,:))'];
    end

    %% determine PCA. then use N of the first basis functions to approximate 
    % the pdf at each row. determine weights needed for this and give back the
    % weights and vectors

    
    
end
try
    X = [X;Y];
end
%     [weights vectors approx] = mypca(X,N);
    X = X - repmat(mean(X,1),[size(X,1),1]);
    [U S V] = pca(X,Nw);
    
    PC = U*S;
    
%     P1 = PC(1:5*size(cordsN,3),:);
%     P2 = PC(5*size(cordsN,3)+1:2*5*size(cordsN,3),:);
%     P3 = PC(2*5*size(cordsN,3)+1:3*5*size(cordsN,3),:);
if avg == 0
    m = mm;
else
    m = 1;
end




try
     P1 = PC(1:m*size(cordsN,3),:);
%      if avg == 0
%          P1 = [P1(1:size(EDG,1),:) P1(size(EDG,1)+1:2*size(EDG,1),:) P1(2*size(EDG,1)+1:3*size(EDG,1),:)];
%      end
end
try
     P2 = PC(m*size(cordsN,3)+1:2*m*size(cordsN,3),:);
%      if avg == 0
%          P2 = [P2(1:size(EDG,1),:) P2(size(EDG,1)+1:2*size(EDG,1),:) P2(2*size(EDG,1)+1:3*size(EDG,1),:)];
%      end
end
try
     P3 = PC(2*m*size(cordsN,3)+1:3*m*size(cordsN,3),:);
%      if avg == 0
%          P3 = [P1(1:size(EDG,1),:) P3(size(EDG,1)+1:2*size(EDG,1),:) P3(2*size(EDG,1)+1:3*size(EDG,1),:)];
%      end
end
try
     P4 = PC(3*m*size(cordsN,3)+1:4*m*size(cordsN,3),:);
%      if avg == 0
%          P4 = [P4(1:size(EDG,1),:) P4(size(EDG,1)+1:2*size(EDG,1),:) P4(2*size(EDG,1)+1:3*size(EDG,1),:)];
%      end
end
try
     P5 = PC(4*m*size(cordsN,3)+1:5*m*size(cordsN,3),:);
%      if avg == 0
%          P5 = [P5(1:size(EDG,1),:) P5(size(EDG,1)+1:2*size(EDG,1),:) P5(2*size(EDG,1)+1:3*size(EDG,1),:)];
%      end
end
try
     P6 = PC(5*m*size(cordsN,3)+1:6*m*size(cordsN,3),:);
%      if avg == 0
%          P6 = [P6(1:size(EDG,1),:) P6(size(EDG,1)+1:2*size(EDG,1),:) P6(2*size(EDG,1)+1:3*size(EDG,1),:)];
%      end
end
try
     P7 = PC(6*m*size(cordsN,3)+1:7*m*size(cordsN,3),:);
%      if avg == 0
%          P7 = [P7(1:size(EDG,1),:) P7(size(EDG,1)+1:2*size(EDG,1),:) P7(2*size(EDG,1)+1:3*size(EDG,1),:)];
%      end
end
try
     PV = PC(7*m*size(cordsN,3)+1:size(PC,1),:);
end

%     factor = norm(X-approx);

     figure;
     if avg == 0
         top = [1:Np, size(EDG,1)+1:size(EDG,1)+Np,2*size(EDG,1)+1:2*size(EDG,1)+Np];
         bot  = [size(EDG,1)-Np+1:size(EDG,1),2*size(EDG,1)-Np+1:2*size(EDG,1),3*size(EDG,1)-Np+1:3*size(EDG,1)];
         zz = [1:Np, 1:Np, 1:Np];
     else
         top = [1:Np];
         bot  = [size(EDG,1)-Np+1:size(EDG,1)];
         zz = [1:Np];
     end
try
     plot3(P1(top,1),P1(top,2),zz,'ro','MarkerFaceColor','r','markeredgecolor','k','MarkerSize',10); hold on; 
     i =1;
end
try
     plot3(P2(top,1),P2(top,2),zz,'go','MarkerFaceColor','g','markeredgecolor','k','MarkerSize',10);
     i = 2;
end
try
     plot3(P3(top,1),P3(top,2),zz,'bo','MarkerFaceColor','b','markeredgecolor','k','MarkerSize',10);
     i = 3;
end
try
     plot3(P4(top,1),P4(top,2),zz,'ko','MarkerFaceColor','k','markeredgecolor','k','MarkerSize',10);
     i = 4;
end
try
     plot3(P5(top,1),P5(top,2),zz,'co','MarkerFaceColor','c','markeredgecolor','k','MarkerSize',10);
     i = 5;
end
try
     plot3(P6(top,1),P6(top,2),zz,'mo','MarkerFaceColor','m','markeredgecolor','k','MarkerSize',10);
     i = 6;
end
try
     plot3(P7(top,1),P7(top,2),zz,'yo','MarkerFaceColor','y','markeredgecolor','k','MarkerSize',10);
     i = 7;
end
try
     plot3(PV(:,1),PV(:,2),1:Np,'o','MarkerFaceColor',[0.5 0.5 0.5],'markeredgecolor','k','MarkerSize',10);
     i = 8;
end
     leg = {'22','23','24','26','27','28','32','virgin'};
     legend(leg{1:i},'location','best');
     figure;

try
     plot(P1(top,1),P1(top,2),'ro','MarkerFaceColor','r','markeredgecolor','k','MarkerSize',10); hold on; 
     i =1;
end
try
     plot(P2(top,1),P2(top,2),'go','MarkerFaceColor','g','markeredgecolor','k','MarkerSize',10);
     i = 2;
end
try
     plot(P3(top,1),P3(top,2),'bo','MarkerFaceColor','b','markeredgecolor','k','MarkerSize',10);
     i = 3;
end
try
     plot(P4(top,1),P4(top,2),'ko','MarkerFaceColor','k','markeredgecolor','k','MarkerSize',10);
     i = 4;
end
try
     plot(P5(top,1),P5(top,2),'co','MarkerFaceColor','c','markeredgecolor','k','MarkerSize',10);
     i = 5;
end
try
     plot(P6(top,1),P6(top,2),'mo','MarkerFaceColor','m','markeredgecolor','k','MarkerSize',10);
     i = 6;
end
try
     plot(P7(top,1),P7(top,2),'yo','MarkerFaceColor','y','markeredgecolor','k','MarkerSize',10);
     i = 7;
     
end
try
     plot(PV(:,1),PV(:,2),'o','MarkerFaceColor',[0.5 0.5 0.5],'markeredgecolor','k','MarkerSize',10);
     i = 8;
end
     leg = {'22','23','24','26','27','28','32','virgin'};
     legend(leg{1:i},'location','best');
     title(['Top ',num2str(Np,'%1.0d'),' pixels']);


%     legend('22','27');
    
     xlabel('PC1');ylabel('PC2');zlabel('row');
     
     figure; 

try
     plot(P1(bot,1),P1(bot,2),'ro','MarkerFaceColor','r','markeredgecolor','k','MarkerSize',10); hold on; 
     i =1;
end
try
     plot(P2(bot,1),P2(bot,2),'go','MarkerFaceColor','g','markeredgecolor','k','MarkerSize',10);
     i = 2;
end
try
     plot(P3(bot,1),P3(bot,2),'bo','MarkerFaceColor','b','markeredgecolor','k','MarkerSize',10);
     i = 3;
end
try
     plot(P4(bot,1),P4(bot,2),'ko','MarkerFaceColor','k','markeredgecolor','k','MarkerSize',10);
     i = 4;
end
try
     plot(P5(bot,1),P5(bot,2),'co','MarkerFaceColor','c','markeredgecolor','k','MarkerSize',10);
     i = 5;
end
try
     plot(P6(bot,1),P6(bot,2),'mo','MarkerFaceColor','m','markeredgecolor','k','MarkerSize',10);
     i = 6;
end
try
     plot(P7(bot,1),P7(bot,2),'yo','MarkerFaceColor','y','markeredgecolor','k','MarkerSize',10);
     i = 7;
     
end
try
     plot(PV(:,1),PV(:,2),'o','MarkerFaceColor',[0.5 0.5 0.5],'markeredgecolor','k','MarkerSize',10);
     i = 8;
end
     leg = {'22','23','24','26','27','28','32','virgin'};
     legend(leg{1:i},'location','best');
     title(['Bottom ',num2str(Np,'%1.0d'),' pixels']);
     
     figure; plot(diag(S.^2)./sum(diag(S.^2)));

%     h = figure();
%     set(h,'position',[1921          85        1280         920]);
%     set(h,'position',[1          41        1920         964]);
%     set(h,'position',[ 28          49        1316         635]);
% 
%     myplotter(h,BW,EDG,cordsN2,NcountsN,weights,ii);
    
% 
%  plotpca(EDG,weights,vectors,cordsN2,[1:N]);

function plotpca(EDG,weights,vectors,cords,comps)


ind = 1;
xmax = 0;
ymax = 0;

f = size(vectors,2);
cords = cords(:,1:f,:);

for i = 1:size(cords,3)
    ind2 = find(cords(3,:,i),1,'last');
    ymax2 = max(cords(2,:,i));
    if ind2 > ind
        ind = ind2;
        xmax = cords(1,ind,i);
    end
    if ymax2 > ymax
        ymax = ymax2;
    end
end




for i = 1: length(comps)
    
    h=figure;
    set(h,'position',[1921          85        1280         920]);
    subplot(2,2,1);
    imshow(EDG);
    
    subplot(2,2,2);
    plot(weights(:,comps(i)),[1:size(EDG,1)]);
    title(['Principal Component Weight No. ',num2str(comps(i),'%1.0d')]);
    ylabel('Pixels');
    xlabel(['$\alpha_{',num2str(comps(i),'%1.0d'),'}$'],'interpreter','latex','fontsize',16);
    
    subplot(2,2,[3,4]);
    bar(cords(1,:,1),vectors(comps(i),:)); 
    ylim([0 ymax]);
    xlim([0 xmax]);
        
    title(['Principal Component No. ',num2str(comps(i),'%1.0d')]);

    
    set(gcf,'color','w');
    saveas(h,['princecomp_pdf_',num2str(comps(i),'%1.0d')],'png');
end


function [weights vectors approx] = mypca(X , N)
% gets X which is the m x p where 
% m = number of rows in the images
% p = number of bins 
%
% N is the number of principal components that are to be used to
% reconstruct each row of X using e[1...N] and weights w[1...N]
%
% vectors are simply the N first principal components
%
% and weights are m x N (each row can be reconstructed using N weights and
%                        eigenvectors)
%

[coeff,score,latent,tsquared,explained,mu] = pca(X);

vectors = coeff(:,1:N);

num = find(diag(coeff) == 1,1);

b = X - ones(size(X,1),1)*mu; % subtract mean

weights = zeros(size(X,1),N);
approx = zeros(size(X,1),size(X,2));

for i = 1:size(b,1)
   for j = 1:N
       weights(i,j) = b(i,:)*vectors(:,j);
   end
end

approx = weights*vectors' + ones(size(b,1),1)*mu;





function [cordsN2, NcountsN] = getpdf(cordsN)

NcountsN = zeros(1,size(cordsN,3));
cordsN2 = zeros(size(cordsN,1)+1,size(cordsN,2),size(cordsN,3));
for i = 1:size(cordsN,3)
    NcountsN(i) = sum(cordsN(2,:,i));
    mypdf = cordsN(2,:,i).*cordsN(1,:,i);
    mypdf = mypdf / sum(mypdf);
    cordsN2(:,:,i) = [cordsN(1,:,i); mypdf; cordsN(2,:,i)];
    
end


function [cords,Ncounts] = getchords(EDG,binw,width);
% function that generates the chord distribution at each row of pixels for
% the provided binary image EDG

bins = linspace(binw*0.5,width,floor(width/binw));

cords = zeros(3,length(bins),size(EDG,1));
Ncounts = zeros(1,size(EDG,1));

for i = 1:size(EDG,1)
    
    inds = find(EDG(i,:));
    N = length(inds);
    lengths = inds(2:N)-inds(1:N-1);
    inds = find(lengths>1);
    lengths = lengths(inds);
    if ~isempty(inds)
        [counts,centers] = hist(lengths,bins);
        Ncounts(i) = sum(counts);
        cords(:,:,i) = [centers;counts/Ncounts(i);counts];
    else
        cords(:,:,i) = [centers;zeros(1,length(centers));counts];
    end
end

% cords = flipdim(cords,3);

function BW = getsubimage(file, mysize, topleft, scale)
% maybe there is a more efficient way to get the pixels we want without
% having to read the entire image file???

mysize = floor(scale*mysize);
topleft = floor(scale*topleft);

BW = imread(file);
BW = imresize(BW(:,:,[1:3]),scale);
BW = rgb2gray(BW);
BW = BW(topleft(1):(topleft(1)+mysize(1)),topleft(2):(topleft(2)+mysize(2)));

function myplotter(h,BW,EDG,cords,Ncounts, weights,ii)
% plotting routine


c = {'r','b','g','y'};
sh = {'o','^','s'};


h1 = figure;set(h1,'position',[1921          85        1280         920]);
h2 = figure;set(h2,'position',[1921          85        1280         920]);

figure(h);
subplot(4,3,[1 4]); hold on;
imshow(BW); hold on;
axis on;
j = 0;
for i = 1+ floor(linspace(0,1,4)*(size(cords,3)-1))
    j = j + 1;
    plot([1 size(BW,2)],[i i],c{j},'linewidth',4);
end


subplot(4,3,[7 10]); hold on;
imshow(EDG); hold on;
axis on;
j = 0;
for i = 1+ floor(linspace(0,1,4)*(size(cords,3)-1))
    j = j + 1;
    plot([1 size(BW,2)],[i i],c{j},'linewidth',4);
end



samples = 1+ floor(linspace(0,1,4)*(size(cords,3)-1));

ind = 1;
xmax = 0;
ymax = 0;
for i = samples
    ind2 = find(cords(3,:,i),1,'last');
    ymax2 = max(cords(2,:,i));
    if ind2 > ind
        ind = ind2;
        xmax = cords(1,ind,i);
    end
    if ymax2 > ymax
        ymax = ymax2;
    end
end

ymax = ceil(ymax*10)/10;

j = 1;
for i = samples
    subplot(4,3,2+3*(j-1));

    if find(cords(1,:,i),1)
        p=bar(cords(1,:,i),cords(2,:,i));
        set(p,'Facecolor',c{j});
        set(p,'Edgecolor','none');
        ylim([0 ymax]);
        xlim([0 xmax]);
        title(['Number of Chords Sampled: ',num2str(Ncounts(i),'%1.0d')]);
    end
    j = j + 1;
end

%% point cloud images
for i = 1:size(EDG,1)
    
    
    if ~isempty(find(i == samples))
        j = find(i == samples);
        col = c{j};
        m = 8;
    else
        col = (i/size(EDG,1))*[1 1 1];
        m = 5;
    end
    figure(h);
    subplot(4,3,[9 12]);
    plot3(weights(i,1),weights(i,2),weights(i,3),'marker',sh{ii},'markeredgecolor','k','markerfacecolor',col,'markersize',m); hold on;
    
    subplot(4,3,3);
    plot(weights(i,1),weights(i,2),'marker',sh{ii},'markeredgecolor','k','markerfacecolor',col,'markersize',m); hold on;
    
    subplot(4,3,6);
    plot(weights(i,1),weights(i,3),'marker',sh{ii},'markeredgecolor','k','markerfacecolor',col,'markersize',m); hold on;
    
    figure(h1);
    plot(weights(i,1),weights(i,2),'marker',sh{ii},'markeredgecolor','k','markerfacecolor',col,'markersize',m); hold on;
    figure(h2);
    plot(weights(i,1),weights(i,3),'marker',sh{ii},'markeredgecolor','k','markerfacecolor',col,'markersize',m); hold on;
   
end

j = 1;
for i = samples
    figure(h);
    subplot(4,3,[9 12]);
    plot3(weights(i,1),weights(i,2),weights(i,3),'marker',sh{ii},'markeredgecolor','k','markerfacecolor',c{j},'markersize',8); hold on;
    
    subplot(4,3,3);
    plot(weights(i,1),weights(i,2),'marker',sh{ii},'markeredgecolor','k','markerfacecolor',c{j},'markersize',8); hold on;
    
    subplot(4,3,6);
    plot(weights(i,1),weights(i,3),'marker',sh{ii},'markeredgecolor','k','markerfacecolor',c{j},'markersize',8); hold on;
    
    figure(h1);
    plot(weights(i,1),weights(i,2),'marker',sh{ii},'markeredgecolor','k','markerfacecolor',c{j},'markersize',8); hold on;
    
    figure(h2);
    plot(weights(i,1),weights(i,3),'marker',sh{ii},'markeredgecolor','k','markerfacecolor',c{j},'markersize',8); hold on;
    
    
    j= j + 1;
end
figure(h);
subplot(4,3,[9 12]);
xlabel('$\alpha_1$','interpreter','latex','fontsize',14);
ylabel('$\alpha_2$','interpreter','latex','fontsize',14);
zlabel('$\alpha_3$','interpreter','latex','fontsize',14);

subplot(4,3,3);
xlabel('$\alpha_1$','interpreter','latex','fontsize',14);
ylabel('$\alpha_2$','interpreter','latex','fontsize',14);

subplot(4,3,6);
xlabel('$\alpha_1$','interpreter','latex','fontsize',14);
ylabel('$\alpha_3$','interpreter','latex','fontsize',14);
    
set(h,'color','w');
saveas(h,'image_pdf','png');

figure(h1);
xlabel('$\alpha_1$','interpreter','latex','fontsize',14);
ylabel('$\alpha_2$','interpreter','latex','fontsize',14);
set(h1,'color','w');
saveas(h1,'PC1vPC2','png');

figure(h2);
xlabel('$\alpha_1$','interpreter','latex','fontsize',14);
ylabel('$\alpha_3$','interpreter','latex','fontsize',14);
set(h2,'color','w');
saveas(h2,'PC1vPC3','png');






