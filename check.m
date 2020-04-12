%%
files = dir;
slaeFiles = cell(0, 1);
for i = 1 : size(files)
    if contains(files(i).name, 'slae') && contains(files(i).name, '.mat')
        slaeFiles{end + 1, 1} = i;
    end
end

bias = cell(size(slaeFiles, 1), 2);
tec = cell(size(slaeFiles, 1), 2);

for i = 1 : size(bias, 1)
    load(files(slaeFiles{i}).name, 'x');
    bias{i, 1} = files(slaeFiles{i}).name(6 : 9);
    bias{i, 2} = x(end - 31 : end);
    bias{i, 2} = bias{i, 2} - mean(bias{i, 2});
    
    tec{i, 1} = files(slaeFiles{i}).name(6 : 9);
    tec{i, 2} = zeros((size(x, 1) - 32) / 7, 1);
    for k = 1 : size(tec{i, 2}, 1)
        tec{i, 2}(k) = x((k - 1) * 7 + 1);
    end
    clear 'x';
end

%%
figure;
hold on;
for i = 1 : size(bias, 1)
    plot(bias{i, 2});
end
title('BIAS');
legend(bias{:, 1});

%%
figure;
hold on;
for i = 1 : size(tec, 1)
    plot(tec{i, 2});
end
title('TEC');
legend(tec{:, 1});