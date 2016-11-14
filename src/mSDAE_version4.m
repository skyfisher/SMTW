function [W1,W2, h1, h2, obj,addObjs] = mSDAE_version4(X, Y, Tx, Ty, opt)
%% Learn Projection matrix W through Stacked Marginal Denoising Autoencoder
% X,   Y : Input data
% Tx, Ty : Projection matrix
% opt    : Input parameters
% W, h   : Output Pojection matrix along with output of the network
% Copyright @ Nieliquan  2016/4/19
% Last Modified:

layers = opt.layers;
W1     = {};
W2     = {};
h1     = {};
h2     = {};
obj    = {};
for layer = 1 : layers
    opt.layer = layer;
    [W1_temp, W2_temp, h1_temp, h2_temp, obj_temp, temp_addObjs]=mDAE(X, Y, Tx, Ty, opt);
    W1{layer} = W1_temp;
    W2{layer} = W2_temp;
    
    X          = h1_temp;
    Y          = h2_temp;
    h1{layer}  = h1_temp;
    h2{layer}  = h2_temp;
    
    obj{layer} = obj_temp;
    addObjs{layer} = temp_addObjs;
    
%     fprintf('Layer= %d\n', layer);
end

function [W1, W2, h1, h2, obj, addObjs] = mDAE(X, Y, Tx, Ty, opt)
%% Single Layer Maginal Denoising Autoencoder
% W1, W2 : Projection matrix
% h1, h2 : Nonlinear transformation of input data
% Copyright @ Nieliquan 2016/4/19
sig_func    = opt.sig_func;
lambda      = opt.lambda;
beta        = opt.beta;
m           = opt.m;
par.energy  = opt.energy;    % opt.energy;

X = norma(X); 
Y = norma(Y);

% duplicate m times
Xm = repmat(X*Tx, 1, m);
Ym = repmat(Y*Ty, 1, m);

%% Initialize Each layer's alignment matrix
aliTemp = myTemporalAlignment({X, Y}, opt);
P1 = aliTemp.P(:, 1); P2 = aliTemp.P(:, 2);
Tx = full(sparse(P1, 1:length(P1), 1));
Ty = full(sparse(P2, 1:length(P2), 1));

[W1, W2]   = myCCA(X*Tx, Y*Ty, par);

% solving W1 and W2 with closed form solution
prob_p = opt.prob_p(opt.layer);
lenNum = size(X,1);
prob_q = ones(lenNum,1).*(1-prob_p);
XXt    = Xm*Xm';
Qxx    = XXt.*(prob_q*prob_q');
Qxx(1:lenNum+1:end) = prob_q.*diag(XXt);
Pxx    = XXt.*repmat(prob_q',lenNum,1);
YYt    = Ym*Ym';
Qyy    = YYt.*(prob_q*prob_q');
Qyy(1:lenNum+1:end) = prob_q.*diag(YYt);
Pyy    = YYt.*repmat(prob_q',lenNum,1);

%% add for showing objs
addObjs  =[];
for i=1:opt.maxIter
    oldW1 = W1;
    W1 = (W2*Y*Ty*Tx'*X'+lambda*Pxx)/(X*Tx*Tx'*X'+lambda*Qxx + beta*eye(size(X, 1)));
    W2 = (W1*X*Tx*Ty'*Y'+lambda*Pyy)/(Y*Ty*Ty'*Y'+lambda*Qyy + beta*eye(size(Y, 1)));
    
    aliTemp = myTemporalAlignment({W1*X, W2*Y}, opt);
    P1 = aliTemp.P(:, 1); P2 = aliTemp.P(:, 2);
    Tx = full(sparse(P1, 1:length(P1), 1));
    Ty = full(sparse(P2, 1:length(P2), 1));
    df = norm(oldW1-W1, 'fro')/norm(oldW1, 'fro');
    tempobj = norm(W1*X*Tx-W2*Y*Ty, 'fro');
    addObjs = [addObjs, tempobj];
%     fprintf('iter=%d, df=%f\n', i, df);
    %% check convergence
    if(df < opt.th)
        break;
    end
end

obj = norm(W1*X*Tx-W2*Y*Ty, 'fro');

switch(sig_func)
    case 'sigmoid'
        h1 = 1./(1+exp(-W1*X));
        h2 = 1./(1+exp(-W2*Y));
    case 'tanh'
         h1 = tanh(W1*X);
         h2 = tanh(W2*Y);
    case 'relu'
        h1 = max(0, W1*X);
        h2 = max(0, W2*Y);
    case 'linear'
        h1 = W1*X;
        h2 = W2*X;
    otherwise
        error('unsupported non-linear method\n');
end

end
end