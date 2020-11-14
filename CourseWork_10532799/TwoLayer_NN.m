close all
clear all
clc

%Data to show arm configurations (10 end effector positions)
samples = 10;
theta = pi*rand(2,samples);
[P1config,P2config] = RevoluteForwardKinematics2D(0.4, theta, 0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% GENERATE DATASETS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%TRAINING:generate possible end effector positions given random angles
samples = 5000;
thetaTRAIN = pi*rand(2,samples); 
origin = 0;
armLen = 0.4;
[P1train,P2train] = RevoluteForwardKinematics2D(armLen, thetaTRAIN, origin);

%TESTING:generate possible end effector positions given random angles
samples = 5000;
thetaTEST = pi*rand(2,samples); 
origin = 0;
armLen = 0.4;
[P1test,P2test] = RevoluteForwardKinematics2D(armLen, thetaTEST, origin);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%   IMPLEMENT 2 LAYER NETWORK   %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nodes = 10;

%%%%%%%%%%%%%% TRAINING %%%%%%%%%%%%%%

%use training data as input
input = P2train;

%calculate theta1 angles
Data = thetaTRAIN(1,:);
W1 = rand(nodes,3);
W2 = rand(1,nodes+1);
[TRAINJointAngles1,TRAINerror1,W11,W12] = Network(input,Data,nodes,samples,W1,W2);

%calculate theta2 angles
W1 = rand(nodes,3);
W2 = rand(1,nodes+1);
Data = thetaTRAIN(2,:);
[TRAINJointAngles2,TRAINerror2,W21,W22] = Network(input,Data,nodes,samples,W1,W2);

%concatinate joint angles & recalculate end effector position
TRAINJointAngles = [TRAINJointAngles1;TRAINJointAngles2];
[TRAINP1,TRAINP2] = RevoluteForwardKinematics2D(0.4, TRAINJointAngles, 0);



%%%%%%%%%%%%%% TESTING %%%%%%%%%%%%%%

%testing data is now the input
input = P2test;

%calculate theta1 angles
[TESTJointAngles1] = networkTEST(input,nodes,samples,W11,W12);

%calculate theta2 angles
[TESTJointAngles2] = networkTEST(input,nodes,samples,W21,W22);

%concatinate joint angles & recalculate end effector position
TESTJointAngles = [TESTJointAngles1;TESTJointAngles2];
[TESTP1,TESTP2] = RevoluteForwardKinematics2D(0.4, TESTJointAngles, 0);



%%%%%%%%%%%%%%% ALL PLOTS: TRAINING & TESTING %%%%%%%%%%%%%%%

%function containing plots
Plots(P1config,P2config,thetaTRAIN,P2train,TRAINerror1,TRAINerror2,TRAINJointAngles1,TRAINJointAngles2,TRAINP2,thetaTEST,P2test,TESTJointAngles1,TESTJointAngles2,TESTP2);


















