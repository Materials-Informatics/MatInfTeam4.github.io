function spatialstats()

path = 'J:\Users\Patxi\Dropbox\ME8333\24';
close all;
N = 3; % number of wiebull's to use in the mixture

for i = 1:9
    
    % generate the correct path and get the right cropped filename
    file{i} = [path,'\Pic',num2str(i,'%1.0d'),'\',num2str(i,'%1.0d'),'c.tif'];
    info = imfinfo(file{i});
    
    % get a subimage in BW
    mysize = [1800,1400];
    topleft = [info.Height-mysize(1), floor(info.Width*0.5) - floor(mysize(2)*0.5)];
    BW = getsubimage(file{i},mysize, topleft,0.25);
    
    % get edges
    EDG = edge(BW,'canny');
    % cut off the edges
    EDG = EDG(3:size(EDG,1)-2,3:size(EDG,2)-2);
    
    % compute just the chordlength on a line-by-line basis (in height dir)
    binw = 5; % pixels
    [cords,Ncounts] = getchords(EDG,binw,mysize(2));
    
    if i == 1
        cordsN = cords([1,3],:,:);
    else
        cordsN(2,:,:) = cordsN(2,:,:) + cords(3,:,:);
    end

    % plotting routine
    h = figure();
    set(h,'position',[1921          85        1280         920]);
    myplotter(h,BW,EDG,cords,Ncounts);
    5;
end
    
[cordsN2, NcountsN] = getpdf(cordsN);

h = figure();
set(h,'position',[1921          85        1280         920]);
myplotter(h,BW,EDG,cordsN2,NcountsN);

for j = 1:size(BW,1)
    lb = [0  0   0  0  0   0   0 0   0 ];
    ub = [1 inf inf 1 inf inf 1 inf inf];
    start = [(1/3) 1 0.5 (1/3) 1 1 (1/3) 1 2];
    [paramEsts,paramCIs] = mle(x, 'pdf',@mypdf, 'start',start, 'lower',lb,'upper',ub);
end

function [cordsN2, NcountsN] = getpdf(cordsN)

NcountsN = zeros(1,size(cordsN,3));
cordsN2 = zeros(size(cordsN,1)+1,size(cordsN,2),size(cordsN,3));
for i = 1:size(cordsN,3)
    NcountsN(i) = sum(cordsN(2,:,i));
    cordsN2(:,:,i) = [cordsN(1,:,i); cordsN(2,:,i)./NcountsN(i); cordsN(2,:,i)];
    
end

function out = mypdf(x,varargin)

out = 0;
sum = 0;
for i = 1:length(varargin)/3
    out = out + varargin(i+2)*wblpdf(x,varargin(i),varargin(i+1));
end

out = out / n;


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

function myplotter(h,BW,EDG,cords,Ncounts)
% plotting routine


c = {'r','b','g','y'};

subplot(4,2,[1 3]); 
imshow(BW); hold on;
axis on;
j = 0;
for i = 1+ floor(linspace(0,1,4)*(size(cords,3)-1))
    j = j + 1;
    plot([1 size(BW,2)],[i i],c{j},'linewidth',2);
end


subplot(4,2,[5 7]); 
imshow(EDG); hold on;
axis on;
j = 0;
for i = 1+ floor(linspace(0,1,4)*(size(cords,3)-1))
    j = j + 1;
    plot([1 size(BW,2)],[i i],c{j},'linewidth',2);
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
    subplot(4,2,2*j);

    if find(cords(1,:,i),1)
        p=bar(cords(1,:,i),cords(2,:,i));
        set(p,'Facecolor',c{j});
        set(p,'Edgecolor','k');
        ylim([0 ymax]);
        xlim([0 xmax]);
        title(['Number of Chords Sampled: ',num2str(Ncounts(i),'%1.0d')]);
    end
    j = j + 1;
end

set(h,'color','w');






