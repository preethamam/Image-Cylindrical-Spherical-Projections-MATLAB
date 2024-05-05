function imageCylindrical = image2cylindrical_v2(image, K, DC)

%%***********************************************************************%
%*                   Image to cylindrical projection                    *%
%*           Projects normal image to a cylindrical warp                *%
%*                                                                      *%
%* Code author: Preetham Manjunatha                                     *%
%* Github link: https://github.com/preethamam
%* Date: 05/04/2024                                                     *%
%************************************************************************%
%
%************************************************************************%
%
% Usage: imageCylindrical = image2cylindrical_v2(image, K, DC)
% Inputs: image - input image
%         K  - Camera intrinsic matrix (depends on the camera).
%         DC - Radial and tangential distortion coefficient.
%              [k1, k2, k3, p1, p2]
%
% Outputs: imageCylindrical - Warpped image to cylindrical coordinates

% Get distrotion coefficients
fx = K(1,1);
fy = K(2,2);
k1 = DC(1);
k2 = DC(2);
k3 = DC(3);
p1 = DC(4);
p2 = DC(5);

% Get image size
[ydim, xdim, bypixs] = size(image);

% Get the center of image
xc = xdim/2;
yc = ydim/2;

% Create X and Y coordinates grid
[X,Y] = meshgrid(1:xdim, 1:ydim);

% Perform the cylindrical projection
theta = (X - xc) / fx;
h = (Y - yc) / fy;

% Cylindrical coordinates to Cartesian
xcap = sin(theta);
ycap = h;
zcap = cos(theta);

xyz_cap = cat(3, xcap, ycap, zcap);
xyz_cap = reshape(xyz_cap,[],3);

% Normalized coords
xyz_cap_norm = (K * xyz_cap')';
xn = xyz_cap_norm(:,1) ./ xyz_cap_norm(:,3);
yn = xyz_cap_norm(:,2) ./ xyz_cap_norm(:,3);

% Radial and tangential distortion 
r = xn.^2 + yn.^2;
xd_r = xn .* (1 + k1 * r.^2 + k2 * r.^4 + k3 * r.^6);
yd_r = yn .* (1 + k1 * r.^2 + k2 * r.^4 + k3 * r.^6);

xd_t = 2 * p1 * xn .* yn + p2 * (r.^2 + 2 * xn.^2);
yd_t = p1 * (r.^2 + 2 * yn.^2) + 2 * p2 * xn .* yn;

xd = xd_r + xd_t;
yd = yd_r + yd_t;

% Reshape and clip coordinates
xd = reshape(ceil(xd),[ydim, xdim]);
yd = reshape(ceil(yd),[ydim, xdim]);
mask = xd > 0 & xd <= xdim & yd > 0 & yd <= ydim;

% Get masked coordinates
xd = xd .* mask;
yd = yd .* mask;

% Get projections
ind = sub2ind(size(image), yd(mask), xd(mask), ones(1,length(xd(mask)))');
IC1 = zeros(ydim, xdim, 'uint8');
IC1(mask) = image(ind + 0 * ydim * xdim);

if bypixs == 1
    imageCylindrical  = IC1;
else
    IC2 = zeros(ydim, xdim, 'uint8');
    IC3 = zeros(ydim, xdim, 'uint8');
    IC2(mask) = image(ind + 1 * ydim * xdim);
    IC3(mask) = image(ind + 2 * ydim * xdim);
    imageCylindrical = cat(3, IC1, IC2, IC3);
end

end