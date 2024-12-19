% Acknowledgements: Hammer (Stack Overflow)
% https://stackoverflow.com/questions/12017790/warp-image-to-appear-in-cylindrical-projection

clc; clear; close all;
image = imread('../checker.jpg');
[width, height, channels] = size(image);
f = width / 2;

imageCylindrical = cylindrical_concave(image, f);
figure; 
imshow(imageCylindrical)

function final_point = convert_pt(point, w, h, f)
    % Center the point at (0, 0).
    pc = [point(1) - w/2, point(2) - h/2];
    
    % These are your free parameters.
    r = w;
    omega = w/2;
    z0 = f - sqrt(r^2 - omega^2);
    
    zc = (2*z0 + sqrt(4*z0^2 - 4*(pc(1)^2/(f^2) + 1)*(z0^2 - r^2))) / (2 * (pc(1)^2/(f^2) + 1));
    final_point = [pc(1)*zc/f, pc(2)*zc/f];
    final_point(1) = final_point(1) + w/2;
    final_point(2) = final_point(2) + h/2;
end

function dest_im = cylindrical_concave(image, f)
    [height, width, ~] = size(image);
    dest_im = zeros(size(image), 'uint8');
    
    for y = 1:height
        for x = 1:width
            current_pos = [x, y];
            current_pos = convert_pt(current_pos, width, height, f);
            
            top_left = floor(current_pos); % top left because of integer rounding
            
            % make sure the point is actually inside the original image
            if top_left(1) < 1 || ...
               top_left(1) > width-1 || ...
               top_left(2) < 1 || ...
               top_left(2) > height-1
                continue
            end
            
            % bilinear interpolation
            dx = current_pos(1) - top_left(1);
            dy = current_pos(2) - top_left(2);

            dxx(y, x) = dx;
            dyy(y, x) = dy;
            
            weight_tl = (1.0 - dx) * (1.0 - dy);
            weight_tr = (dx)       * (1.0 - dy);
            weight_bl = (1.0 - dx) * (dy);
            weight_br = (dx)       * (dy);
            
            value = weight_tl * image(top_left(2), top_left(1), :) + ...
                    weight_tr * image(top_left(2), top_left(1)+1, :) + ...
                    weight_bl * image(top_left(2)+1, top_left(1), :) + ...
                    weight_br * image(top_left(2)+1, top_left(1)+1, :);
            
            dest_im(y, x, :) = value;
        end
    end
end
