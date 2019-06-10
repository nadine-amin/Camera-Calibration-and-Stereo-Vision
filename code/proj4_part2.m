% Calibration of own Cameras Stencil Code
% Written by Elsayed Hemayed

% This script 
% (1) Loads the left and right image of a calibration pattern
% (2) Develop a technique to extract the calibration points and to sort them according to their location in 3D. 
% (3) Use the functions developed in PART I to calibrate your camera and obtain the camera perspective projection matrix and its optical center.
% (4) Validate the computed projection matrix as done in PART I. You may need to review and repeat your process to ensure getting good calibration.
% Repeat this process for the left and right camera. 
% (5) compute the essential and Fundamental matrix as explained in the lecture. Ref: Szeliski Book sec 7.2

clear
close all

%%
% Load images and prepare them
right=imread('../data/im_1.jpg');
left=imread('../data/im_2.jpg');

%%
% Extract 2d points and map them to 3d points
load('../data/down_left1') %obtained using the camera calibration toolbox
load('../data/up_left1') %obtained using the camera calibration toolbox

load('../data/down_right1') %obtained using the camera calibration toolbox
load('../data/up_right1') %obtained using the camera calibration toolbox
%%
Points_2D_r = [down_right1(:,4:5); up_right1(:,4:5)];
up_right_3D = [up_right1(:,2), -23*ones(size(up_right1,1),1), 23+up_right1(:,1)];
Points_3D_r = [down_right1(:,1:3); up_right_3D];
%Normalize
Points_2D_r = [(Points_2D_r(:,1)-mean(Points_2D_r(:,1)))/std(Points_2D_r(:,1)), (Points_2D_r(:,2)-mean(Points_2D_r(:,2)))/std(Points_2D_r(:,2))];
Points_3D_r = [(Points_3D_r(:,1)-mean(Points_3D_r(:,1)))/std(Points_3D_r(:,1)), (Points_3D_r(:,2)-mean(Points_3D_r(:,2)))/std(Points_3D_r(:,2)), (Points_3D_r(:,3)-mean(Points_3D_r(:,3)))/std(Points_3D_r(:,3))];


Points_2D_l = [down_left1(:,4:5); up_left1(:,4:5)];
up_left_3D = [up_left1(:,2), -23*ones(size(up_left1,1),1), 23+up_left1(:,1)];
Points_3D_l = [down_left1(:,1:3); up_left_3D];
%Normalize
Points_2D_l = [(Points_2D_l(:,1)-mean(Points_2D_l(:,1)))/std(Points_2D_l(:,1)), (Points_2D_l(:,2)-mean(Points_2D_l(:,2)))/std(Points_2D_l(:,2))];
Points_3D_l = [(Points_3D_l(:,1)-mean(Points_3D_l(:,1)))/std(Points_3D_l(:,1)), (Points_3D_l(:,2)-mean(Points_3D_l(:,2)))/std(Points_3D_l(:,2)), (Points_3D_l(:,3)-mean(Points_3D_l(:,3)))/std(Points_3D_l(:,3))];

%% Calculate the projection matrix given corresponding 2D and 3D points
% 
M_l = calculate_projection_matrix(Points_2D_l,Points_3D_l);
M_r = calculate_projection_matrix(Points_2D_r,Points_3D_r);

disp('The left projection matrix is:')
disp(M_l);

disp('The right projection matrix is:')
disp(M_r);

[Projected_2D_Pts_l, Residual_l] = evaluate_points( M_l, Points_2D_l, Points_3D_l);
fprintf('\nThe total left residual is: <%.4f>\n\n',Residual_l);

[Projected_2D_Pts_r, Residual_r] = evaluate_points( M_r, Points_2D_r, Points_3D_r);
fprintf('\nThe total right residual is: <%.4f>\n\n',Residual_r);

visualize_points(Points_2D_l,Projected_2D_Pts_l);
visualize_points(Points_2D_r,Projected_2D_Pts_r);

%% Calculate the camera center using the M found from previous step
Center_l = compute_camera_center(M_l);
Center_r = compute_camera_center(M_r);

fprintf('The estimated location of left camera is: <%.4f, %.4f, %.4f>\n',Center_l);
plot3dview(Points_3D_l, Center_l)

fprintf('The estimated location of right camera is: <%.4f, %.4f, %.4f>\n',Center_r);
plot3dview(Points_3D_r, Center_r)

%%
% compute the fundamental or the essential matrix

M_r_Center_l = (M_r*[Center_l;1]);
M_r_Center_l = [0, -M_r_Center_l(3), M_r_Center_l(2); ...
    M_r_Center_l(3), 0, -M_r_Center_l(1); ...
    -M_r_Center_l(2), M_r_Center_l(1), 0];
F= M_r_Center_l*M_r*(M_l'*inv(M_l*M_l'))




