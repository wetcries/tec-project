% equations
function slae(file, alpha)
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
        ion_position = [TEC_cell{i}(k, 3),...
            TEC_cell{i}(k, 4),...
            TEC_cell{i}(k, 5)];
        delta = ecef2lla(ion_position) - ecef2lla(base_position);

        A(counter, 1 + (index - 1) * 7) = S;
        A(counter, 2 + (index - 1) * 7) = S * delta(1);
        A(counter, 3 + (index - 1) * 7) = S * delta(1)^2;
        A(counter, 4 + (index - 1) * 7) = S * delta(2);
        A(counter, 5 + (index - 1) * 7) = S * delta(2)^2;
        A(counter, 6 + (index - 1) * 7) =...
            S * (time - (index - 0.5) * period);
        A(counter, 7 + (index - 1) * 7) =...
            S * (time - (index - 0.5) * period)^2;
        A(counter, end + i - 32) = 1;

        y(counter) = TEC_cell{i}(k, 8);
    end
end
S = sparse(A);
toc
fprintf('completed: alpha = %d\n', alpha);
save(['slae_', num2str(alpha), '.mat'], 'S', 'y');


        