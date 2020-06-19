file = 'kos12490.mat';
load(['slae_2_', file]);
load(file, 'year', 'month', 'day');
load(['cell_', file], 'base_position');
tec0 = x(1 : mode * 3 + 1 :end - 32);
timeDerivative = x(4 : mode * 3 + 1 : end - 32);
time0 = period : period : 86400 - period;

sunElevation = zeros(size(time0, 2), 1);
lla = ecef2lla(base_position, 'WGS84');
UTC = cell(numel(sunElevation), 1);

for i = 1 : numel(sunElevation)
    hour = floor(time0(i) / 3600);
    minute = floor((time0(i) - hour * 3600) / 60);
    second = time0(i) - hour * 3600 - minute * 60;
    dataNumber = datenum([year, month, day, hour, minute, second]);
    UTC{i} = datestr(dataNumber,'yyyy/mm/dd HH:MM:SS');
    [~, sunElevation(i)] = SolarAzEl(UTC{i}, lla(1), lla(2), lla(3));
end


time0 = period : period : 86400 - period;
time0 = time0 / 3600;
date = datestr(datenum([year, month, day]), 'mmmm-dd-yyyy');
figure(1);
grid on;

yyaxis left;
plot(time0, tec0);
title({'TEC and Solar elevation angle during the day',...
    ['(', date, ', location: ', num2str(lla(1)), ', ',num2str(lla(2)), ')']});
xlabel('UTC time, hours');
ylabel('TECU');
xlim([0, 24]);
xticks(0:24);

yyaxis right;
plot(time0, sunElevation);
ylabel('Elevation angle, degrees');


figure(2);
hold on;
yyaxis left;
plot(time0, timeDerivative);
xlim([0, 24]);
xticks(0 : 24);

yyaxis right;
plot(time0, tec0);

clear

