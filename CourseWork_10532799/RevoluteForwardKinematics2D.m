function [P1 P2] = RevoluteForwardKinematics2D(armLen, theta, origin)
% calculate revolute arm forward kinematics
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% all rights reserved
% Author: Dr. Ian Howard
% Associate Professor (Senior Lecturer) in Computational Neuroscience
% Centre for Robotics and Neural Systems
% Plymouth University
% A324 Portland Square
% PL4 8AA
% Plymouth, Devon, UK
% howardlab.com
% 22/09/2018
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

armLen(1) = armLen;
armLen(2) = armLen;
origin(1) = origin;
origin(2) = origin;

% unpack joint angles to make clear what we are dong here
theta1 = theta(1,:);
theta2 = theta(2,:);

% unpack segment length
l1 = armLen(1);
l2 = armLen(2);

% relative forward kinematics
x = l1 * cos(theta1) + ones(size(theta1)) * origin(1);
y = l1 * sin(theta1) + ones(size(theta1)) * origin(2);

% pack results
P1 = [x; y;];

% relative forward kinematics
x = l1 * cos(theta1) + l2 * cos(theta1 + theta2) + ones(size(theta2)) * origin(1);
y = l1 * sin(theta1) + l2 * sin(theta1 + theta2) + ones(size(theta2)) * origin(2);

% pack results
P2 = [x; y;];

end


