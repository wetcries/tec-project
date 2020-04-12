% calculation of measured tec value

for i = 1 : 32
    if isempty(TEC_cell{i})
        continue;
    end
    
    for k = 1 : size(intervals{i}, 1)
        const = 0;
        
        for n = intervals{i}(k, 1) : intervals{i}(k, 2)
            const = const + (TEC_cell{i}(n, 7) - TEC_cell{i}(n, 6));
        end
        const = const / (intervals{i}(k, 2) - intervals{i}(k, 1) + 1);
        
        for n = intervals{i}(k, 1) : intervals{i}(k, 2)
            TEC_cell{i}(n, 8) = TEC_cell{i}(n, 6) + const;
        end
        
    end
end
