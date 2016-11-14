%% A framework on testing different algorithms in different datasets
%% along with different methods
%% Copyright @ Nieliquan
%% 2015/11/5
close all ; clc; clear;
infile;
parDtw = [];
parCca = []; % CCA: reduce dimension to keep at least 0.95 energy
parCtw = [];
mtimes = 10; % duplicate times
mctwAccs = [];

%% Load dataset
dataset = 'kth';
switch dataset
    case 'mocap'
        [sequences, gnd_labels] = loadCmuData(10);
        sequences = [sequences(1:18), sequences(28:end)];
        gnd_labels = [gnd_labels(:, 1:18), gnd_labels(:, 28:end)];
        sequences = [sequences(1:33), sequences(35:end)];
        gnd_labels = [gnd_labels(1:33), gnd_labels(35:end)];
    case 'kth'
        pathName = '..\dataset\kth';
        [sequences, gnd_labels] = loadKTHDataset(pathName);
        
    otherwise
        error 'unsupported datasets\n';
end

%% reshuffle the data
index      = randperm(length(gnd_labels));
sequences  = sequences(index);
gnd_labels = gnd_labels(index);

%% Test data on different algorithm
algs = {'MCTW'};
for m = 1:mtimes
for algIndex = 1:length(algs)
    alg = algs{algIndex};
    switch alg
        case 'MCTW'
           %% Init parameter
            opt.layers      = 2;
            opt.lambda      = 0.3;
            opt.beta        = 0.3;
            opt.maxIter     = 10;
            opt.sig_func    = 'sigmoid';
            opt.energy      = 10;
            opt.prob_p      = [0.2, 0.2];
            opt.m           = 5;
            opt.alpha       = 0.001;
            opt.th          = 1e-4;
            opt.version     = 4;
            opt.choose      = 1;

            [acc, testLabels] = evaluateAlg( sequences, gnd_labels, alg, opt);
            fprintf('===========================================\n');
            fprintf('alg=MCTW,version=%d,dataset=%s Acc=%f\n', opt.version, dataset,acc);
            mctwAccs = [mctwAccs, acc];
        otherwise
            error('unsupported method');
    end
end
end

fprintf('alg=MCTW,version=%d,dataset=%s, average Acc=%f\n', opt.version, dataset, sum(mctwAccs(:))/mtimes);