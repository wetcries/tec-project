figure
hold on
for i = 1 : 32
    if isempty(TEC_cell{i})
        continue;
    end
    for k = 1 : size(intervals{i}, 1)
        plot(TEC_cell{i}(intervals{i}(k, 1) : intervals{i}(k, 2), 1),...
            TEC_cell{i}(intervals{i}(k, 1) : intervals{i}(k, 2), 8));
    end
end