function dh_color_wheel(dir_out, radius)
% Color wheel
%
% dh_color_wheel(dir_out, radius)
%
% Inputs:
%   dir_our - Output directory.
%   radius  - Wheel radius in px.
%
% This function creates the polar angle RYGB colour wheel for freesurfer. 
% The script is adapted from Sam Schwarzkopf's examples in the retinotopy 
% tutorial.
%__________________________________________________________________________
% Copyright (C) 2021 Daniel Haenelt

if ~exist('radius','var')  
    radius = 200;
end

% colour peaks
R = [1 0 0];
Y = [1 1 0];
G = [0 1 0];
B = [0 0 1];

% make folder
cd(fileparts(which(mfilename)));
if ~exist(dir_out,'dir') 
    mkdir(dir_out); 
end

% output image matrix
[x,y] = meshgrid(-radius:radius, -radius:radius);
[t,r] = cart2pol(x,y);
t = t / pi * 180; % convert to degrees
t = t + 90; % calibrate angles to stimulus starting position
t = mod(ceil(t),360) + 1; % ensure between 1-360
nr = ceil(r/radius*360); % normalized rho in degrees
nr(nr==0) = 1;

% polar angle
cycles = 2;
steps = 360 / 4 / cycles;
cmap = [];
for c = 1:cycles  
    cmap = [cmap; linspace(R(1), Y(1), steps)', linspace(R(2), Y(2), steps)', linspace(R(3), Y(3), steps)'];
    cmap = [cmap; linspace(Y(1), G(1), steps)', linspace(Y(2), G(2), steps)', linspace(Y(3), G(3), steps)'];
    cmap = [cmap; linspace(G(1), B(1), steps)', linspace(G(2), B(2), steps)', linspace(G(3), B(3), steps)'];
    cmap = [cmap; linspace(B(1), R(1), steps)', linspace(B(2), R(2), steps)', linspace(B(3), R(3), steps)'];
end

% image for output
imgR = zeros(2*radius+1, 2*radius+1);
imgG = zeros(2*radius+1, 2*radius+1);
imgB = zeros(2*radius+1, 2*radius+1);

imgR(r<radius) = cmap(t(r<radius),1);
imgG(r<radius) = cmap(t(r<radius),2);
imgB(r<radius) = cmap(t(r<radius),3);

% final image matrix
img = imgR;
img(:,:,2) = imgG;
img(:,:,3) = imgB;

% Flip left & right side (only affects pol)
img = flip(img, 2);

% copy right side and override left side
img_temp = flip(img, 2);
img(:,1:radius,:) = img_temp(:,1:radius,:);

% save image
imwrite(img,'./img/pol_legend.png');

% eccentricity
cycles = 1;
steps = 360 / 3 / cycles;
cmap = [];
for c = 1:cycles  
    cmap = [cmap; linspace(R(1), Y(1), steps)', linspace(R(2), Y(2), steps)', linspace(R(3), Y(3), steps)'];
    cmap = [cmap; linspace(Y(1), G(1), steps)', linspace(Y(2), G(2), steps)', linspace(Y(3), G(3), steps)'];
    cmap = [cmap; linspace(G(1), B(1), steps)', linspace(G(2), B(2), steps)', linspace(G(3), B(3), steps)'];
end

% image for output
imgR = zeros(2*radius+1, 2*radius+1);
imgG = zeros(2*radius+1, 2*radius+1);
imgB = zeros(2*radius+1, 2*radius+1);

imgR(r<radius) = cmap(nr(r<radius),1);
imgG(r<radius) = cmap(nr(r<radius),2);
imgB(r<radius) = cmap(nr(r<radius),3);

% final image matrix
img = imgR;
img(:,:,2) = imgG;
img(:,:,3) = imgB;

% save image
imwrite(img,'./img/ecc_legend.png');
