function [X_Add, Y_Add, Px_Add, Py_Add] = duplicateSample(X, Y, Px, Py)

% X_slice = [1, 10, 30, 50, 60];
% Y_slice = [5, 15, 35, 55, 65];

% duplicate X
X_Add  = [X(:,1),  X(:, 1),  X(:, 2:10),  X(:, 10),  X(:, 10:30),  X(:, 30)];
Px_Add = [Px(:,1), Px(:, 1), Px(:, 2:10), Px(:, 10), Px(:, 10:30), Px(:, 30)];
X_Add  = [X_Add, X(:, 30:50), X(:, 50), X(:, 50:60), X(:, 60:72)];
Px_Add = [Px_Add, Px(:, 30:50), Px(:, 50), Px(:, 50:60), Px(:, 60:72)];

% duplicate Y
Y_Add  = [Y(:,1:5),  Y(:, 5:15),   Y(:, 15), Y(:, 15:35),  Y(:, 35)];
Py_Add = [Py(:,1:5), Py(:, 5:15), Py(:, 15), Py(:, 15:35), Py(:, 35)];

Y_Add  = [Y_Add,  Y(:, 35:55),  Y(:, 55),  Y(:, 55:65), Y(:, 65:72)];
Py_Add = [Py_Add, Py(:, 35:55), Py(:, 55), Py(:, 55:65), Py(:, 65:72)];
end