function [net] = networkTEST(input,nodes,samples,W1,W2)
%This function passes the trained weights to implement the trained network
%on testing data.

%augment input
X = [input;ones(1,samples)];

%calculate net and a2 for N number of nodes
for idx2 = 1:nodes
net(idx2,:) = W1(idx2,:)*X;

for idx3 = 1:samples
a2(idx2,idx3) = 1/(1+exp(-net(idx2,idx3)));
end
end

%augment output of the sigmoid
a2AUG = [a2;ones(1,samples)];

%output
net2 = W2*a2AUG;

%return net
net = net2;


