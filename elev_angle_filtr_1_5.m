for i = 1 : 32
    if isempty(TEC_cell{i})
        continue;
    end
    
    for k = size(TEC_cell{i}, 1) : -1 : 1
        if TEC_cell{i}(k, 2) < pi/6
            TEC_cell{i}(k, :) = [];
        end
    end
end
