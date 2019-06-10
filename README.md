# Camera-Calibration-and-Stereo-Vision

This project is based on the assignment developed by Henry Hu, Grady Williams, and James Hays based on a similar project by Aaron Bobick and modified by Elsayed Hemayed.

The camera projection matrix is calculated from a set of matched 2D and 3D points. The coordinates of the camera center are also calculated. Next, the mobile camera is calibrated and used to reconstruct some points of a chosen object.

# Running the Code

Prior to running the code, please set up VLFeat (necessary for running the third part of the project).

In order to calculate the camera projection matrix and the coordinates of the camera center from a set of matched 2D and 3D points, please run the script "proj4_part1".

In order to calibrate the mobile camera, please run the script "proj4_part2".

In order to reconstruct some points of the chosen object using two cameras, please run the script "proj4_part3".
