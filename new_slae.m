function new_slae(file,alpha)
load(file, 'TEC_cell', 'base_position');

tic;
all_data_size = 0;
period = 150;
window = 51;

for i = 1 : 32
    if isempty(TEC_cell{i})
        continue
    end
    
    for k = 1 : size(TEC_cell{i}, 1)
        time = TEC_cell{i}(k, 1);
        
        index = int64(round(time / period));
        delta_t = (time - double(index) * period);
        
        if abs(delta_t) < (window - 1) / 2
            all_data_size = all_data_size + 1;
        end
    end
end

A = zeros(all_data_size, 32 + 7 * 86400 / period);
y = zeros(all_data_size, 1);
coef = 6371 / (6371 + 450);
base_lla = ecef2lla(base_position);
counter = 0;

for i = 1 : 32
    if isempty(TEC_cell{i})
        continue
    end
    
    for k = 1 : size(TEC_cell{i}, 1)
        time = TEC_cell{i}(k, 1);
        index = int64(round(time / period));
        if index == 86400 / period
            continue
        end
        delta_t = (time - double(index)* period);
        
        if abs(delta_t) >= (window - 1) / 2
            continue
        end
        counter = counter + 1;

        tetha = TEC_cell{i}(k, 2);
        S = 1/(cos(asin(coef*sin(alpha*(pi/2 - tetha)))));
        lat = TEC_cell{i}(k, 3);
        lon = TEC_cell{i}(k, 4);
        
        % need to be universal relatively time step
        
        
        A(counter, 1 + (index + 1) * 7) = S;
        A(counter, 2 + (index + 1) * 7) = S * (lat - base_lla(1));
        A(counter, 3 + (index + 1) * 7) = S * (lat - base_lla(1))^2;
        A(counter, 4 + (index + 1) * 7) = S * (lon - base_lla(2));
        A(counter, 5 + (index + 1) * 7) = S * (lon - base_lla(2))^2;
        A(counter, 6 + (index + 1) * 7) = S * delta_t;
        A(counter, 7 + (index + 1) * 7) = S * delta_t ^ 2;
        A(counter, end + i - 32) = 1;       
        y(counter) = TEC_cell{i}(k, 8);
    end
    fprintf('completed for %i satellite\n', i); 
end
S = sparse(A);
toc;
fprintf('completed: alpha = %d\n', alpha);
save(['slae_', file(7:end), '.mat'], 'S', 'y');
