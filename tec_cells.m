% processing of tec from DATA mat file
function tec_cells(file)
%%

load(file, 'ObservationDataGPS', 'ObservTypes', 'Position_X',...
    'Position_Y', 'Position_Z');
base_position = [Position_X, Position_Y, Position_Z];
OD = ObservationDataGPS;
%check for time offset
start_of_observation = OD(1, 1);
end_of_observation = OD(end, 1);
time_offset = false;
start_of_the_day = false;
if end_of_observation - start_of_observation < 0
    time_offset = true;
end
%----------

c = 299792458;
freq1 = 1575.42E6;
freq2 = 1227.60E6;
waveLength1 = c / pi / freq1;
waveLength2 = c / pi / freq2;
coef = 1 / 40.308 * freq1^2 * freq2^2 / (freq1^2 - freq2^2);


%%
indexes_L1 = cell(0, 1);
indexes_L2 = cell(0, 1);
indexes_C1 = cell(0, 1);
indexes_C2 = cell(0, 1);


for i = 1 : size(ObservTypes, 1)
    if contains(ObservTypes{i}, 'L1')
        indexes_L1{end + 1, 1} = i;
    end
    
    if contains(ObservTypes{i}, 'L2')
        indexes_L2{end + 1, 1} = i;
    end
    
    if contains(ObservTypes{i}, 'C1C')
        indexes_C1{end + 1, 1} = i;
    end
    
    if contains(ObservTypes{i}, 'C1W')
        indexes_C2{end + 1, 1} = i;
    end
end


%%  
sizeOfData = size(ObservationDataGPS, 1);
TEC_cell = cell(32, 1);
for i = 1 : 32
    TEC_cell{i} = zeros(86400, 8);
    TEC_cell{i}(:, :) = NaN;
end
TEC_cell_Description = {'Time', 'Elev angle', 'IonPointX', 'IonPointY', 'IonPointZ'...
    'TEC F', 'TEC P', 'TEC V'};
counter = zeros(32);

for i = 1 : sizeOfData
%     if OD(i, 9 + 3*(index_L1 - 1)) == 0 ||...
%             OD(i, 9 + 3*(index_L2 - 1)) == 0 ||...
%             OD(i, 9 + 3*(index_C1 - 1)) == 0 ||...
%             OD(i, 9 + 3*(index_C2 - 1)) == 0
%         continue
%     end
    index_L1 = NaN;    
    index_L2 = NaN;
    index_C1 = indexes_C1{1};
    index_C2 = indexes_C2{1};
    
    for k = 1 : size(indexes_L1, 1)
        if OD(i, 9 + 3 * (indexes_L1{k} - 1)) ~= 0 &&...
                ~isnan(OD(i, 9 + 3 * (indexes_L1{k} - 1)))
            index_L1 = indexes_L1{k};
            break
        end
    end
    
    for k = 1 : size(indexes_L2, 1)
        if OD(i, 9 + 3 * (indexes_L2{k} - 1)) ~= 0 &&...
                ~isnan(OD(i, 9 + 3 * (indexes_L2{k} - 1)))
            index_L2 = indexes_L2{k};
            break
        end
    end
    
    if isnan(index_L1) || isnan(index_L2)
        continue
    end


    tec_f = coef * (OD(i, 9 + 3*(index_L1 - 1))...
        * waveLength1 - OD(i, 9 + 3*(index_L2 - 1)) * waveLength2) / 1E16;
    tec_p = coef * (OD(i, 9 + 3*(index_C1 - 1))...
        - OD(i, 9 + 3*(index_C2 - 1))) / 1E16;
    
    if isnan(tec_f + tec_p)
        continue
    end
    %elev angle and ion_point
    sat_position = [OD(i, 3), OD(i, 4), OD(i, 5)];
    r = sat_position - base_position;
    n = base_position;
    r_len = sqrt(sum(r.^2));
    n_len = sqrt(sum(n.^2));
    elev_angle = asin((r(1) * n(1) + r(2) * n(2) + r(3) * n(3)) /...
        r_len / n_len);
    %to be continued...
    if elev_angle < pi/6 || isnan(elev_angle)
        continue;
    end
    
    %OD(i, 2) - Sat number 
    counter(OD(i, 2)) = counter(OD(i, 2)) + 1;
    %time
    if OD(i, 1) == 0
        start_of_the_day = true;
    end
    
    if start_of_the_day
        TEC_cell{OD(i, 2)}(counter(OD(i, 2)), 1) = OD(i, 1); %OD(i, 1) - moment of time
    else
        TEC_cell{OD(i, 2)}(counter(OD(i, 2)), 1) = OD(i, 1) - 86400;
    end
        
    %tec_f and tec_p
    TEC_cell{OD(i, 2)}(counter(OD(i, 2)), 6) = tec_f;
    TEC_cell{OD(i, 2)}(counter(OD(i, 2)), 7) = tec_p;
    
    
    %elev angle and ion point continue
    a_len = (-2*sin(elev_angle) + sqrt(4 * 6.4^2 * 1E12 *...
        sin(elev_angle)^2 + 4 * (6.85^2 * 1E12 - 6.4^2 * 1E12))) / 2;
    
    a = a_len * r / r_len;
    Ion_point = base_position + a;
    
    TEC_cell{OD(i, 2)}(counter(OD(i, 2)), 2) = elev_angle;
    TEC_cell{OD(i, 2)}(counter(OD(i, 2)), 3) = a(1);
    TEC_cell{OD(i, 2)}(counter(OD(i, 2)), 4) = a(2);
    TEC_cell{OD(i, 2)}(counter(OD(i, 2)), 5) = a(3);    
end

for i = 1 : 32
    TEC_cell{i}(counter(i) + 1 : end, :) = [];
end




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

%% TEC measured
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

save('cells.mat', 'TEC_cell', 'TEC_cell_Description', 'base_position',...
    'intervals');





