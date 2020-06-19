

tec = x(1 : mode * 3 + 1 :end - 32);
time = period : period : 86400 - period;

lla = ecef2lla(base_position, 'WGS84');
rlla = round(lla);



sunElevation = zeros(size(time, 2), 1);
UTC = cell(numel(sunElevation), 1);
for i = 1 : numel(sunElevation)
    hour = floor(time(i) / 3600);
    minute = floor((time(i) - hour * 3600) / 60);
    second = time(i) - hour * 3600 - minute * 60;
    dataNumber = datenum([year, month, day, hour, minute, second]);
    UTC{i} = datestr(dataNumber,'yyyy/mm/dd HH:MM:SS');
    [~, sunElevation(i)] = SolarAzEl(UTC{i}, lla(1), lla(2), lla(3));
end

time = time / 3600;
dtec = diff(tec) / period; 

figure;
hold on;
yyaxis left;
plot(time, tec, 'blue');

yyaxis right;
plot(time, sunElevation);
  

%%
F = TEC_cell{22}(:, 6);
P = TEC_cell{22}(:, 7);
V = TEC_cell{22}(:, 8);
T = TEC_cell{22}(:, 1);
T = T / 3600;
bias = x(end - 32 + 22);
F = F - bias;
P = P - bias;
V = V - bias;
figure;
hold on;
plot(T, F, 'k');
plot(T, P, 'r');
plot(T, V, 'b');
grid on;
legend('фазовые измерения', 'кодовые измерения',...
    'устранение фазовой неоднозначности');
xlabel('Время UTC');
ylabel('TECU');

