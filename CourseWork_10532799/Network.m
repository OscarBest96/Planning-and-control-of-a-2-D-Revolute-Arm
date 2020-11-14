function [net, error, W1, W2] = Network(input,Data,nodes,samples,W1,W2)

%augment input data
X = [input;ones(1,samples)];

%loop for..
for idx = 1:5000
    
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

%return output 'net3'
net = net2;

%output (upper) layer delta term
delta3 = -(Data-net2);

%input (lower) layer delta term
delta2 = (W2(1,1:nodes)'*delta3).*a2.*(1-a2);

%error gradient w.r.t W1
dEdW1 = delta2*X';

%error gradient w.r.t W2
dEdW2 = delta3*a2AUG';

%update weights
alpha = 0.0001;  %learning rate
%W1
W1 = W1-(alpha.*dEdW1);
%W2
W2 = W2-(alpha.*dEdW2);

%error
error(idx) = SumSquaredError(Data,net2);

end
 
end

