% Acknowledgements: Avni Agrawal (Mathworks File Exchange)
% https://www.mathworks.com/matlabcentral/answers/2115376-why-imwarp-isn-t-working-for-cylindrical-projection

clc; close all; clear;

% Inputs
fileName = '../checker.jpg';

% Focal lengths (adjust as necessary)
fx = 50; % Larger focal length to reduce extreme distortion
fy = 50; % Used for vertical scaling if needed

% Read image
image = imread(fileName);

% Get image size
[ydim, xdim, ~] = size(image);

% Camera intrinsics (not directly used here but useful for understanding the setup)
K = [fx, 0, xdim/2; 0, fy, ydim/2; 0, 0, 1];

% Get the center of the image
xc = xdim / 2;
yc = ydim / 2;

% Create X and Y coordinates grid
[X, Y] = meshgrid(1:xdim, 1:ydim);

% Perform the cylindrical projection
theta = (X - xc) / fx;
h = (Y - yc) / fy;

% Simulate the 3D cylindrical effect
Xcyl = fx * tan(theta) + xc;
Zcyl = fx ./ cos(theta); % Z-coordinate in cylinder space for depth effect

% Apply a perspective effect on Y based on Z depth, simulating tilt
Ycyl = (h .* Zcyl) + yc;

% Normalize Z for depth effect on X (optional, for more pronounced edge tilting)
Xcyl = (Xcyl - xc) .* (1 + Zcyl/max(Zcyl(:))) + xc;

% Use interp2 for mapping the original image to the new coordinates
imageCylindrical = zeros(size(image), class(image));
for k = 1:size(image, 3) % For each color channel
    imageCylindrical(:,:,k) = interp2(double(image(:,:,k)), Xcyl, Ycyl, 'cubic', 0);
end

% Display the result
imshow(uint8(imageCylindrical));