folder = 'C:\Users\meDaddy\Documents\MATLAB\tec-project';
%%
files = dir([folder, '\mat']);
stations = cell(0, 1);

for i = 1 : size(files, 1)
    if contains(files(i).name, '.mat') && ~contains(files(i).name, 'cell_') && ~contains(files(i).name, 'slae_')
        stations{end + 1, 1} = files(i).name(1 : 4);
    end
end

%%

for i = 1 : size(stations, 1)
    tec_cells([folder, '\mat\', stations{i}, '2530.mat'])
end

%%
for i = 1 : size(stations, 1)
    slae([folder, '\cell\','cell_', stations{i}, '2530.mat'], 0, 400, 150, 0.87);
end

%%
% stations = {'rio1'; 'zara'; 'pasa'; 'bell'; 'esco';...
%     'lliv'; 'creu'; 'case'; 'axpv'; 'prat'; 'mops';...
%     'como'; 'zada'; 'delf'; 'dent'; 'ware'; 'crei';...
%     'man2'; 'ildx'; 'vale'; 'ibiz'; 'carg'};

% stations = {'rio1'; 'zara'; 'pasa'; 'esco';...
%     'lliv'; 'axpv'; 'prat'; 'mops';...
%     'zada'; 'dent'; 'ware'; 'crei';...
%     'vale'; 'ibiz'; 'carg'};

% for i = 1 : size(stations, 1)
%     slae([folder, '\cell\','cell_', stations{i}, '2530.mat'],...
%         0, 60, 30, 0.87);
% end

allStations = cell(0, 1);
bullshit = {'tuc2'; 'man2'; 'igeo';...
    'bell'; 'axpv'};

for k = 1 : size(stations, 1)
    name = stations{k};
    if sum(contains(bullshit, name))
        continue;
    end
    
    file = [name, '2530.mat'];
    try
        load([folder, '\slae\', 'slae_0_', file]);
    catch
        fprintf('No such file: %s\n', file);
        continue;
    end
        
    if isempty(S)
        continue
    end
    load([folder, '\mat\', file], 'year', 'month', 'day');
    load([folder, '\cell\', 'cell_', file], 'base_position');
    tec = x(1 : mode * 3 + 1 :end - 32);
    time = period : period : 86400 - period;
    
%     lla = ecef2lla(base_position, 'WGS84');
%     rlla = round(lla);
%     mtime = 0.25 : 0.25 : 24 - 0.25;
%     mtec = M_tec(1:end-1, 91 + rlla(1), 181 + rlla(2));
%     etec = M_dtec(1:end-1, 91 + rlla(1), 181 + rlla(2)); 
%     mtec = mtec + (mean(tec) - mean(mtec));
%     
%     
%     sunElevation = zeros(size(time, 2), 1);
%     UTC = cell(numel(sunElevation), 1);
%     for i = 1 : numel(sunElevation)
%         hour = floor(time(i) / 3600);
%         minute = floor((time(i) - hour * 3600) / 60);
%         second = time(i) - hour * 3600 - minute * 60;
%         dataNumber = datenum([year, month, day, hour, minute, second]);
%         UTC{i} = datestr(dataNumber,'yyyy/mm/dd HH:MM:SS');
%         [~, sunElevation(i)] = SolarAzEl(UTC{i}, lla(1), lla(2), lla(3));
%     end
    
    time = time / 3600;
    dtec = diff(tec) / period; 

%     subplot(3, 5, k);   
%     figure;
%     hold on;
%     plot(time, tec, 'blue');
%     errorbar(mtime, mtec, etec, 'red');
%     plot(time, sunElevation);
%     plot(time(1 : end - 1), dtec);
%     title([stations{k}]);
%     xlim([14.5, 17.5]);
%     ylim([-3e-3, 12e-3])
%     yyaxis right;
%     plot(time(1 : end - 1), dtec);
%     save(['tec_', stations{k}], 'tec', 'dtec', 'time', 'sunElevation',...
%         'mtec', 'etec', 'lla', 'period', 'mtime');

    allStations{end + 1, 1} = stations{k};

end
clearvars -except allStations