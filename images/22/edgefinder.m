%
% Find edges of an image
%
%

function out = edgefinder()


close all;

%% look for stitched together image, otherwise create the stiched image

curdir = 'J:\Users\Patxi\Documents\GitHub\MatInfTeam4.github.io\images\22';
l = dir(curdir);

flag =  find( cellfun(@(x)isequal(x,'stiched.png'),{l.name}) );

% if isempty(flag)
%     stichimages('J:\Users\Patxi\Dropbox\ME8333\22_S1');
% end

% run a simple loop for now to go through all images and inspect


file = ['J:\Users\Patxi\Dropbox\ME8333\22_S1\22\multifocus.tif'];

I = imread(file);

% defines "fraction" of image to look at - useful for zooming in
% on small patches [1e-5 to 1] represents the entire image
start = 0.25;
final = 0.75;
I2 = I(ceil(start*size(I,1)):final*size(I,1),ceil(size(I,2)*start):final*size(I,2),:);

G = rgb2gray(I2);

%% canny filter
filter1 = 'canny';
thresh1 = [0.45];

BW1 = edge(G,filter1,thresh1);

y = getmondim(1);
h=figure('position',y);

% plot original and the canny filters
subplot(2,2,1);imshow(G); axis on;
subplot(2,2,3); imshow(BW1); axis on; title([filter1,' filter, threshold = ',num2str(thresh1,'%1.2f')]);

%% multi/single thresh no filter

[levels metric] = multithresh(G,2); % get two levels
levels = double(levels)/256;        % normalize

BW1 = im2bw(G,levels(1));           % get pixels above first threshold
BW2 = 1-im2bw(G,levels(2));         % get pixels below first threshold
BW = BW1 & BW2; BW = 1- BW;         % get intersection and inverse
figure(h);


% plot the original image and overlay the thresholded image on top w gr
green = cat(3,zeros(size(G)),ones(size(G)),zeros(size(G)));
subplot(2,2,4); imshow(G);
subplot(2,2,4); hold on; gh = imshow(green);
title('multi-threshold');
set(gh,'AlphaData',imcomplement(BW)); axis on;



%% histogram
[counts, x]=imhist(G);
counts = counts*(1/sum(counts));    % normalize to get the ~pdf

figure(h);
subplot(2,2,2); 
plot(x,counts); ys = get(gca,'Ylim'); hold on;
plot([levels(1) levels(1)]*256,ys,'r');
plot([levels(2) levels(2)]*256,ys,'r');
ylim(ys);title(['m1 = ', num2str(metric,'%1.2f')]);
axis on; grid on;
set(gcf,'color','w');
saveas(h,num2str(i,'%1.0d'),'png');

function stichimages(path)

% goto directory with images
l = dir(path);

% find all the directories which contain the ii-th image
pics =  length(find( cellfun(@(x)isequal(x,1),{l.isdir}) ))-2;

% loop over each image and stich together
% assumes that image order goes from 1 to ii
img1 = rgb2gray(imread([path,'\',num2str(1,'%1.0d'),'\multifocus.tif']));

for j = 2:pics
    img2 = rgb2gray(imread([path,'\',num2str(j,'%1.0d'),'\multifocus.tif']));

    
%     F1 = fftshift(fft2(img1));
%     F2 = fftshift(fft2(img2));
    F1 = fft2(img1);
    F2 = fft2(img2);
    F2 = conj(F2);
    prod = F1.*F2;
    Q = prod./abs(prod);
    
    Q = ifft2(Q);
    Q = Q;
    [X, Y] = find(Q == max(max(Q)));
    Qs = Q(size(Q,1),:);
    [val index] = max(Qs);
    
    
    h = figure;
    y = getmondim(1);
    h=figure('position',y);
    subplot(4,2,[1,3]); imshow(img1); axis on; freezeColors;
    s = subplot(4,2,[2,4]); imshow(img2); hold on; axis on; freezeColors;
    pos2 = get(s,'Position');
    
    
    s = subplot(4,2,6); contourf(Q); colormap('jet');colorbar;
    pos3 = get(s,'Position');
    set(s,'Position',[pos2(1) pos3(2) pos2(3) pos3(4)])
    f = subplot(4,2,8); 
    posf = get(f,'Position');
    
    %set(f,'Position',[posf(1) posf(2) pos3(3) posf(4)]);
    plot(f,1:size(Q,2),Qs,'k'); hold on;
    plot(f,[index index],[0 1],'r'); 
    ylim(get(f,'ylim')); xlim(get(s,'xlim'));
    
    s=subplot(4,2,[2,4]); hold on;
    plot(s,[index index],[1 size(img2,1)],'r');
    5;
end


