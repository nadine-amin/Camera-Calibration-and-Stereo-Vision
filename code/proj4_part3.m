% Depth Measurement Stencil Code
% Written by Elsayed Hemayed

% This script 
% (1) Load your calibration data done in PART II.
% (2) Load the image of your selected object using your cameras. Do not move your cameras from the calibration position.
% (3) Use the provided computer vision software library VLFeat to perform SIFT detection and matching so you can identify a set of matched points in the images. 
% (4) Improve your results by checking the epipolar constraint using the fundamental or essential matrix computed in PART II. 
% (5) Reconstruct the matched points. You can use the provided reconstruction tool reconstruct_3D.m explained in reconstruct.pdf file. Or use the MATLAB triangulate function available starting from R2014b.
% (6) Draw the reconstructed points in the 3D coordinates and discuss the reconstruction accuracy.

clear
close all

%%
% Load calibration data

M_l=[-0.8015 0.4403 -0.0333 -0.0524; ...
    0.0194 0.1065 -0.9037 -0.1055; ...
    -0.0374 -0.1722 -0.0298 1.0000];
M_r=[-0.5558 -0.6756 0.0571 0.0724; ...
    -0.0346 0.0944 -0.9229 -0.0931; ...
    0.0609 -0.1405 -0.0155 1.0000];

Center_l=[2.7245; 5.1202; 0.5454];
Center_r=[-5.4898; 4.6726; 0.5833];
F=[-0.0040 -0.4438 -0.2135; ...
    -0.2963 -0.0945 4.8764; ...
    -0.1843 -4.9775 -0.0666];
%%
% Load images and prepare them
pic_l=imread('../data/object_left.jpg');
pic_r=imread('../data/object_right.jpg');

%%
% Extract and match SIFT points from both images
% and Improve your results by checking the epipolar constraint using the fundamental or essential matrix. 
% The proposed solution provided here is not the optimum so feel free to do
% your own. A better approach is do the matching and the checking simultanously 

[Points_2D_l, Points_2D_r] = sift_wrapper( pic_l, pic_r );
fprintf('Found %d possibly matching features\n',size(Points_2D_l,1));
%%
% show_correspondence2(pic_l, pic_r, Points_2D_l(:,1), Points_2D_l(:,2), Points_2D_r(:,1),Points_2D_r(:,2));
index = [60; 65; 72; 74; 75; 76; 79; 80; 86; 87; 88; 89; 90; 91]; %[65; 79][65; 87]
show_correspondence2(pic_l, pic_r, Points_2D_l(index,1), Points_2D_l(index,2), Points_2D_r(index,1),Points_2D_r(index,2));
%%
%reject points that violate the epipolar contraint
Points_2D_l_refined = Points_2D_l(index, :);
Points_2D_r_refined = Points_2D_r(index, :);

% normalize
Points_2D_r_norm = [(Points_2D_r(:,1)-mean(Points_2D_r(:,1)))/std(Points_2D_r(:,1)), (Points_2D_r(:,2)-mean(Points_2D_r(:,2)))/std(Points_2D_r(:,2))];
Points_2D_l_norm = [(Points_2D_l(:,1)-mean(Points_2D_l(:,1)))/std(Points_2D_l(:,1)), (Points_2D_l(:,2)-mean(Points_2D_l(:,2)))/std(Points_2D_l(:,2))];

Points_2D_l_refined_norm = Points_2D_l_norm(index, :);
Points_2D_r_refined_norm = Points_2D_r_norm(index, :);

indices = [];
for i = 1:length(index)
    point_l = [Points_2D_l_refined_norm(i,1); Points_2D_l_refined_norm(i,2); 1];
    point_r = [Points_2D_r_refined_norm(i,1); Points_2D_r_refined_norm(i,2); 1];
    if abs(point_r'*F*point_l) < 0.1
        indices = [indices; i];
    end
end

Points_2D_l_refined = Points_2D_l_refined(indices,:);
Points_2D_r_refined = Points_2D_r_refined(indices,:);

Points_2D_l_refined_norm = Points_2D_l_refined_norm(indices,:);
Points_2D_r_refined_norm = Points_2D_r_refined_norm(indices,:);
%% Reconstruct the matched points
%  You can use the provided reconstruction tool reconstruct_3D.m explained in reconstruct.pdf file. Or use the MATLAB triangulate function available starting from R2014b.

mk = cat(3, Points_2D_r_refined_norm, Points_2D_l_refined_norm);
Pk = cat(3, M_r, M_l);
Points_3D = reconstruct_3D(mk, Pk);

% Save the points to a file
save('Points_3D.mat', 'Points_3D')
%% Draw the reconstructed points in the 3D coordinates 
% discuss the reconstruction accuracy.

% feel free to use different visualization function to better show your
% results.
fprintf('The estimated location of left camera is: <%.4f, %.4f, %.4f>\n',Center_l);
plot3dview(Points_3D, Center_l)

fprintf('The estimated location of right camera is: <%.4f, %.4f, %.4f>\n',Center_r);
plot3dview(Points_3D, Center_r)

%%
% Make sure to prove the accuracy of your reconstruction 
[Projected_2D_Pts_l, Residual_l] = evaluate_points( M_l, Points_2D_l_refined_norm, Points_3D);
fprintf('\nThe total left residual is: <%.4f>\n\n',Residual_l);

[Projected_2D_Pts_r, Residual_r] = evaluate_points( M_r, Points_2D_r_refined_norm, Points_3D);
fprintf('\nThe total right residual is: <%.4f>\n\n',Residual_r);

