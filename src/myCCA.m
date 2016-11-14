function [Wx, Wy, M1, M2,HIS] = myCCA(X, Y, opt)
%% Canonical Correlation analysis
% X,  Y  :  Input data D*N , feature column wise
% Wx, Wy :  Projextion Matrix
% HIS    :  History result For debug
% Copyright @ Nieliquan 2015/10/17
% Last Modified : 2015/10/28 add dimension reduction
tic;
[d1, N] = size(X);
[d2, ~] = size(Y);
rcov = 1e-4;
if exist('opt', 'var')&&~isempty(opt)
    energy = opt.energy;
else
    energy = 0.95;
end

%% Centralize
meanX = mean(X, 2);
meanY = mean(Y, 2);
X = X - repmat(meanX, 1,size(X, 2));
Y = Y - repmat(meanY, 1,size(Y, 2));

Cxx = X*X'./(N-1)+rcov*eye(d1);
Cyy = Y*Y'./(N-1)+rcov*eye(d2);
Cxy = X*Y'./(N-1);

%% calculate Cxx.^{-1/2}
[U,S,V]=svd(Cxx);
D = diag(1./sqrt(diag(S)));
invCxx = U*D*V';
clear U S V;

%% calculate Cyy.^{-1/2}
[U,S,V]=svd(Cyy);
D = diag(1./sqrt(diag(S)));
invCyy = U*D*V';
clear U S V;

H = invCxx*Cxy*invCyy;

[U, D, V] = svd(H);
t = diag(D);

%% save energy percent
if energy < 1
    for i=1:length(t)
        if sum(t(1:i))/sum(t) >= energy
            d = i;
            break;
        end
    end
else
    d = energy;
end

Wx = invCxx*U(:, 1:d);
Wy = invCyy*V(:, 1:d);

%% For debug
HIS.A    = Wx'*X;
HIS.B    = Wy'*Y;
HIS.D    = D;
HIS.time = toc;

M1 = meanX;
M2 = meanY;
