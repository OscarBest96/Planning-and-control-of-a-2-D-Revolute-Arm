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

% run maze experiments
% you need to expand this script to run the assignment

close all
clear all
clc

%scaled to fit within arm workspace
limits = [-0.6 -0.1; -0.2 0.3;]; %for arm movement through maze

%limits = [0 1; 0 1;]; %for path through maze
% build the maze
maze = CMazeMaze10x10(limits);


%histogram of starting states 1000 states 100 bins
for trials = 1:1000
startingState = maze.RandomStatingState();
x(trials) = startingState;
end

figure(1)
hold on
title('10532799: Histogram of starting states')
histogram(x, 100);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%   IMPLEMENT QLEARNING   %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%set range for initial Qvalues
minVal = 0.001;
maxVal = 0.1;

%build transition matrix
T = maze.BuildTransitionMatrix();
transitionMatrix = T.tm;


%Trails
for trials = 1:100  
    Qtable = maze.InitQTable(minVal, maxVal); %init Qtable
    
    %Episodes
    for episodes = 1:1000
    startingState = maze.RandomStatingState(); %select random starting state
    stateID = startingState; %assign starting state to 'stateID'
    endState = 0; %init endState to 0
    steps = 0; %init steps to 0
    
       %Steps
       while(endState == 0) %while end state hasn't been reached
       e = 0.1; %exploration rate
       action = maze.GreedyActionSelection(Qtable,stateID,e); %chose action
       reward = maze.RewardFunction(stateID, action); %reward recieved?
       resultingState = T.tm(stateID, action); %resulting state
       endState = maze.IsEndState(resultingState); %checks if endstate is reached
       alpha=0.2; %learning rate 
       gamma=0.9; %temporal discount rate
       Qtable = maze.UpdateQ(Qtable,stateID,action,resultingState,reward,alpha,gamma); %update Qtable
       stateID = resultingState; %update the state
       steps = steps+1; %increment steps
       end
       
      stepARRAY(episodes,trials) = steps; %creates matrix of steps for each episode per trail
    
    end
    
end

%calculate episode mean & std
[episodeMEAN,episodeSTD] = QLearningOperation(stepARRAY);

%Mean and std of steps plotted against episode.
%{
figure(2);
hold on
h=title(sprintf('10532799: Q learning in operation across multiple trials'));
xlabel('Episode number');
ylabel('Number of steps');
errorbar(episodeMEAN,episodeSTD);
%}


%%%%%%%%%%%%%%%%%%%% Plot line through the maze %%%%%%%%%%%%%%%%%%%%


%coordinates of the optimal route
[stateXY] = Exploitation(Qtable);
%coordinates scaled for maze
stateXY(1,:) = (stateXY(1,:).*(1/20))-0.6;
stateXY(2,:) = (stateXY(2,:).*(1/20))-0.2;

%plotting on the maze
%{
figure(3)
maze.DrawMaze();
plot(stateXY(1,:),stateXY(2,:),'mx-', 'MarkerSize',15,'LineWidth',4);
%}
    

%%%%%%%%%%%%%% Generate kinematic control to revolute arm %%%%%%%%%%%%%%

input = stateXY; % input is now the end effector position coordinates for the optimal route through the maze
samples = length(stateXY); % same number of samples as stateXY inputs
[W11,W12,W21,W22] = Weights(); %optimal weights from trained network
nodes = 10; %using 10 nodes
 
%calculate theta1 angles
[JointAngles1] = networkTEST(input,nodes,samples,W11,W12);
%calculate theta2 angles
[JointAngles2] = networkTEST(input,nodes,samples,W21,W22);

%concatenate joint angles 1&2
JointAngles = [JointAngles1; JointAngles2];

%run joint angles through the forward kinematics function to return end
%effector positions
[P1,P2] = RevoluteForwardKinematics2D(0.4, JointAngles, 0);
  
% Animated revolute arm movement
figure(3)
maze.DrawMaze();
h=title(sprintf('10532799: Animated revolute arm movement'));
xlabel('X coordinate');
ylabel('Y coordinate');
pause(5);
plot(stateXY(1,:),stateXY(2,:),'mx-', 'MarkerSize',15,'LineWidth',4); %plot path 
plot(0,0,'k*'); %plot origin
for idx = 1:length(stateXY)
    %plot arm and both joints for each cooardinate 
    plot([0,P1(1,idx)],[0,P1(2,idx)],'r-',[P1(1,idx),P2(1,idx)],[P1(2,idx),P2(2,idx)],'r-','linewidth',2);
    plot(P1(1,idx),P1(2,idx),'go');
    plot(P2(1,idx),P2(2,idx),'co');
    pause(0.3);% pause between steps to show animated movement
end
hold off






     





