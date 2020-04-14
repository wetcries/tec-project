%%
figure;
hold on;
for i = 1 : 1
    if isempty(TEC_cell{i})
        continue;
    end
    
    for k = 1 : size(intervals{i}, 1)
        start = intervals{i}(k, 1);
        eend = intervals{i}(k, 2);
        plot(TEC_cell{i}(start : eend, 1),...
            TEC_cell{i}(start : eend, 8));
    end
end