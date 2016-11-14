%% A framework on testing different algorithms in different datasets
%% along with different methods
%% Copyright @ Nieliquan
%% 2015/11/5
close all ; clc; clear;
infile;
parDtw = [];
parCca = []; % CCA: reduce dimension to keep at least 0.95 energy
parCtw = [];

%% Load dataset
dataset = 'mocap';
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
    case 'weizman'
        [sequences, gnd_labels] = loadWeizman();
    otherwise
        error 'unsupported datasets\n';
end

%% reshuffle the data
index      = randperm(length(gnd_labels));
sequences  = sequences(index);
gnd_labels = gnd_labels(index);

%% Test data on different algorithm
algs = { 'MCTW'};
for algIndex = 1:length(algs)
    alg = algs{algIndex};
    switch alg
        case 'MCTW'
           %% Init parameter
            opt.layers      = 2;
            opt.lambda      = 0.5;
            opt.beta        = 0.5;
            opt.maxIter     = 15;
            opt.sig_func    = 'sigmoid';
            opt.energy      = 10;
            opt.prob_p      = [0.2, 0.2];
            opt.m           = 10;
            opt.th          = 1e-6;
            opt.version     = 4;
            opt.choose      = 1;

            [acc, testLabel] = evaluateAlg( sequences, gnd_labels, alg, opt);
            fprintf('===========================================\n');
            fprintf('alg=MCTW,version=%d,dataset=%s Acc=%f\n', opt.version, dataset, acc);

        otherwise
            error('unsupported method');
    end
end