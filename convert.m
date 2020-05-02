stec = zeros(86400, 32);
Elev = zeros(86400, 32);
stec(:, :) = NaN;
Elev(:, :) = NaN;

for i = 1 : 32
    if isnan(TEC_cell{i})
        continue
    end
    
    for k = 1 : size(TEC_cell{i}, 1)
        time = TEC_cell{i}(k, 1);
        tec = TEC_cell{i}(k, 8);
        angle = TEC_cell{i}(k, 2) * 180 / pi;
        
        stec(time + 1, i) = tec;
        Elev(time + 1, i) = angle;
    end
end

clear time tec angle i k