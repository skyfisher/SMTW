%% A demo for COIL dataset using SMTW
%% Copyright @ Liquan Nie
%% Mail: nieliquan@gmail.com

clear;clc;close all;
coil_path = './dataset/coil-100';
D = 71;

%% Cars
cats = read_coil_images(coil_path,15);
dogs = read_coil_images(coil_path,19);

n = size(cats,1);
dim = size(cats,2)*size(cats,3);
X = zeros(dim,n);
Y = zeros(dim,n);
for i = 1:72
    X(:,i) = reshape(cats(i,:,:),[],1);
    Y(:,i) = reshape(dogs(i,:,:),[],1);
end

%% show all image 
train_index = 1:5:72;
ShowX = X(:, train_index);
ShowY = Y(:, train_index);

total_col = length(train_index);

[bigImageX] = convertImageSequence(ShowX, 128, 128);
[bigImageY] = convertImageSequence(ShowY, 128, 128);
bigImage = [bigImageY];
figure; imshow(bigImage/255);
title('Ground truth alignment sequence');
pcaOpt.ReducedDim = 64;

%% Mix picture with duplicate pictures
Px = 1: size(X, 2);
Py = 1: size(Y, 2);
[X, Y, Px_truth, Py_truth] = duplicateSample(X, Y, Px, Py);
originX = X;
originY = Y;
[eigVec, ~] = PCA(X', pcaOpt);
X = eigVec'*X;
[eigVec, ~] = PCA(Y', pcaOpt);
Y = eigVec'*Y;


[d1,n1] = size(X);
[d2,n2] = size(Y);

train_idx = 1:5:72;
test_idx  = setdiff(1:72,train_idx);
num_train = length(train_idx);
num_test  = n - num_train;
X = norma(X);
Y = norma(Y);
Xs = {X, Y};

[ctwAln, ctwys] = ctw(Xs, dtw(Xs), [], {'b',71});

%% Marginal denoisng autoencoder corruption 1
opt.layers      = 2;
opt.lambda      = 0.3;
opt.beta        = 0.3;
opt.maxIter     = 15;
opt.sig_func    = 'sigmoid';
opt.energy      = size(Xs{1}, 1);
opt.prob_p      = [0.2, 0.2];
opt.m           = 1;

opt.th          = 1e-6;
opt.version     = 4;
opt.choose      = 1;
[aliSMTW, ~] = MarginalCTW(Xs, [], opt);

%% show alignment result of CTW
figure;
title('CTW COIL');
plot_correspondences(ctwys{1}, ctwys{2});

%% show representation of SMTW
figure;title('SMTW COIL layer 1');
plot_correspondences(aliSMTW.h1{1}, aliSMTW.h2{1});

figure;title('SMTW COIL layer 2');
plot_correspondences(aliSMTW.h1{end}, aliSMTW.h2{end});


