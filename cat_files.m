files = dir('mat_files');
load([files(3).folder, '\', files(3).name], 'Matr_GPS', 'Param_GPS',...
    'Position_X', 'Position_Y', 'Position_Z');

ObservationDataGPS = [];
ObservationDataGPS = [ObservationDataGPS; Matr_GPS];
clear 'Matr_GPS';
for i = 4 : size(files, 1)
    load([files(i).folder, '\', files(i).name], 'Matr_GPS');
    ObservationDataGPS = [ObservationDataGPS; Matr_GPS];
    clear 'Matr_GPS'
end

ObservTypes = cell(0, 1);
for i = 9 : 3 : size(Param_GPS)
    ObservTypes{end + 1, 1} = Param_GPS{i};
end

save('test_2.mat', 'ObservationDataGPS', 'ObservTypes',...
    'Position_X', 'Position_Y', 'Position_Z');
clear

