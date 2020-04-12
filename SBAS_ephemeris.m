% finput='E:\YandexDisk\Work\GPS\DATA\SigmaRinex\2015_01_07\log_2015_01_07_00.00.00.15H';
% Данная программа позволяет считывать координаты спутников Глонасс
%   finput - путь к файлу
%   на выходе получаем масив 
%   Eph_GLO=(t,SatNum,X,Xv,Xa,Y,Yv,Ya,Z,Zv,Za,Health)
%   1 столбец: t - время передачи эфемерид в формате  MatLab
%   2 столбец: SatNum - порядковый номер спутника Глонасс
%   3 столбец: X - X координата спутника в формате ECEF
%   4 столбец: Xv - Xv скорость спутника в формате ECEF
%   5 столбец: Xa - Xa ускорение спутника в формате ECEF 
%   6 столбец: Y - Y координата спутника в формате ECEF
%   7 столбец: Yv - Yv скорость спутника в формате ECEF
%   8 столбец: Ya - Ya ускорение спутника в формате ECEF 
%   9 столбец: Z - Z координата спутника в формате ECEF
%   10 столбец: Zv - Zv скорость спутника в формате ECEF
%   11 столбец: Za - Za ускорение спутника в формате ECEF  
%   12 столбец: Health - Health переданного сообщения
function Eph_SBAS = SBAS_ephemeris(finput)
%% Обращаемся к файлу
    fid=fopen(finput,'r');
%% Определяем версию RINEX данных
    line = fgetl(fid); 
    RinVer=line(6:9); %#ok<NASGU>
    NumLine=0;
%% Пропускаем заголовок
    while 1
       line = fgetl(fid);
       answer = findstr(line,'END OF HEADER');  %#ok<FSTR>
       if  ~isempty(answer),
            NumLine=NumLine+1;
            break
       end 
    end
    clear answer;
    %% Считываем значение эфемерид
        Eph_SBAS=[];
        while  ~feof(fid) 
            line = fgetl(fid);
                SatNum=str2double(line(2:3));
                Year=str2double(line(5:8));
                Month=str2double(line(10:11));
                Day=str2double(line(13:14));
                Hour=str2double(line(16:17));
                Min=str2double(line(19:20));
                Sec=str2double(line(22:23));
                t=datenum(Year, Month, Day, Hour, Min, Sec);
                clear Year Month Day Hour Min Sec;
                
                SvClock=str2num(line(24:42));   %#ok<*ST2NM> % В секундах
                ScFrenq=str2num(line(43:61));
                MFT=str2num(line(62:80));
                
            %% BROADCAST ORBIT - 1
                line = fgetl(fid);
                    X=str2num(line(5:23))*1000;     % X координата спутника в формате ECEF
                    Xv=str2num(line(24:42))*1000;   % Xv скорость спутника в формате ECEF
                    Xa=str2num(line(43:61))*1000;   % Xa ускорение спутника в формате ECEF 
                    Health=str2num(line(62:80));    % Значение 0 все OK
            %% BROADCAST ORBIT - 2
                line = fgetl(fid);
                    Y=str2num(line(5:23))*1000;     % Y координата спутника в формате ECEF
                    Yv=str2num(line(24:42))*1000;   % Yv скорость спутника в формате ECEF
                    Ya=str2num(line(43:61))*1000;   % Ya ускорение спутника в формате ECEF
                    FreqNum=str2num(line(62:80));   %#ok<NASGU> % Номер частоты
            %% BROADCAST ORBIT - 3
                line = fgetl(fid);
                    Z=str2num(line(5:23))*1000;     % Z координата спутника в формате ECEF
                    Zv=str2num(line(24:42))*1000;   % Zv скорость спутника в формате ECEF
                    Za=str2num(line(43:61))*1000;   % Za ускорение спутника в формате ECEF
                    Age=str2num(line(62:80));       %
            %% Записываем в матрицу
                if Health==0
                    Eph_SBAS=[Eph_SBAS;t,SatNum,X,Xv,Xa,Y,Yv,Ya,Z,Zv,Za,Health]; %#ok<AGROW>
                else
                    Eph_SBAS=[Eph_SBAS;t,SatNum,0,0,0,0,0,0,0,0,0,Health]; %#ok<AGROW>
                end
                clear t SatNum X Xv Xa Y Yv Ya Z Zv Za Health FreqNum Age SvClock ScFrenq MFT                
        end
        fclose(fid);      