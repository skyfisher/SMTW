function [ acc, testLabels ] = evaluateAlg( sequences, gnd_labels, alg, opt)
% sequences gnd_label  source data and it's corresponding label
% alg opt, algorithm type and it's parameter

%% Leave-one-out testing Fold1
len              = length(sequences);
objs             = zeros(len, len);
for a=1:len
    objs(a, a) = inf;
end
testLabels       = zeros(1,len);
for i = 1: len
    testSeq = sequences(i);
    for j = i+1: length(sequences)
        fprintf('alg=%s,index=%d,subIndex=%d\n', alg, i, j);
        seq              = sequences(j);
        Xs = {testSeq{1}, seq{1}};
        switch alg
            case 'RCTW'
                aliRCTW   = RCTW_ALM(Xs, opt);
                objs(i,j) = aliRCTW.obj;

            case 'DTW'
                [aliDtw]   = dtw(Xs,[],[]);
                objs(i, j) = aliDtw.obj;
      
            case 'ISOCCA'
                T = floor(min(size(Xs{1},2), size(Xs{2},2))/2);
                [ui, vi, d] = IsoCCA_init(Xs{1},  Xs{2}, T);
                [~, ~, objective_error] = IsoCCA(Xs{1}, Xs{2}, T, 0.5, 0, ui, vi);
                objs(i, j) = objective_error;
            case 'CTW'
                aliCtw = ctw(Xs, dtw(Xs,[],[]), [], opt.parCtw, opt.parCca, opt.parDtw);
                objs(i, j) = aliCtw.obj;
            case 'GTW'
                ns = cellDim(Xs, 2);
                l = round(max(ns) * 1.1);
                bas = baTems(l, ns, 'pol', [5 .5], 'tan', [5 1 1]); % 2 polynomial and 3 tangent 
                aliGtw = gtw(Xs, bas, utw(Xs, bas, []), [], opt.parGtw, opt.parCca, opt.parGN);
                objs(i, j) = aliGtw.obj;
            case 'AECTW'
                [aliAERDTW, ~] = AERDTW({testSeq{1}, seq{1}}, [], opt);
                objs(i,j) = aliAERDTW.obj;
            case 'SAETW'
                [aliSAETW, ~] = SAETW({testSeq{1}, seq{1}}, [], opt);
                objs(i,j) = aliSAETW.obj{end};
            case 'MCTW'
                [aliMCTW, ~] = MarginalCTW({testSeq{1}, seq{1}}, [], opt);
                 objs(i,j) = aliMCTW.obj;
            otherwise
                error('Method not surppoted');
        end
    end
end

objs = objs + objs';
for a=1:len
    [val, ind] = min(objs(a, :));
    testLabels(a) = gnd_labels(ind);
end

acc = sum((testLabels == gnd_labels))/len;

fprintf('===========================================\n');
fprintf('alg=%s, Acc=%f\n', alg, acc); 

end

