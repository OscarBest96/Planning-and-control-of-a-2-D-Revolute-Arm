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


classdef CMazeMaze10x10
    % define Maze work for RL
    %  Detailed explanation goes here
    
    properties
        
        % parameters for the gmaze grid management
        %scalingXY;
        blockedLocations;
        cursorCentre;
        limitsXY;
        xStateCnt
        yStateCnt;
        stateCnt;
        stateNumber;
        totalStateCnt
        squareSizeX;
        cursorSizeX;
        squareSizeY;
        cursorSizeY;
        stateOpen;
        stateStart;
        stateEnd;
        stateEndID;
        stateX;
        stateY;
        xS;
        yS
        stateLowerPoint;
        textLowerPoint;
        stateName;
        
        % parameters for Q learning
        QValues;
        tm;
        actionCnt;
    end
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % constructor to specity maze
        function f = CMazeMaze10x10(limitsXY)
            
            % set scaling for display
            f.limitsXY = limitsXY;
            f,blockedLocations = [];
            
            % setup actions
            f.actionCnt = 4;
            
            % build the maze
            f = SimpleMaze10x10(f);
            
            % display progress
            disp(sprintf('Building Maze CMazeMaze10x10'));
            
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % build the maze
        function f = SetMaze(f, xStateCnt, yStateCnt, blockedLocations, startLocation, endLocation)
            
            % set size
            f.xStateCnt=xStateCnt;
            f.yStateCnt=yStateCnt;
            f.stateCnt = xStateCnt*yStateCnt;
            
            % compute state countID
            for x =  1:xStateCnt
                for y =  1:yStateCnt
                    
                    % get the unique state identified index
                    ID = x + (y -1) * xStateCnt;
                    
                    % record it
                    f.stateNumber(x,y) = ID;
                    
                    % also record how x and y relate to the ID
                    f.stateX(ID) = x;
                    f.stateY(ID) = y;
                end
            end
            
            % calculate maximum number of states in maze
            % but not all will be occupied
            f.totalStateCnt = f.xStateCnt * f.yStateCnt;
            
            
            % get cell centres
            f.squareSizeX= 1 * (f.limitsXY(1,2) - f.limitsXY(1,1))/f.xStateCnt;
            f.cursorSizeX = 0.5 * (f.limitsXY(1,2) - f.limitsXY(1,1))/f.xStateCnt;
            f.squareSizeY= 1 * (f.limitsXY(2,2) - f.limitsXY(2,1))/f.yStateCnt;
            f.cursorSizeY = 0.5 * (f.limitsXY(2,2) - f.limitsXY(2,1))/f.yStateCnt;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % init maze with no closed cell
            f.stateOpen = ones(xStateCnt, yStateCnt);
            f.stateStart = startLocation;
            f.stateEnd = endLocation;
            f.stateEndID = f.stateNumber(f.stateEnd(1),f.stateEnd(2));
            
            % put in blocked locations
            for idx = 1:size(blockedLocations,1)
                bx = blockedLocations(idx,1);
                by = blockedLocations(idx,2);
                f.stateOpen(bx, by) = 0;
            end
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % get locations for all states
            for x=1:xStateCnt
                for y=1:xStateCnt
                    
                    % start at (0,0)
                    xV = x-1;
                    yV = y-1;
                    
                    % pure scaling component
                    % assumes input is between 0 - 1
                    scaleX =  (f.limitsXY(1,2) - f.limitsXY(1,1)) / xStateCnt;
                    scaleY = (f.limitsXY(2,2) - f.limitsXY(2,1)) / yStateCnt;
                    
                    % remap the coordinates and add on the specified orgin
                    f.xS(x) = xV  * scaleX + f.limitsXY(1,1);
                    f.yS(y) = yV  * scaleY + f.limitsXY(2,1);
                    
                    % remap the coordinates, add on the specified orgin and add on half cursor size
                    f.cursorCentre(x,y,1) = xV * scaleX + f.limitsXY(1,1) + f.cursorSizeX/2;
                    f.cursorCentre(x,y,2) = yV * scaleY + f.limitsXY(2,1) + f.cursorSizeY/2;
                    
                    f.stateLowerPoint(x,y,1) = xV * scaleX + f.limitsXY(1,1);  - f.squareSizeX/2;
                    f.stateLowerPoint(x,y,2) = yV * scaleY + f.limitsXY(2,1); - f.squareSizeY/2;
                    
                    f.textLowerPoint(x,y,1) = xV * scaleX + f.limitsXY(1,1)+ 10 * f.cursorSizeX/20;
                    f.textLowerPoint(x,y,2) = yV * scaleY + f.limitsXY(2,1) + 10 * f.cursorSizeY/20;
                end
            end
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % draw rectangle
        function DrawSquare( f, pos, faceColour)
            % Draw rectagle
            rectangle('Position', pos,'FaceColor', faceColour,'EdgeColor','k', 'LineWidth', 3);
        end
        
        % draw circle
        function DrawCircle( f, pos, faceColour)
            % Draw rectagle
            rectangle('Position', pos,'FaceColor', faceColour,'Curvature', [1 1],'EdgeColor','k', 'LineWidth', 3);
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % draw the maze
        function DrawMaze(f)
            figure('position', [100, 100, 1200, 1500]);
            fontSize = 20;
            hold on
            h=title(sprintf('10532799: Maze wth %d x-axis X %d y-axis cells', f.xStateCnt, f.yStateCnt));
            set(h,'FontSize', fontSize);
            
            for x=1:f.xStateCnt
                for y=1:f.yStateCnt
                    pos = [f.stateLowerPoint(x,y,1)  f.stateLowerPoint(x,y,2)  f.squareSizeX f.squareSizeY];
                    
                    % if location open plot as blue
                    if(f.stateOpen(x,y))
                        DrawSquare( f, pos, 'b');
                        % otherwise plot as black
                    else
                        DrawSquare( f, pos, 'k');
                    end
                end
            end
            
            
            % put in start locations
            for idx = 1:size(f.stateStart,1)
                % plot start
                x = f.stateStart(idx, 1);
                y = f.stateStart(idx, 2);
                pos = [f.stateLowerPoint(x,y,1)  f.stateLowerPoint(x,y,2)  f.squareSizeX f.squareSizeY];
                DrawSquare(f, pos,'g');
            end
            
            % put in end locations
            for idx = 1:size(f.stateEnd,1)
                % plot end
                x = f.stateEnd(idx, 1);
                y = f.stateEnd(idx, 2);
                pos = [f.stateLowerPoint(x,y,1)  f.stateLowerPoint(x,y,2)  f.squareSizeX f.squareSizeY];
                DrawSquare(f, pos,'r');
            end
            
            % put on names
            for x=1:f.xStateCnt
                for y=1:f.yStateCnt
                    sidx=f.stateNumber(x,y);
                    stateNameID = sprintf('%s', f.stateName{sidx});
                    text(f.textLowerPoint(x,y,1),f.textLowerPoint(x,y,2), stateNameID, 'FontSize', 20)
                end
            end
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % setup 10x10 maze
        function f = SimpleMaze10x10(f)
            
            xCnt=10;
            yCnt=10;
            
            % specify start location in (x,y) coordinates
            % example only
            startLocation=[1 1];
            % YOUR CODE GOES HERE
            
            
            % specify end location in (x,y) coordinates
            % example only
            endLocation=[10 10];
            % YOUR CODE GOES HERE
            
            
            % specify blocked location in (x,y) coordinates
            blockedLocations = [1 3; 1 4; 1 5; 1 6;
                                2 8; 2 9;
                                3 3; 3 8; 3 9;
                                4 1; 4 3; 4 4; 4 5; 4 6; 4 7; 4 8; 4 9;
                                5 4; 5 5;
                                6 2; 6 5; 6 6; 6 8; 6 9; 6 10;
                                7 5; 7 6;
                                8 2; 8 3; 8 7; 8 8;
                                9 2; 9 3; 9 8; 9 9;
                                10 5; 10 6;];
            
            
            % build the maze
            f = SetMaze(f, xCnt, yCnt, blockedLocations, startLocation, endLocation);
            
            % write the maze state
            maxCnt = xCnt * yCnt;
            for idx = 1:maxCnt
                f.stateName{idx} = num2str(idx);
            end
            
        end
        
        
        
          function action =  GreedyActionSelection(f,Qtable, stateID, e)
         
          %return max value and it's position
          [value, pos] = max(Qtable(stateID,:));
          a = pos;
          
          %select a value at random from the Qtable row
          eACTIONS = Qtable(stateID,:);
          ePOS =randi(length(eACTIONS));
          
          %create a random value between 0-1 for comparison
          probVECTOR = rand;
          
          % e% chance a random action is selected else max is selected
          if (probVECTOR <= e)
          action = ePOS;
          else
          action = a;


         end
        
        end
        
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % reward function that takes a stateID and an action
        function reward = RewardFunction(f, stateID, action)
           
            %reward is given if action leads to reward state (100)
           if((stateID == 99 && action == 2)||(stateID == 90 && action == 1))
               reward = 10;
           else
               reward = 0;
           end
         end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % function  computes a random starting state
        function startingState = RandomStatingState(f)
            %lists all possible starting states
            x=[1 2 3 5 6 7 8 9 10 11 12 13 14 15 17 20 22 25 26 27 30 32 33 36 37 38 39 40 42 43 48 49 52 53 55 58 59 61 62 63 65 66 67 69 70 71 75 77 80 81 85 87 88 90 91 92 93 94 95 97 98 99];
           
            %selects a state at random and assigns to starting state
            pos = randi(length(x));
            startingState = x(pos);   
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % look for end state
        function endState = IsEndState(f, resultingState)
            
            %endState is flagged as soon as state 100 is reached
            if (resultingState == 100)
            endState=1;
            else 
            endState=0;
            end
            
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % init the q-table
        function f = InitQTable(f,minVal, maxVal)
            
        %set value range    
        range = maxVal - minVal;
        mean = (0.1 + 0.01)/2;
        %init Qtable to all zeros
        Qtable = zeros(100,4);
        
        %fill in table with random values within limits
        for idx1 = 1:100
           for idx2 = 1:4
               y = range * (rand - 0.5) + mean;
               Qtable(idx1,idx2)= y;
           end
        end
        %endstate set to all zeros(as Qlearning will terminate)
        Qtable(100,:) =[0 0 0 0];
        f = Qtable;
        end
        
        
        
        function Qtable = UpdateQ(f,Qtable,stateID,action,resultingState,reward,alpha,gamma)
        
        %implement Qlearning equation
        Qtable(stateID,action) = Qtable(stateID,action) + alpha *(reward+(gamma*(  max(Qtable(resultingState,:)) ))-Qtable(stateID,action));

        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % % build the transition matrix
        % look for boundaries on the grid
        % also look for blocked state
        function f = BuildTransitionMatrix(f)
            
            %initialise the transormation matrix
            f.tm=[11 2 1 1;12 3 1 2;13 3 3 2;0 0 0 0;15 6 5 5;6 7 6 5;17 8 7 6;8 9 8 7;9 10 9 8;20 10 10 9;
                 11 12 1 11;22 13 2 11; 13 14 3 12;14 15 14 13;25 15 5 14;0 0 0 0;27 17 7 17;0 0 0 0;0 0 0 0; 30 20 10 20;
                 0 0 0 0;32 22 12 22;0 0 0 0;0 0 0 0;25 26 15 25;36 27 26 25;37 27 17 26;0 0 0 0;0 0 0 0;40 30 20 30;
                 0 0 0 0;42 33 22 32;43 33 33 32;0 0 0 0;0 0 0 0;36 37 26 36;37 38 27 26;48 39 38 37;49 40 39 38;40 40 30 39;
                 0 0 0 0;52 43 32 42;53 43 33 42;0 0 0 0;0 0 0 0;0 0 0 0;0 0 0 0;58 49 38 48;59 49 39 48;0 0 0 0;
                 0 0 0 0;62 53 42 52;63 53 43 52;0 0 0 0;65 55 55 55;0 0 0 0;0 0 0 0;58 59 48 58;69 59 49 58;0 0 0 0;
                 71 62 61 61;62 63 52 61;63 63 53 62;0 0 0 0;75 66 55 65;66 67 66 65;77 67 67 66;0 0 0 0;69 70 69 69;80 70 70 69;
                 81 71 61 71;0 0 0 0;0 0 0 0;0 0 0 0;85 75 65 75;0 0 0 0;87 77 67 77;0 0 0 0;0 0 0 0;90 80 70 80;
                 91 81 71 81;0 0 0 0;0 0 0 0;0 0 0 0;95 85 75 85;0 0 0 0;97 88 77 87;98 88 88 87;0 0 0 0;100 90 80 90;
                 91 92 81 91;92 93 92 91;93 94 93 92;94 95 94 93;95 95 85 94;0 0 0 0;97 98 87 97;98 99 88 97;99 100 99 98;100 100 90 99];
           end
        
    end
end

