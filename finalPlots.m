southStations = {'carg'; 'ibiz'; 'vale'};


flareTime = 0;
for i = 1 : size(southStations, 1)
    load(['tec_', southStations{i}, '.mat']);
    
    flareTimeIndex = 16 * 3600 / period;
    
    flareTime = flareTime +...
        time(find(dtec == max(dtec(flareTimeIndex - round(1800 / period) :...
        flareTimeIndex + round(1800 / period)))));
    
end

flareTime = flareTime / size(southStations, 1) * 3600;
clearvars -except flareTime

%%
% stations = {'rio1'; 'zara'; 'pasa'; 'esco';...
%     'lliv'; 'axpv'; 'mops';...
%     'zada'; 'dent'; 'ware'; 'crei';...
%     'vale'; 'ibiz'; 'carg'};

load('allStation.mat', 'allStations');
stations = allStations;

dtecPoints = zeros(size(stations, 1), 1);
elevPoints = zeros(size(stations, 1), 1);

for i = 1 : size(stations, 1)
    load(['tec_', stations{i}, '.mat']);
    
    figure;
    plot(time(1 : end - 1), dtec);
    xlim([15, 17]);
    title(stations{i});
    flareTimeIndex = round(flareTime / period); 
    dtecPoints(i) = max(dtec(flareTimeIndex - 10 : flareTimeIndex + 10));
    elevPoints(i) = sunElevation(flareTimeIndex);
end

figure;
scatter(elevPoints, dtecPoints, 'filled');
grid on;
title('Зависимость dTECU/dt от угла элевации Солнца', 'FontSize', 14);
xlabel('Угол элевации в градусах', 'FontSize', 14);
ylabel('dTECU/dt', 'FontSize', 14);
text(elevPoints, dtecPoints + 1e-3, stations, 'FontSize', 12);
clearvars -except flareTime
%%
lonStations = {'rio1'; 'zara'; 'esco'; 'lliv'; 'axpv'; 'mops'; 'zada'};
latStations = {'dent'; 'crei'; 'esco'; 'zara'; 'vale'; 'ibiz'; 'carg'};

dtecLonPoints = zeros(size(lonStations, 1), 1);
lonPoints = zeros(size(lonStations, 1), 1);
for i = 1 : size(lonStations, 1)
    load(['tec_', lonStations{i}, '.mat']);
    
    flareTimeIndex = round(flareTime / period); 
    dtecLonPoints(i) = max(dtec(flareTimeIndex - 10 : flareTimeIndex + 10));
    lonPoints(i) = lla(1);
end

dtecLatPoints = zeros(size(latStations, 1), 1); 
latPoints = zeros(size(latStations, 1), 1);
for i = 1 : size(latStations, 1)
    load(['tec_', latStations{i}, '.mat']);
    
    flareTimeIndex = round(flareTime / period); 
    dtecLatPoints(i) = max(dtec(flareTimeIndex - 10 : flareTimeIndex + 10));
    latPoints(i) = lla(1);
end

figure;
scatter(lonPoints, dtecLonPoints, 'filled');
grid on;
title('Зависимость dTECU/dt от координаты долготы', 'FontSize', 14);
text(lonPoints + 0.05, dtecLonPoints, lonStations, 'FontSize', 12);
ylabel('dTEC/dt', 'FontSize', 14);
xlabel('Долгота в градусах', 'FontSize', 14);

figure;
scatter(latPoints, dtecLatPoints, 'filled');
grid on;
text(latPoints + 0.25, dtecLatPoints, latStations, 'FontSize', 12);
title('Зависимость dTECU/dt от координаты широты', 'FontSize', 14);
ylabel('dTECU/dt', 'FontSize', 14);
xlabel('Широта в градусах', 'FontSize', 14);
