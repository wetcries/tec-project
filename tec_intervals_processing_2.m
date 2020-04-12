%search for observ intervals

load('cells.mat');
%check time is about time between intervals
check_time = 100;

%intervals cell contains indexes of intervals
intervals = cell(32, 1);
for i = 1 : 32
    if isempty(TEC_cell{i})
        continue;
    end
    intervals{i} = zeros(100, 2);
    intervals{i}(:,:) = NaN;
end

counter = zeros(32, 1);

for i = 1 : 32
    if isempty(TEC_cell{i})
        continue;
    end
    counter(i) = counter(i) + 1;
    intervals{i}(1, 1) = 1; 
end

for i = 1 : 32
    if isempty(TEC_cell{i})
        continue;
    end
   for k = 2 : size(TEC_cell{i}, 1)
        if TEC_cell{i}(k, 1) - TEC_cell{i}(k - 1, 1) < check_time
            intervals{i}(counter(i), 2) = k;            
        else
            counter(i) = counter(i) + 1;
            intervals{i}(counter(i), 1) = k;
        end
   end
end

for i = 1 : 32
    if isempty(TEC_cell{i})
        continue;
    end
    intervals{i}(counter(i) + 1: end, :) = [];
    for k = size(intervals{i}, 1) : -1 : 1
        if sum(isnan(intervals{i}(k, :)), 2) ~= 0
            intervals{i}(k, :) = [];
        end
    end
end
