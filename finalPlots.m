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
    
%     figure;
%     hold on;
%     yyaxis left;
%     plot(time(1 : end - 1), dtec);
%     
%     yyaxis right;
%     plot(time, tec);
%     
%     xlim([12, 18]);
%     title(stations{i});
    flareTimeIndex = round(flareTime / period); 
    dtecPoints(i) = max(dtec(flareTimeIndex - 10 : flareTimeIndex + 10));
    elevPoints(i) = sunElevation(flareTimeIndex);
end

save('dtecSizeForMap.mat', 'dtecPoints', 'elevPoints');

A = elevPoints;
B = dtecPoints;

[A, sortIdx] = sort(A, 'ascend');
B = B(sortIdx);
fo = fitoptions('Method', 'NonLinearLeastSquares',...
    'Lower', [0, 0, 0], 'Upper', [inf, inf, inf], 'StartPoint', [1, 1, 0]);
ft = fittype('a * exp(b * x) + c')
myfit = fit(A, B, ft, fo)


figure;
hold on;
% scatter(elevPoints, dtecPoints, 'filled');
p1 = plot(myfit, A, B);
grid on;
% title('Зависимость dTECU/dt от угла элевации Солнца', 'FontSize', 14);
xlabel('Угол элевации в градусах', 'FontSize', 14);
ylabel('dTECU/dt', 'FontSize', 14);
% text(elevPoints, dtecPoints + 1e-3, stations, 'FontSize', 12);
legend([p1(1), p1(2)], 'Значения для выбранных станций',...
    'Приближенная кривая', 'Location', 'northwest');
text(5, 0.015,...
    [num2str(myfit.a, '%.6f') ' * exp(- ' num2str(myfit.b, '%.3f') ' * x)'],...
    'Color', 'red');
printpreview;
print('pics/dtec_elev', '-dpng', '-r600');

clearvars -except flareTime
%%
lonStations = {'rio1'; 'zara'; 'esco'; 'case'; 'elba'; 'prat'; 'aqui';...
    'zada'; 'dub2'; 'duth'; 'cost'};
latStations = {'carg'; 'ibiz'; 'vale'; 'zara'; 'case'; 'esco'; 'smne';...
    'dour'; 'dent'; 'delf'; 'stas'};

% load('allStation.mat', 'allStations');
% latStations = allStations;
% lonStations = allStations;
lllon = zeros(size(lonStations, 1), 2);
lllat = zeros(size(latStations, 1), 2);
elevlon = zeros(size(lonStations, 1), 1);
elevlat = zeros(size(latStations, 1), 1);

dtecLonPoints = zeros(size(lonStations, 1), 1);
lonPoints = zeros(size(lonStations, 1), 1);
for i = 1 : size(lonStations, 1)
    load(['tec_', lonStations{i}, '.mat']);
    
    flareTimeIndex = round(flareTime / period); 
    dtecLonPoints(i) = max(dtec(flareTimeIndex - 10 : flareTimeIndex + 10));
    lonPoints(i) = lla(2);
    lllon(i, :) = lla(1 : 2);
    elevlon(i) = sunElevation(flareTimeIndex);
end

dtecLatPoints = zeros(size(latStations, 1), 1); 
latPoints = zeros(size(latStations, 1), 1);
for i = 1 : size(latStations, 1)
    load(['tec_', latStations{i}, '.mat']);
    
    flareTimeIndex = round(flareTime / period); 
    dtecLatPoints(i) = max(dtec(flareTimeIndex - 10 : flareTimeIndex + 10));
    latPoints(i) = lla(1);
    lllat(i, :) = lla(1 : 2);
    elevlat(i) = sunElevation(flareTimeIndex);
end

figure;

A = lonPoints;
B = dtecLonPoints;

[A, sortIdx] = sort(A, 'ascend');
B = B(sortIdx);
fo = fitoptions('Method', 'NonLinearLeastSquares',...
    'Lower', [0, 0, 0], 'Upper', [inf, inf, inf], 'StartPoint', [1, 1, 0]);
ft = fittype('a * exp(-b * x) + c')
myfit = fit(A, B, ft, fo)

% scatter(lonPoints, dtecLonPoints, 'b', 'filled');
p = plot(myfit, A, B);
grid on;
% title('Зависимость dTECU/dt от координаты долготы', 'FontSize', 14);
text(lonPoints - 2, dtecLonPoints + 0.001, lonStations, 'FontSize', 12);
ylabel('dTEC/dt', 'FontSize', 14);
xlabel('Долгота в градусах', 'FontSize', 14);
xlim([-5, 30]);
legend(p, 'Значения для выбранных станций',...
    'Приближенная кривая');

text(15, 0.01,...
    [num2str(myfit.a, '%.3f') ' * exp(- ' num2str(myfit.b, '%.3f') ' * x)'],...
    'Color', 'red');
printpreview;
print('pics/dtec_lon', '-dpng', '-r600');

figure;

A = latPoints;
B = dtecLatPoints;

[A, sortIdx] = sort(A, 'ascend');
B = B(sortIdx);
fo = fitoptions('Method', 'NonLinearLeastSquares',...
    'Lower', [0, 0, 0], 'Upper', [inf, inf, inf], 'StartPoint', [0, 0, 0]);
ft = fittype('a * exp(-b * x) + c')
myfit = fit(A, B, ft, fo)

% scatter(latPoints, dtecLatPoints, 'filled');
p = plot(myfit, A, B);
grid on;
textax = dtecLatPoints + 0.001;
textax(8) = textax(8) - 0.002;
textax(9) = textax(9) + 0.001;
text(latPoints, textax, latStations, 'FontSize', 12);
ylabel('dTECU/dt', 'FontSize', 14);
xlabel('Широта в градусах', 'FontSize', 14);
legend(p, 'Значения для выбранных станций',...
    'Приближенная кривая');
text(50, 0.01,...
    [num2str(myfit.a, '%.3f') ' * exp(- ' num2str(myfit.b, '%.3f') ' * x)'],...
    'Color', 'red');
printpreview;
print('pics/dtec_lat', '-dpng', '-r600');

%%

figure;
glon = geoscatter(lllon(:, 1), lllon(:, 2), 'b', 'filled');
text(lllon(:, 1) + 0.5, lllon(:, 2) - 0.8, lonStations,...
    'FontSize', 14);
% printpreview;
% print('pics/lonStations', '-dpng', '-r600');


figure;
geoscatter(lllat(:, 1), lllat(:, 2), 'r', 'filled');
text(lllat(:, 1) + 0, lllat(:, 2) + 0.5, latStations,...
    'FontSize', 14);
% printpreview;
% print('pics/latStations', '-dpng', '-r600');
