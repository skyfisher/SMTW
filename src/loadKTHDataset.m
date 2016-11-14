function [sequence, gnd_label] = loadKTHDataset(pathName)
%% Load KTH action recognition dataset
% pathName  :  dataset path name
% sequenes  :  image sequences of the videos
% gnd_label :  ground-truth label of the videos
% Copyright @ Nieliquan 2015/11/14
% Last Modified: 
if exist('KTH_dataset.mat', 'file')
    load KTH_dataset.mat;
    return;
end

sequences       = {};
gnd_label       = [];
actionPathNames = dir(pathName);
count           = 1;
seqVideo        = [];

% Action path Layer
for i=1:length(actionPathNames)
    actionName = actionPathNames(i).name;
    if strcmp(actionName, '..') || strcmp(actionName , '.')
        continue;
    end
    
    % Action folder Layer
    tmpName = [pathName, '\',actionName];
    subFolderNames = dir(tmpName);
    for ii = 1 : length(subFolderNames)
        subFolerName = subFolderNames(ii).name;
        if strcmp(subFolerName, '..') || strcmp(subFolerName , '.')
            continue;
        end
        
        % Action video file Layer
        fileNames = dir([pathName, '\', actionName, '\', subFolerName]);
        for iii = 1 : length(fileNames)
            fprintf([actionName,':', subFolerName,':' num2str(iii),'\n']);
            fileName = fileNames(iii).name;
            if strcmp(fileName, '..') || strcmp(fileName , '.')
                continue;
            end
            
            % Action image file Layer
            fileName = [pathName, '\', actionName, '\', subFolerName, '\', fileName];

            image = imread(fileName);
            imshow(image);
            
            seqVideo = [seqVideo, double(image(:))];
        end
        
        % Do Pca dimension reduction to Keep 0.95 energy
        option.ReducedDim = 10;
        seq = PCA(seqVideo, option);
        gnd_label = [gnd_label, i-2];
        sequence{count} = seq';
        count = count + 1;
        seqVideo = [];
    end
end

end