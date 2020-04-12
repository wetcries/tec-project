function D = GPS_ephemeris (finput)
% Scope:   This Matlab program reads a RINEX 2 navigation message file
%          output contain the reduced ephemeris data. 
% Usage:   D = ephemeris ('file.09n');   
% Inputs:  - name of the ephemeris data file, RINEX 2 navigation message file 
%  Remark: The reduced ephemeris data can be used by macros 
%          svpeph and svpalm, respectively; both files contain data only for 
%          healthy satellites. 
%  Last update:  05/26/09 
%  Copyright (C) Ryabov Alexander. 
 
finp = fopen(finput, 'r'); 
% определяем версию RINEX данных
line = fgetl(finp); 
RinVer=line(6:9);
% пропускаем заголовок
while 1
   line = fgetl(finp); 
   answer = findstr(line,'END OF HEADER'); 
   if  ~isempty(answer), break;  end 
end
% инициируем данные 
D = []; nrsat = 0; 
% Считываем данные эфемерид согласно версии RINEX 
if RinVer == '3.02'
  while  ~feof(finp) 
   line = fgetl(finp);	      
       SatNum = str2double(line(2:3)); %№ спутника
       Year = str2double(line(5:8)); %Год
       Month = str2double(line(10:11)); %Месяц
       Day = str2double(line(13:14)); %День
       Hour = str2double(line(16:17));%Час 
       Min = str2double(line(19:20)); %Минута
       Sec = str2double(line(22:23)); %Секунда
       t=datenum(Year,Month,Day,Hour,Min,Sec); % Переводим время в формат MatLab
       
       
       af0 = str2num(line(24:42)); %- Сдвиг часов спутника (секунда)
       af1 = str2num(line(43:61)); %- Скорость ухода часов (сек./сек.)
       af2 = str2num(line(62:80)); %- Ускорение ухода часов (сек./сек.^2)
    %% BROADCAST ORBIT - 1
       line = fgetl(finp);	       
           iode = str2num(line(5:23)); 
           crs = str2num(line(24:42)); 
           deltan = str2num(line(43:61)); 
           M0 = str2num(line(62:80)); 
    %% BROADCAST ORBIT - 2
       line = fgetl(finp);	     
           cuc = str2num(line(5:23)); 
           ecc = str2num(line(24:42)); 
           cus = str2num(line(43:61)); 
           roota = str2num(line(62:80)); % - sqrt(A) (метр^0.5) 
    %% BROADCAST ORBIT - 3
       line = fgetl(finp);        
           toe = str2num(line(5:23));  %Время эфемерид (Toe)
           cic = str2num(line(24:42)); 
           Omega0 = str2num(line(43:61)); 
           cis = str2num(line(62:80)); 
    %% BROADCAST ORBIT - 4
       line = fgetl(finp);	       
           i0 =  str2num(line(5:23)); 
           crc = str2num(line(24:42)); 
           omega = str2num(line(43:61)); 
           Omegadot = str2num(line(62:80)); 
    %% BROADCAST ORBIT - 5
       line = fgetl(finp);	       
           idot = str2num(line(5:23)); 
           codes = str2num(line(24:42)); %Коды в диапазоне L2
           weekno = str2num(line(43:61)); 
           L2flag = str2num(line(62:80)); %Флаг данных L2 P
    %% BROADCAST ORBIT - 6           
       line = fgetl(finp);	      
           svaccur = str2num(line(5:23)); %- Точность положения спутника (метр)
           svhealth = str2num(line(24:42)); %- Исправность сп. (биты 17-22 сл.3 кад.1)
           tgd = str2num(line(43:61)); 
           iodc = str2num(line(62:80)); 
    %% BROADCAST ORBIT - 7
       line = fgetl(finp);	       
           tom = str2num(line(5:23)); %- Время передачи сообщения:0, если неизвестно
        nrsat = nrsat + 1;
    %% Записываем в матрицу  
        if  (svhealth == 0) 
            smaxis = roota * roota; 
            D = [D; t SatNum toe smaxis ecc i0 Omega0 omega M0 Omegadot deltan idot cic cis crc crs cuc cus];
        else D=[D; t SatNum 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
        end 
 end    
else  % для версии RINEX 210 и 211 формат эфемерид совпадает
  while  ~feof(finp) 
   line = fgetl(finp);	      
   SatNum = str2double(line(1:2));    %№ спутника
   Year = str2double(line(3:5));     %Год
   Month = str2double(line(6:8));    %Месяц
   Day = str2double(line(9:11));     %День
   Hour = str2double(line(12:14));   %Час 
   Min = str2double(line(15:17));    %Минута
   Sec = str2double(line(18:22));    %Секунда
   t=datenum (Year,Month,Day,Hour,Min,Sec); % Переводим время в формат MatLab
   
   af0 = str2num(line(23:41)); %- Сдвиг часов спутника (секунда)
   af1 = str2num(line(42:60)); %- Скорость ухода часов (сек./сек.)
   af2 = str2num(line(61:79)); %- Ускорение ухода часов (сек./сек.^2)
   line = fgetl(finp);	       % BROADCAST ORBIT - 1
   iode = str2num(line(4:22)); 
   crs = str2num(line(23:41)); 
   deltan = str2num(line(42:60)); 
   M0 = str2num(line(61:79)); 
   line = fgetl(finp);	       % BROADCAST ORBIT - 2
   cuc = str2num(line(4:22)); 
   ecc = str2num(line(23:41)); 
   cus = str2num(line(42:60)); 
   roota = str2num(line(61:79)); % - sqrt(A) (метр^0.5) 
   line = fgetl(finp);         % BROADCAST ORBIT - 3
   toe = str2num(line(4:22));  %Время эфемерид (Toe)
   cic = str2num(line(23:41)); 
   Omega0 = str2num(line(42:60)); 
   cis = str2num(line(61:79)); 
   line = fgetl(finp);	       % BROADCAST ORBIT - 4
   i0 =  str2num(line(4:22)); 
   crc = str2num(line(23:41)); 
   omega = str2num(line(42:60)); 
   Omegadot = str2num(line(61:79)); 
   line = fgetl(finp);	       % BROADCAST ORBIT - 5
   idot = str2num(line(4:22)); 
   codes = str2num(line(23:41)); %Коды в диапазоне L2
   weekno = str2num(line(42:60)); 
   L2flag = str2num(line(61:79)); %Флаг данных L2 P
   line = fgetl(finp);	       % BROADCAST ORBIT - 6
   svaccur = str2num(line(4:22)); %- Точность положения спутника (метр)
   svhealth = str2num(line(23:41)); %- Исправность сп. (биты 17-22 сл.3 кад.1)
   tgd = str2num(line(42:60)); 
   iodc = str2num(line(61:79)); 
   line = fgetl(finp);	       % BROADCAST ORBIT - 6
   tom = str2num(line(4:22)); %- Время передачи сообщения:0, если неизвестно
 
   nrsat = nrsat + 1; 
 
   if  (svhealth == 0) 
      smaxis = roota * roota; 
 
%     Save the reduced data set to be used by macro svpeph  
    
%       fprintf(fout1,'%3d %16.9e %16.9e %16.9e %16.9e ',svprn,toe,smaxis,ecc,i0); 
%       fprintf(fout1,'%16.9e %16.9e %16.9e %16.9e ',Omega0,omega,M0,Omegadot); 
%       fprintf(fout1,'%16.9e %16.9e %16.9e %16.9e ',deltan,idot,cic,cis); 
%       fprintf(fout1,'%16.9e %16.9e %16.9e %16.9e\n',crc,crs,cuc,cus); 

D = [D; t SatNum toe smaxis ecc i0 Omega0 omega M0 Omegadot deltan idot cic cis crc crs cuc cus];
   end 
 
  end 
end
fclose (finp);