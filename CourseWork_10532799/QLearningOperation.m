function [episodeMEAN,episodeSTD] = QLearningOperation(stepARRAY)

%calculate mean and std across trials of the steps taken against episodes
for idx3 = 1:1000
   episodeMEAN(idx3) = mean(stepARRAY(idx3,:));
   episodeSTD(idx3) = std(stepARRAY(idx3,:));
end

end

