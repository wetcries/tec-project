bias_nasa = zeros(32, 1);
for i = 1 : 32
    bias_nasa(i) = bias_cell{i}{1, 3} * 2.86;
end

bias = x(end - 31: end);
bias = bias - mean(bias);
%%
figure;
hold on;
plot(bias_nasa);
plot(bias);
legend('nasa', 'calc');

%%
tec = zeros(576, 1);
counter = 0;
for i = 1 : 7 : 4032
    counter = counter + 1;
    tec(counter) = x(i);
end
plot(tec);
%%
counter = 0;
period = 150;
for i = 1 : 1
    if isempty(TEC_cell{i})
        continue
    end
    
    for k = 1 : size(TEC_cell{i}, 1)
        time = TEC_cell{i}(k, 1);
        
        index = int64(floor(time / period)) + 1;
        delta_t = (time - (double(index) - 0.5) * period);
        
        if abs(delta_t) < 21
            counter = counter + 1;
        end
    end
    fprintf('sat %i\n', i);
end

