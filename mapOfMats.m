lats = zeros(size(stations));
lons = zeros(size(stations));

figure;

for i = 1 : size(stations, 1)
    load([stations{i}, '2530.mat'], 'Position_X', 'Position_Y', 'Position_Z');
    lla = ecef2lla([Position_X, Position_Y, Position_Z], 'WGS84');
    lats(i) = lla(1);
    lons(i) = lla(2);
end

geoscatter(lats, lons);
names = cell2mat(stations);

text(lats + 0.1, lons + 0.1, stations);