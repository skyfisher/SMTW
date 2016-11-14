function [ X ] = norma( X )
%% Centralize and Normalize a matrix

meanX = mean(X, 2);

X = X - repmat(meanX, 1, size(X, 2));
for i =1 : size(X, 1)
    N = norm(X(i,:), 2);
    if (N ~= 0)
        X(i, :) = X(i, :)/N;
    end
end

end