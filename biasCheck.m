bias_nasa = zeros(32, 1);

for i = 1 : size(bias_cell, 1)
    for k = 1 : size(bias_cell{i}, 1)
        if contains(bias_cell{i, 1}(k, 1), 'C1C') &&...
                contains(bias_cell{i, 1}(k, 2), 'C1W')
            bias_nasa(i) = cell2mat(bias_cell{i, 1}(k, 3));
        end
    end
end
bias_nasa = (bias_nasa - mean(bias_nasa)) * 2.86;
bias = x(end - 31 : end);
bias = bias - mean(bias);

figure;
hold on;
plot(bias);
plot(bias_nasa);
