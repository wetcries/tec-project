folder = 'C:\Users\meDaddy\Documents\MATLAB\tec-project';


% files = dir([folder, '\slae']);
% slaeFiles = cell(0, 1);
% slaeStations = cell(0, 1);
% 
% for i = 1 : size(files, 1)
%     if contains(files(i).name, 'slae_')
%         slaeStations{end + 1, 1} = files(i).name(8 : end - 8);
%     end
% end

slaeStations = {'rio1'; 'zara'; 'pasa'; 'esco';...
    'lliv'; 'axpv'; 'prat'; 'mops';...
    'zada'; 'dent'; 'ware'; 'crei';...
    'vale'; 'ibiz'; 'carg'};


lats = zeros(size(slaeStations));
lons = zeros(size(slaeStations));

figure;

for i = 1 : size(slaeStations, 1)
    load([folder, '\mat\',...
        slaeStations{i}, '2530.mat'],...
        'Position_X', 'Position_Y', 'Position_Z');
    lla = ecef2lla([Position_X, Position_Y, Position_Z], 'WGS84');
    lats(i) = lla(1);
    lons(i) = lla(2);
end

geoscatter(lats, lons);
names = cell2mat(slaeStations);
text(lats + 0.1, lons + 0.1, slaeStations);
