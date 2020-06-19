files = dir('C:\Users\meDaddy\Documents\MATLAB\253\');
rinexFiles = cell(0, 1);
europe = cell(0, 3);

for i = 1 : size(files, 1)
    if contains(files(i).name(end), 'o')
        rinexFiles{end + 1, 1} = i;
    end
end

for i = 1 : size(rinexFiles, 1)
    path = [files(rinexFiles{i}).folder,...
        '\', files(rinexFiles{i}).name];
    fd = fopen(path);
    while true
        line = fgetl(fd);
        if contains(line, 'RINEX VERSION / TYPE')
            rinexVersion = real(str2doubleq(line(1:9)))
            if rinexVersion > 2.5
                break
            end
        end
        if contains(line, 'APPROX POSITION XYZ')
            Position_X = real(str2doubleq(line(1:14)));
            Position_Y = real(str2doubleq(line(15:28)));
            Position_Z = real(str2doubleq(line(29:42)));
            break
        else
            continue        
        end
    end   
    fclose('all');
    
    lla = ecef2lla([Position_X, Position_Y, Position_Z], 'WGS84');
    
%     if lla(1) > 35 && lla(1) < 70 && lla(2) > -10 && lla(2) < 40
        europe{end + 1, 1} = files(rinexFiles{i}).name;
        europe{end, 2} = lla(1);
        europe{end, 3} = lla(2);        
%     end
end

% clearvars -except europe
%%
lats = cell2mat(europe(:, 2));
lons = cell2mat(europe(:, 3));
names = cell2mat(europe(:, 1));

geoscatter(lats, lons);
% text(lats + 0.2, lons + 0.2, names);

%%
folder = 'C:\Users\meDaddy\Documents\MATLAB\253\';
counter = 0;
for i = 1 : size(europe, 1)
    try
    rinexToMat2_1([folder, europe{i, 1}]);
    catch
        counter = counter + 1;
        fprintf('Error: %d %s\n', counter, europe{i, 1});
    end
end