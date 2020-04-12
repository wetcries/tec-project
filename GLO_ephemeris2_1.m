% Данная программа позволяет считывать координаты спутников Глонасс
%   finput - путь к файлу
%   на выходе получаем масив 
%   Eph_GLO=(t,SatNum,,Xv,Xa,Y,Yv,Ya,Z,Zv,Za,Health)
%   t - время передачи эфемерид в формате  MatLab
%   SatNum - порядковый номер спутника Глонасс
%   X - X координата спутника в формате ECEF
%   Xv - Xv скорость спутника в формате ECEF
%   Xa - Xa ускорение спутника в формате ECEF 
%   Y - Y координата спутника в формате ECEF
%   Yv - Yv скорость спутника в формате ECEF
%   Ya - Ya ускорение спутника в формате ECEF 
%   Z - Z координата спутника в формате ECEF
%   Zv - Zv скорость спутника в формате ECEF
%   Za - Za ускорение спутника в формате ECEF  
%   Health - Health переданного сообщения
function Eph_GLO = GLO_ephemeris2_1(finput)
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
    %% Считываем значение эфемерид
        Eph_GLO=[];
        while  ~feof(fid) 
            line = fgetl(fid);
                SatNum=str2double(line(1:2));
                Year=str2double(line(4:5));
                Month=str2double(line(7:8));
                Day=str2double(line(10:11));
                Hour=str2double(line(13:14));
                Min=str2double(line(16:17));
                Sec=str2double(line(18:22));
                t=datenum(Year + 2000, Month, Day, Hour, Min, Sec+16); %приводим ко времени в формате GPS
                clear Year Month Day Hour Min Sec;
                
                SvClock=str2num(line(23:41));   %#ok<*ST2NM> % В секундах
                ScFrenq=str2num(line(42:60));
                MFT=str2num(line(61:79));
                
            %% BROADCAST ORBIT - 1
                line = fgetl(fid);
                    X=str2num(line(4:22))*1000;     % X координата спутника в формате ECEF
                    Xv=str2num(line(23:41))*1000;   % Xv скорость спутника в формате ECEF
                    Xa=str2num(line(42:60))*1000;   % Xa ускорение спутника в формате ECEF 
                    Health=str2num(line(61:79));    % Значение 0 все OK
            %% BROADCAST ORBIT - 2
                line = fgetl(fid);
                    Y=str2num(line(4:22))*1000;     % Y координата спутника в формате ECEF
                    Yv=str2num(line(23:41))*1000;   % Yv скорость спутника в формате ECEF
                    Ya=str2num(line(42:60))*1000;   % Ya ускорение спутника в формате ECEF
                    FreqNum=str2num(line(61:79));   %#ok<NASGU> % Номер частоты
            %% BROADCAST ORBIT - 3
                line = fgetl(fid);
                    Z=str2num(line(4:22))*1000;     % Z координата спутника в формате ECEF
                    Zv=str2num(line(23:41))*1000;   % Zv скорость спутника в формате ECEF
                    Za=str2num(line(42:60))*1000;   % Za ускорение спутника в формате ECEF
                    Age=str2num(line(61:79));       %
            %% Записываем в матрицу
                if Health==0
                    Eph_GLO=[Eph_GLO;t,SatNum,X,Xv,Xa,Y,Yv,Ya,Z,Zv,Za,Health]; %#ok<AGROW>
                else
                    Eph_GLO=[Eph_GLO;t,SatNum,0,0,0,0,0,0,0,0,0,Health]; %#ok<AGROW>
                end
                clear t SatNum X Xv Xa Y Yv Ya Z Zv Za Health FreqNum Age SvClock ScFrenq MFT                
        end
        fclose(fid);      