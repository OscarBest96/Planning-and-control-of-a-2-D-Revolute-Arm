function  [coordinates] = StateCoordinates(stateID)

if(mod(stateID,10)==0) %this indicates that the X coordinate is on the tenth column
    X=10;
else
    X=mod(stateID,10); %isolates the first digit of the 2-digit number and assigns to X
end
 Y=(stateID-X)/10; %minus digit from tenth and divide by 10 to isolate 2nd digit. Assign to Y
 
 
%center in square
X=X-0.5;
Y=Y+0.5;

%return coordinate vector
coordinates = [X;Y];

end

