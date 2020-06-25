stations = {'rio1'; 'zara'; 'case'; 'esco';...
    'lliv'; 'axpv'; 'prat'; 'mops';...
    'zada'; 'dent'; 'ware'; 'crei';...
    'vale'; 'ibiz'; 'carg'};
% load('allStation.mat');
% stations = allStations;
% load('dtecSizeForMap.mat');

ll = zeros(size(stations, 1), 2);

%%
% figure;
% for i = 1 : size(stations, 1)
%     load(['tec_', stations{i}, '.mat']);
%     ll(i, 1) = lla(1);
%     ll(i, 2) = lla(2);
% %     subplot(3, 5, i);
% %     hold on;
% %     grid on;
% %     plot(time, tec);
% %     errorbar(mtime, mtec, etec);  
% %     title(stations{i});
% end


figure;
for i = 1 : size(stations, 1)
    load(['tec_', stations{i}, '.mat']);
    ll(i, 1) = lla(1);
    ll(i, 2) = lla(2);
    
    subplot(3, 5, i);
    plot(time(1 : end - 1), dtec);  
    title({['Станция: ', stations{i}],...
        ['Угол возв. Солнца: ',...
        num2str(sunElevation(round(16 * 3600 / period)), '%.2f')],...
        ['Положение: ', num2str(lla(1), '%.2f'), ', ', num2str(lla(2), '%.2f')]});
    xlabel('Время UTC, часы');
    ylabel('dTEC/dt');
    xlim([15.5, 16.5]);
    ylim([-0.005, 0.03]);
    grid on;
end
printpreview;
print('pics/dtec15', '-dpng');

%%
% figure;
% geoscatter(ll(: , 1), ll(: , 2), dtecPoints * 10000, 'r', 'filled');
% % title('Зависимость производной dTEC/dt во время вспышки от расположения станции',...
% %     'FontSize', 14);

figure;
geoscatter(ll(: , 1), ll(: , 2), 10, 'r', 'filled');
% title('Выбранные станции',...
%     'FontSize', 14);
text(ll(:,1) + 0.2, ll(:,2) + 0.2, stations, 'FontSize', 14);
title('Выбранные станции');

printpreview;
print('pics/stations_pres', '-dpng', '-r600');

clear
