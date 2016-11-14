%% A demo for testing sythetic data using SMTW
%% Copyright @ Liquan Nie
%% Mail: nieliquan@gmail.com

clc;clear;close all;infile;

D = 2;

%% synthetic data
N = 600;
[data1,data2] = synthesize_data(N, 'spiral',true);

[d1,n1] = size(data1);
[d2,n2] = size(data2);
P_truth = [[1:n1]',[1:n2]'];

%% showing unaligned data
figure;
plot_correspondences(data1,data2);
title('Unaligned');

Xs = {data1, data2};

opt.choose =1;


if d1 < d2, data1(d1+1:d2,:) = 0; end
if d2 < d1, data2(d2+1:d1,:) = 0; end
Xs = {data1,data2};
[ctwAln, ys] = ctw(Xs, myTemporalAlignment(Xs, opt),[], {'b', D});
data1 = data1(1:d1,:);
data2 = data2(1:d2,:);
aln1 = ys{1};
aln2 = ys{2};

%% Alignment result of CTW
figure;title('CTW alignment');
plot_correspondences(aln1,aln2);

clear opt;clear ali; clear HIS;
difs = [];

%% Alignemtn result of SMTW
opt.layers      = 2;
opt.lambda      = 0.001;
opt.beta        = 0.001;
opt.maxIter     = 20;
opt.sig_func    = 'sigmoid';
opt.energy      = 2;
opt.prob_p      = [0.5, 0.5];
opt.m           = 1;
opt.choose      = 1;
opt.th          = 1e-6;
opt.version     = 4;
opt.debug       = 1;

[ali, HIS] = MarginalCTW(Xs, [], opt);

%% Alignment result using layer 1
figure; title('SMTW 1');
X = norma(data1); Y = norma(data2);
plot_correspondences(ali.h1{end}*ali.Tx,ali.h2{end}*ali.Ty);

%% Alignment result using layer 2
figure; title('SMTW 2');
plot_correspondences(ali.h1{end}*ali.Tx,ali.h2{end}*ali.Ty);
