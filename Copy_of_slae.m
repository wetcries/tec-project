% equations
function Copy_of_slae(file, alpha)
load(file, 'TEC_cell', 'base_position');
tic
time_offset = false;
min_time = zeros(32, 1);
for i = 1 : 32 
    if isempty(TEC_cell{i})
        continue;
    end
    if TEC_cell{i}(1,1) < 0
        time_offset = true;
        min_time(i) = TEC_cell{i}(1,1);
    end
end

if time_offset
    offset = abs(min(min_time));
else
    offset = 0;
end

array_size = 0;
for i = 1 : 32
    if isempty(TEC_cell{i})
        continue;
    end
    
    array_size = array_size + size(TEC_cell{i}, 1);
end

period = 600; % period of time, when tec doesn't change 
A = zeros(array_size, 32 + 7 * 86400 / period);
y = zeros(array_size, 1);
counter = 0;
nop = 86400 / period; %nop - number of periods

coef = 6371 / (6371 + 450);
base_lla = ecef2lla(base_position);

for i = 1 : 32
    if isempty(TEC_cell{i})
        continue;
    end
    
    for k = 1 : size(TEC_cell{i}, 1)
        counter = counter + 1;
        time = TEC_cell{i}(k, 1) + offset;
        
        % index of time period 
        index = int64(floor(time / period)) + 1;
        
        tetha = TEC_cell{i}(k, 2);
        S = 1/(cos(asin(coef*sin(alpha*(pi/2 - tetha)))));
        lat = TEC_cell{i}(k, 3);
        lon = TEC_cell{i}(k, 4);

        A(counter, 1 + (index - 1) * 7) = S;
        A(counter, 2 + (index - 1) * 7) = S * (lat - base_lla(1));
        A(counter, 3 + (index - 1) * 7) = S * (lat - base_lla(1))^2;
        A(counter, 4 + (index - 1) * 7) = S * (lon - base_lla(2));
        A(counter, 5 + (index - 1) * 7) = S * (lon - base_lla(2))^2;
        
        delta_t = (time - (double(index) - 0.5) * period);
        A(counter, 6 + (index - 1) * 7) = S * delta_t;
        
        A(counter, 7 + (index - 1) * 7) = S * delta_t ^ 2;
        A(counter, end + i - 32) = 1;

        y(counter) = TEC_cell{i}(k, 8);
        
    end
    fprintf('completed for %i satellite\n', i);
end
S = sparse(A);
toc
fprintf('completed: alpha = %d\n', alpha);
save(['slae_', num2str(alpha), '.mat'], 'S', 'y');


        