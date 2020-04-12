% processing of tec from DATA mat file

load('test_2.mat', 'ObservationDataGPS', 'ObservTypes', 'Position_X',...
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

index_L1 = find(strcmp(ObservTypes, 'L1C'));
index_L2 = find(strcmp(ObservTypes, 'L2W'));
index_C1 = find(strcmp(ObservTypes, 'C1C'));
index_C2 = find(strcmp(ObservTypes, 'C2W'));

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
    tec_f = coef * (OD(i, 9 + 3*(index_L1 - 1))...
        * waveLength1 - OD(i, 9 + 3*(index_L2 - 1)) * waveLength2) / 1E16;
    tec_p = coef * (OD(i, 9 + 3*(index_C1 - 1))...
        - OD(i, 9 + 3*(index_C2 - 1))) / 1E16;
    
    if isnan(tec_f + tec_p)
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
    
    %elev angle and ion_point
    sat_position = [OD(i, 3), OD(i, 4), OD(i, 5)];
    r = sat_position - base_position;
    n = base_position;
    r_len = sqrt(sum(r.^2));
    n_len = sqrt(sum(n.^2));
    elev_angle = asin((r(1) * n(1) + r(2) * n(2) + r(3) * n(3)) /...
        r_len / n_len);
    
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

save('cells.mat', 'TEC_cell', 'TEC_cell_Description', 'base_position');
clear




