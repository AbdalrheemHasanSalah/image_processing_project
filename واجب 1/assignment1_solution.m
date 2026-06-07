function assignment1_final()

clc; clear; close all;
%Abdalrheem salah
%Nizar kassab

path_image = input('entar the path of image: ','s');
img = imread('test.png');   

if ndims(img) == 3
    img = 0.2989*double(img(:,:,1)) + ...
          0.5870*double(img(:,:,2)) + ...
          0.1140*double(img(:,:,3));
else
    img = double(img);
end

img = uint8(img);

figure; imshow(img);
title('Original Image');

% =========================================
% Binary
thr = input('entar threshold (0-255): ');
bw = img > thr; 

figure; imshow(bw);
title('Binary');

% =========================================
% 4-connectivity
[L4, n4] = myLabeling(bw, 4);

figure;
imagesc(L4); axis off; axis image;
colormap jet; colorbar;
title(['4 conn = ', num2str(n4)]);

% =========================================
% 8-connectivity
[L8, n8] = myLabeling(bw, 8);

figure;
imagesc(L8); axis off; axis image;
colormap jet; colorbar;
title(['8 conn = ', num2str(n8)]);

% =========================================
% Task 3
minI = input('min intensity: ');
maxI = input('max intensity: ');
conn = input('connectivity (4/8): ');

if minI > maxI
    t = minI;
    minI = maxI;
    maxI = t;
end

mask = (img >= minI) & (img <= maxI);

figure; imshow(mask);
title('mask');

[Lm, nm] = myLabeling(mask, conn);

figure;
imagesc(Lm); axis off; colorbar;
title(['components = ', num2str(nm)]);

% =========================================
% Task 4
minSize = input('min size: ');

out = removeSmall(Lm, minSize);

figure; imshow(out);
title('after filtering');

end


% =====================================================
function [L, count] = myLabeling(BW, connType)

[r, c] = size(BW);
L = zeros(r, c);

parent = 1:(r*c);  
label = 1;

for i = 1:r
    for j = 1:c
        
        if BW(i,j) == 0
            continue;
        end
        
        neigh = [];
        
        if connType == 4
            
            if j > 1 && L(i,j-1) > 0
                neigh(end+1) = L(i,j-1);
            end
            
            if i > 1 && L(i-1,j) > 0
                neigh(end+1) = L(i-1,j);
            end
            
        else
            
            if j > 1 && L(i,j-1) > 0
                neigh(end+1) = L(i,j-1);
            end
            
            if i > 1 && L(i-1,j) > 0
                neigh(end+1) = L(i-1,j);
            end
            
            if i > 1 && j > 1 && L(i-1,j-1) > 0
                neigh(end+1) = L(i-1,j-1);
            end
            
            if i > 1 && j < c && L(i-1,j+1) > 0
                neigh(end+1) = L(i-1,j+1);
            end
        end
        
        if isempty(neigh)
            L(i,j) = label;
            parent(label) = label;
            label = label + 1;
        else
            m = min(neigh);
            L(i,j) = m;
            
            for k = 1:length(neigh)
                parent = merge(parent, m, neigh(k));
            end
        end
        
    end
end

for i = 1:r
    for j = 1:c
        if L(i,j) > 0
            L(i,j) = findRoot(parent, L(i,j));
        end
    end
end

u = unique(L);
u(u==0) = [];

newL = zeros(r,c);

for k = 1:length(u)
    newL(L == u(k)) = k;
end

L = newL;
count = length(u);

end


% =====================================================
function parent = merge(parent, a, b)

ra = findRoot(parent, a);
rb = findRoot(parent, b);

if ra ~= rb
    if ra < rb
        parent(rb) = ra;
    else
        parent(ra) = rb;
    end
end

end


% =====================================================
function r = findRoot(parent, x)

r = x;

while parent(r) ~= r
    r = parent(r);
end

end


% =====================================================
function out = removeSmall(L, minPixels)

[rr, cc] = size(L);
out = zeros(rr, cc);

labels = unique(L);
labels(labels == 0) = [];

for i = 1:length(labels)
    
    lab = labels(i);
    

    cnt = sum(L(:) == lab);
    
    if cnt > minPixels  
        out(L == lab) = 1;
    end
    
end

out = logical(out);

end