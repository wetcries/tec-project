%% read from rinex
files = dir('C:\Users\meDaddy\Documents\MATLAB\sopac\');
rinexFiles = cell(0, 1);

for i = 1 : size(files, 1)
    if contains(files(i).name(end), 'o')
        rinexFiles{end + 1, 1} = i;
    end
end

for i = 1 : size(rinexFiles, 1)
    try
    rinexToMat2_1([files(rinexFiles{i}).folder,...
        '\', files(rinexFiles{i}).name]);
    catch
        fprintf('Error: %s\n', files(rinexFiles{i}).name);
    end
end

clear

%% observation data cells
files = dir;
matFiles = cell(0, 1);
for i = 1 : size(files, 1)
    if contains(files(i).name, '.mat')
        matFiles{end + 1, 1} = i;
    end
end

for i = 1 : size(matFiles, 1)
    Copy_of_tec_cells(files(matFiles{i}).name);
end

clear

%% slae
files = dir;
cellFiles = cell(0, 1);
for i = 1 : size(files, 1)
    if contains(files(i).name, 'cells') && contains(files(i).name, '.mat')
        cellFiles{end + 1, 1} = i;
    end
end

for i = 1 : size(cellFiles, 1)
    new_slae(files(cellFiles{i}).name, 0.87);
end

clear

%% solving slae
files = dir;
slaeFiles = cell(0, 1);
for i = 1 : size(files)
    if contains(files(i).name, 'slae') && contains(files(i).name, '.mat')
        slaeFiles{end + 1, 1} = i;
    end
end

for i = 1 : size(slaeFiles, 1)
    roots(files(slaeFiles{i}).name);
end

clear