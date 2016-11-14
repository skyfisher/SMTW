function [ali, HIS]=MarginalCTW(Xs, aliT, opt)
%% Marginal Autoencoder regularized CTW
% Xs     : Input data D*N, feature column wise
% aliT   : Target alignment
% ali    : Alignment result
% HIS    : Result history for debug
% Copyright @ Nieliquan 2016/4/19
% Last Modified :

maxIter = 1;
version = opt.version;
X = Xs{1};    Y = Xs{2};
X = norma(X); Y = norma(Y);

th       = 1e-6;
[d1, N1] = size(X);
[d2, N2] = size(Y);

%% Data Initialization
aliTemp = myTemporalAlignment({X, Y},opt);
P1 = aliTemp.P(:, 1); 
P2 = aliTemp.P(:, 2);
oldP = [P1, P2];
Tx = full(sparse(P1, 1:length(P1), 1));
Ty = full(sparse(P2, 1:length(P2), 1));

[W1, W2]   = myCCA(X*Tx, Y*Ty, []);

HIS.objs  = [];
HIS.diffs = [];

% Iteration
for iter=1:1
    % Update Wx Wy
    switch version
        case 1
            [W1, W2, h1, h2, objs] = mSDAE_version1(X, Y, Tx, Ty, opt);
        case 2
            [W1, W2, h1, h2, objs] = mSDAE_version2(X, Y, Tx, Ty, opt);
        case 3
            [W1, W2, h1, h2, objs] = mSDAE_version3(X, Y, Tx, Ty, opt);
        case 4
            [W1, W2, h1, h2, objs,addObjs] = mSDAE_version4(X, Y, Tx, Ty, opt);
        case 5
            [W1, W2, h1, h2, objs] = mSDAE_version5(X, Y, Tx, Ty, opt);
        otherwise
            error('Unsupported method version for Marginal SDA');
    end

    aliTemp = myTemporalAlignment({h1{end}, h2{end}}, opt);
    P1 = aliTemp.P(:, 1); P2 = aliTemp.P(:, 2);
    Tx = full(sparse(P1, 1:length(P1), 1));
    Ty = full(sparse(P2, 1:length(P2), 1));

    P       = [P1, P2];
    Vs      = {W1, W2, h1, h2};
    ali.W1  = W1;
    ali.W2  = W2;
    ali.h1  = h1;
    ali.h2  = h2;
    ali.Tx  = Tx;
    ali.Ty  = Ty;
    ali.obj = objs{end};
    ali.objs = objs;
    ali.P   = P;
    
    % object value
    diff      = aliDif(P, oldP);
    HIS.objs  = [HIS.objs, ali.obj];
    HIS.diffs = [HIS.diffs, diff];
%     fprintf('Iter %d:diff=%f,obj=%f\n',iter,diff,ali.obj);
    if diff < th
        break;
    end
    
    oldP=P;
end

ali.alg = 'MCTW';
if exist('aliT', 'var') && ~isempty(aliT)
    ali.dif = aliDif(ali.P, aliT.P);
end
end