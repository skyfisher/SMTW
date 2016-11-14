function [ bigImage ] = convertImageSequence(images, width, height)
%% show image sequences each image 1D vector
len = size(images, 2);
bigImage = [];
for i = 1 : len
    image = reshape(images(:, i), width, height);
    bigImage = [bigImage, image];
end

end