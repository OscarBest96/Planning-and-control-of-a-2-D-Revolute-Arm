function [error] = SumSquaredError(theta,output)

%calculate the sum squared error
for idx = 1:length(theta)
    errorA(idx) = (theta(idx)-output(1,idx))^2;
end
    error = sum(errorA);
    
    
end

