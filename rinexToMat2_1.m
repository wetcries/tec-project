function rinexToMat2_1(path)
% fd = fopen('C:\Users\meDaddy\Documents\MATLAB\rinex_files\gais269v00.19o', 'r');

% commented GLO SECTION
fd = fopen(path, 'r');
leapSeconds = 16;
fs = 30;
while true
   line = fgetl(fd);
   if contains(line, 'END OF HEADER')
       break;
   end
   if contains(line, 'MARKER NAME')
       markerName = line(1:60);
   end
   if contains(line, 'RINEX VERSION / TYPE')
       rinexVersion = real(str2doubleq(line(1:9)));
   end
   if contains(line, 'APPROX POSITION XYZ')
       Position_X = real(str2doubleq(line(1:14)));
       Position_Y = real(str2doubleq(line(15:28)));
       Position_Z = real(str2doubleq(line(29:42)));
   end
   if contains(line, 'INTERVAL')
       fs = real(str2doubleq(line(1:10)));
   end
   if contains(line, 'TIME OF FIRST OBS')
       yearFirstObs = real(str2doubleq(line(1:6)));
       monthFirstObs = real(str2doubleq(line(7:12)));
       dayFirstObs = real(str2doubleq(line(13:18)));
       hourFirstObs = real(str2doubleq(line(19:24)));
       minuteFirstObs = real(str2doubleq(line(25:30)));
       secondFirstObs = real(str2doubleq(line(31:43)));
       timeSystemFirstObs = line(49:51);
       startTime = datenum([yearFirstObs, monthFirstObs, dayFirstObs,...
           hourFirstObs, minuteFirstObs, secondFirstObs]);
       weekDay = weekday(datestr([yearFirstObs, monthFirstObs,...
           dayFirstObs, 0, 0, 0], 1));
   end
   if contains(line, 'TIME OF LAST OBS')
       yearLastObs = real(str2doubleq(line(1:6)));
       monthLastObs = real(str2doubleq(line(7:12)));
       dayLastObs = real(str2doubleq(line(13:18)));
       hourLastObs = real(str2doubleq(line(19:24)));
       minuteLastObs = real(str2doubleq(line(25:30)));
       secondLastObs = real(str2doubleq(line(31:43)));
       timeSystemLastObs = line(49:51);
       if timeSystemLastObs == timeSystemFirstObs
           clear timeSystemLastObs
       end
       endTime = datenum([yearLastObs, monthLastObs, dayLastObs,...
           hourLastObs, minuteLastObs, secondLastObs]);
   end
   if contains(line, 'LEAP SECONDS')
       leapSeconds = real(str2doubleq(line(1:6)));
   end   
   if contains(line, '# / TYPES OF OBSERV')
       numberOfObservations = real(str2doubleq(line(1:6)));
       if mod(numberOfObservations, 9) ~= 0
           numberOfLines = fix(numberOfObservations / 9) + 1;
       else
           numberOfLines = fix(numberOfObservations / 9);
       end
       ObservTypes = cell(numberOfObservations, 1);
       for lineNumber = 1 : numberOfLines
           for i = 1 : 9
               if (i + (lineNumber - 1) * 9) > numberOfObservations
                   break;
               end
               ObservTypes{i + (lineNumber - 1) * 9} =...
                   line(11 + 6*(i - 1):12 + 6*(i - 1));
           end
           if lineNumber ~= numberOfLines
                   line = fgetl(fd);
           end
       end
   end      
end
% выделение памяти под измерения
ObservationDataGPS = zeros(20 * 86400 / fs, 8 + 3 * numberOfObservations);
% ObservationDataGLO = zeros(20 * 86400 / fs, 8 + 3 * numberOfObservations);
% ObservationDataGAL = zeros(20 * 86400 / fs, 8 + 3 * numberOfObservations);
EphemerisGPS = GPS_ephemeris([path(1:end-1) 'n']);
% EphemerisGLO = GLO_ephemeris2_1([path(1:end-1) 'g']);

iteratorGPS = 0;
% iteratorGLO = 0;
% iteratorGAL = 0;
while ~feof(fd)
   line = fgetl(fd); 
   year = real(str2doubleq(line(2:3)));
   month = real(str2doubleq(line(5:6)));
   day = real(str2doubleq(line(8:9)));
   hour = real(str2doubleq(line(11:12)));
   minute = real(str2doubleq(line(14:15)));
   second = real(str2doubleq(line(16:26)));
   epochFlag = real(str2doubleq(line(29)));
   numberOfSatellites = real(str2doubleq(line(30:32)));
   if length(line) > 68
       clockOffset = real(str2doubleq(line(69:80)));
   else
       clockOffset = nan;
   end
       
   %???
   T0 = datenum(year, month, day, hour, minute, second);
   GPSWeekTime = hour * 3600 + minute * 60 + second +...
       3600 * 24 * (weekDay - 1);
   
   if mod(numberOfSatellites, 12) ~= 0
       numberOfLines = fix(numberOfSatellites / 12) + 1;
   else
       numberOfLines = fix(numberOfSatellites / 12);
   end
   
   PRN = {'PRN'};
   satNum = 1;
   for lineNumber = 1 : numberOfLines
       for i = 1 : 12
           if satNum > numberOfSatellites
               break;
           end
           satNum = satNum + 1;
           PRN{end + 1} = line(33 + (i - 1)*3:35 + (i - 1)*3);
       end
       if lineNumber ~= numberOfLines
           line = fgetl(fd);
       end
   end
   
   if mod(numberOfObservations, 5) ~= 0
       numberOfLines = fix(numberOfObservations/5) + 1;
   else
       numberOfLines = fix(numberOfObservations/5);
   end
   
   line = fgetl(fd);
   for satellite = 1 : numberOfSatellites
       switch PRN{satellite + 1}(1)
           case 'G'
               iteratorGPS = iteratorGPS + 1;
               ObservationDataGPS(iteratorGPS, 1) = hour * 3600 +...
                           minute * 60 + second;
               ObservationDataGPS(iteratorGPS, 2) = real(str2doubleq(...
                   PRN{satellite + 1}(2:3)));
               ObservationDataGPS(iteratorGPS, 6) = epochFlag;
               ObservationDataGPS(iteratorGPS, 7) = numberOfSatellites;
               ObservationDataGPS(iteratorGPS, 8) = clockOffset;
               
               % EPHEMERIS
               b = find(EphemerisGPS(:,2) == ObservationDataGPS(iteratorGPS, 2));
               Eph = EphemerisGPS(b, :);
               [~, ii] = min(abs((Eph(:,1) - T0)));
               if sum(Eph(ii, 3:18)) == 0
                   ObservationDataGPS(iteratorGPS, 3) = nan;
                   ObservationDataGPS(iteratorGPS, 4) = nan;
                   ObservationDataGPS(iteratorGPS, 5) = nan;
               else
                   SatECEF = svpeph(floor(GPSWeekTime), Eph(ii, 3:18));
                   ObservationDataGPS(iteratorGPS, 3) = SatECEF(1);
                   ObservationDataGPS(iteratorGPS, 4) = SatECEF(2);
                   ObservationDataGPS(iteratorGPS, 5) = SatECEF(3);
               end
       
%            case 'R'
%               iteratorGLO = iteratorGLO + 1;
%               ObservationDataGLO(iteratorGLO, 1) = hour * 3600 +...
%                   minute * 60 + second;
%               ObservationDataGLO(iteratorGLO, 2) = real(str2doubleq(...
%                   PRN{satellite + 1}(2:3));
%               ObservationDataGLO(iteratorGLO, 6) = epochFlag;
%               ObservationDataGLO(iteratorGLO, 7) = numberOfSatellites;
%               ObservationDataGLO(iteratorGLO, 8) = clockOffset;
%               
%               % EPHEMERIS
%               b = find(EphemerisGLO(:,2) == ObservationDataGLO(iteratorGLO, 2));
%                Eph = EphemerisGLO(b, :);
%                [~, ii] = min(abs((Eph(:,1) - T0)));
%                if sum(Eph(ii, 3:11)) == 0
%                    ObservationDataGLO(iteratorGLO, 3) = nan;
%                    ObservationDataGLO(iteratorGLO, 4) = nan;
%                    ObservationDataGLO(iteratorGLO, 5) = nan;
%                else
%                    ObservationDataGLO(iteratorGLO, 3) = Eph(ii, 3);
%                    ObservationDataGLO(iteratorGLO, 4) = Eph(ii, 6);
%                    ObservationDataGLO(iteratorGLO, 5) = Eph(ii, 9);
%                end
%                
%            case 'E'
%                iteratorGAL = iteratorGAL + 1;
%                ObservationDataGAL(iteratorGAL, 1) = hour * 3600 +...
%                   minute * 60 + second;
%                ObservationDataGAL(iteratorGAL, 2) = real(str2doubleq(...
%                   PRN{satellite + 1}(2:3));
%               ObservationDataGAL(iteratorGAL, 6) = epochFlag;
%               ObservationDataGAL(iteratorGAL, 7) = numberOfSatellites;
%               ObservationDataGAL(iteratorGAL, 8) = clockOffset;
       end
       
       obsNum = 1;
       for lineNumber = 1 : numberOfLines
           for i = 1 : 5
               if  obsNum > numberOfObservations
                   break;
               end
               
               while size(line, 2) ~= 80
                   line = [line, ' '];
               end
               switch PRN{satellite + 1}(1)
                   
                   case 'G'
                       ObservationDataGPS(iteratorGPS, 9 + (obsNum - 1) * 3) =...
                           real(str2doubleq(line(1 + (i - 1) * 16:14 + (i - 1) * 16)));
                       ObservationDataGPS(iteratorGPS, 10 + (obsNum - 1) * 3) = ...
                           real(str2doubleq(line(15 + (i - 1) * 16)));
                       ObservationDataGPS(iteratorGPS, 11 + (obsNum - 1) * 3) =...
                           real(str2doubleq(line(16 + (i - 1) * 16)));
               
%                    case 'R'
%                        ObservationDataGLO(iteratorGLO, 9 + (obsNum - 1) * 3) =...
%                            real(str2doubleq(line(1 + (i - 1) * 16:14 + (i - 1) * 16));
%                        ObservationDataGLO(iteratorGLO, 10 + (obsNum - 1) * 3) = ...
%                            real(str2doubleq(line(15 + (i - 1) * 16));
%                        ObservationDataGLO(iteratorGLO, 11 + (obsNum - 1) * 3) =...
%                            real(str2doubleq(line(16 + (i - 1) * 16));
%                
%                    case 'E'
%                        ObservationDataGAL(iteratorGAL,...
%                            9 + (i - 1 + (numberOfLines - 1) * 5) * 3) =...
%                            real(str2doubleq(line(1 + (i - 1) * 16:14 + (i - 1) * 16));
%                        ObservationDataGAL(iteratorGLA,...
%                            10 + (i - 1 + (numberOfLines - 1) * 5) * 3) =...
%                            real(str2doubleq(line(15 + (i - 1) * 16));
%                        ObservationDataGAL(iteratorGAL,...
%                            11 + (i - 1 + (numberOfLines - 1) * 5) * 3) =...
%                            real(str2doubleq(line(16 + (i - 1) * 16));
               end
               obsNum = obsNum + 1;
           end
           if lineNumber ~= numberOfLines
               line = fgetl(fd);
           end
       end
       if satellite ~= numberOfSatellites 
           line = fgetl(fd);
       end
   end
end

ObservationDataGPS(iteratorGPS + 1 : end, :) = [];
% ObservationDataGLO(iteratorGLO + 1 : end, :) = [];
% ObservationDataGAL(iteratorGAL + 1 : end, :) = [];

DescriptionBlockGPS = {'TIME', 'PRN', 'X ECEF', 'Y ECEF', 'Z ECEF', 'FLAG',...
    'NS', 'CLOCK OFFSET'};
for i = 1 : numberOfObservations
    DescriptionBlockGPS{end + 1} = ObservTypes{i};
    DescriptionBlockGPS{end + 1} = 'L';
    DescriptionBlockGPS{end + 1} = 'S/N';
end

% DescriptionBlockGLO = {'TIME', 'PRN', 'X ECEF', 'Y ECEF', 'Z ECEF', 'FLAG',...
%     'NS', 'CLOCK OFFSET'};
% for i = 1 : numberOfObservations
%     DescriptionBlockGLO{end + 1} = ObservTypes{i};
%     DescriptionBlockGLO{end + 1} = 'L';
%     DescriptionBlockGLO{end + 1} = 'S/N';
% end

fclose('all');

% save('test.mat', 'ObservationDataGPS', 'ObservationDataGLO',...
%     'ObservationDataGAL','rinexVersion', 'fs', 'startTime',...
%     'endTime', 'PositionX', 'PositionY', 'PositionZ',...
%     'DescriptionBlockGPS', 'DescriptionBlockGLO', 'leapSeconds',...
%     'ObservTypes');
pathParts = split(path, '\');
save([pathParts{end}(1 : end - 4), '.mat'], 'ObservationDataGPS',...
    'rinexVersion',...
    'Position_X', 'Position_Y', 'Position_Z',...
    'DescriptionBlockGPS',...
    'ObservTypes');
clear
    
