% stations = {'rio1'; 'zara'; 'pasa'; 'esco';...
%     'lliv'; 'axpv'; 'prat'; 'mops';...
%     'zada'; 'dent'; 'ware'; 'crei';...
%     'vale'; 'ibiz'; 'carg'};

stations = allStations;

ll = zeros(size(stations, 1), 2);



%%
figure;
for i = 1 : size(stations, 1)
    load(['tec_', stations{i}, '.mat']);
    ll(i, 1) = lla(1);
    ll(i, 2) = lla(2);
%     subplot(3, 5, i);
%     hold on;
%     grid on;
%     plot(time, tec);
%     errorbar(mtime, mtec, etec);  
%     title(stations{i});
end

figure;
for i = 1 : size(stations, 1)
    load(['tec_', stations{i}, '.mat']);
    ll(i, 1) = lla(1);
    ll(i, 2) = lla(2);
    
%     subplot(3, 5, i);
%     plot(time(1 : end - 1), dtec);  
%     title({['Станция: ', stations{i}],...
%         ['Угол элевации Солнца: ',...
%         num2str(sunElevation(round(16 * 3600 / period)))]});
%     xlabel('Время UTC, часы');
%     ylabel('dTEC/dt');
%     xlim([15.5, 16.5]);
%     ylim([-0.005, 0.03]);
%     grid on;
end


figure;

geoscatter(ll(: , 1), ll(: , 2), 'filled');
title('Расположение выбранных станций', 'FontSize', 14);
text(ll(:,1) + 0.15, ll(:,2) + 0.15, stations, 'FontSize', 14);
clear
