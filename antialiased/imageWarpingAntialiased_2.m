% Acknowledgements: Hammer (Stack Overflow)
% https://stackoverflow.com/questions/12017790/warp-image-to-appear-in-cylindrical-projection

clc; clear; close all;
image = imread('checker.jpg');
[width, height, channels] = size(image);
f = width / 2;
r = width;
fx = f; % 50
fy = f; % 50

% Initialze array
imageCylindrical = zeros(size(image));
zcmat = zeros(width, height);

% Create X and Y coordinates grid
[X,Y] = meshgrid(1:width, 1:height);

% Get the center of image
xc = width/2;
yc = height/2;

% Center the point at (0, 0).
pcX = X - xc;
pcY = Y - yc;

for y = 1:height
    for x = 1:width
        current_pos = [x,y];
        [current_pos, zc] = convert_pt(current_pos, width, height, fx, fy, r);

        top_left = floor(current_pos); % top left because of integer rounding
        zcmat(y,x) = zc;

        % make sure the point is actually inside the original image
        if top_left(1) < 1 || ...
           top_left(1) > width-1 || ...
           top_left(2) < 1 || ...
           top_left(2) > height-1
            continue
        end
    end
end

xd = (pcX .* zcmat/fx) + xc;
yd = (pcY .* zcmat/fy) + yc;

% Interpolate for each color channel
for k = 1:size(image, 3)
    imageCylindrical(:,:,k) = interp2(X, Y, double(image(:,:,k)), xd, yd, 'cubic', 0);
end

% Display the result
imageCylindrical = uint8(imageCylindrical);

figure; 
imshow(imageCylindrical)


function [final_point, zc] = convert_pt(point, w, h, fx, fy, r)    
    pc = [point(1)-w/2, point(2)-h/2];
    omega = w/2;
    z0 = fx - sqrt(r^2 - omega^2);

    zc = (2*z0 + sqrt(4*z0^2 - 4*(pc(1)^2/(fx^2) + 1)*(z0^2 - r^2))) / (2 * (pc(1)^2/(fy^2) + 1));
    final_point = [pc(1)*zc/fx, pc(2)*zc/fy];
    final_point(1) = final_point(1) + w/2;
    final_point(2) = final_point(2) + h/2;
end