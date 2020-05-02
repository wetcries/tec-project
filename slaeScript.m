%%  Задаем шаг по времени
    span=90; % Зазмер половины окна задается в секундах
    dt=300;
    N=size(dt:dt:86400-dt,2);
%%  Задаем геометрические константы    
     E=wgs84Ellipsoid;
     Re=E.SemiminorAxis; % Радиус Земли
     H=350000;                 % Задаем высоту подионосферной точки в км
     alpha=0.87;
%% Инициализируем итоговый масив 
    A=zeros(32*(2*span+1)*N,N+32);
    B=zeros(32*(2*span+1)*N,1);
    sats=double(isnan(Elev)~=1);
    x=0; % один из индексов
%% загрузка файла с данными о hmF2
%     load(['D:\Internet\YandexDisk\Work\GPS\SolarFlares\' mask '_hmF2'],'hmF2');
N_SAT=zeros(N,1);
for i=dt:dt:86400-dt
%         disp(i/dt);
%         qq=find(abs(hmF2(:,1)-i)==min(abs((hmF2(:,1)-i)))); % индекс в массиве hmF2
%         H=hmF2(qq,3);
        n_sat=zeros(span*2+1,1);
        y=0;    % один из индексов
    for k=-span:span
        n=i+k+1;
            n_sat(k+span+1,1)=size(find(isnan(stec(n,:))==0),2);
        for s=1:32
            I=x+y*32+s; % Строчный индекс по итоговой матрице 
            if isnan(Elev(n,s))==0
                A(I,i/dt)=1./(cos(asin(Re/(Re+H)*sin(alpha*(pi/2-Elev(n,s)*pi/180)))));
                A(I,N+s)=sats(n,s);
                B(I,1)=stec(n,s);
                if  isnan(B(I,1))==1
                    B(I,1)=0;
                end
            end            
        end       
       y=y+1;
    end
    x=x+(2*span+1)*32;
    N_SAT(i/dt,1)=mean(n_sat);
end
MATRIX = sparse(A);
solution = MATRIX \ B;
        C=[A B];
        C = C(any(C,2),: );
        save('solution.mat', 'solution', 'C');
%         e=C(:,1:end-1)\C(:,end); % конечное рещение, e(1:N)- значения абсолютного ПЭС e(N+1:end) - ДКЗ приемник + спутник