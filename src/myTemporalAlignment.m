function ali = myTemporalAlignment(Xs, opt)
%% Choosing DTW or Gaussain Newton Methods to do alignment task
%% choose 1 for DTW and 2 for GN methods
%   return the temporal alignment result for ali
%   Copyright@Nieliquan 2016/5/9
if opt.choose == 1
    ali = dtw(Xs);
elseif opt.choose == 2
    ali = dtw(Xs, [], []);
else
    error('unsuppoted temporal alignment methods');
end
end