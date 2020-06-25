%%
base = 'dent';

load(['tec_', base, '.mat']);

figure;
hold on;

plot(time, tec);
errorbar(mtime, mtec, etec);

grid on;
title('Изменение величины TEC за сутки', 'FontSize', 14);
ylabel('TECU ', 'FontSize', 14);
xlabel('Время UTC', 'FontSize', 14);
xlim([0, 24]);
xticks(0 : 24);

legend('Полученное значение TEC для станции dent', 'Данные MADRIGAL',...
    'FontSize', 12, 'Location', 'southeast');
printpreview;
print('pics/tec_madrigal', '-dpng', '-r600');

%%
figure;
hold on;
grid on;
title('Изменение велечины TEC и угла элевации Солнца за сутки',...
    'FontSize', 14);

yyaxis left;
plot(time, tec);
ylabel('TECU', 'FontSize', 14);


yyaxis right;
plot(time, sunElevation);
ylabel('Угол элевации в градусах', 'FontSize', 14);

xlabel('Время UTC', 'FontSize', 14);
xlim([0, 24]);
xticks(0 : 24);
printpreview;
print('pics/tec_sun', '-dpng', '-r600');

%%
