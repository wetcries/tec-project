function slae(file, mode, period, window, alpha)
load(file, 'TEC_cell', 'base_position');
sizeOfData = 0;

for i = 1 : 32
    if isempty(TEC_cell{i})
        continue
    end
    
    for k = 1 : size(TEC_cell{i}, 1)
        time = TEC_cell{i}(k, 1);
        index = round(time / period);
        if abs(time - round(time / period) * period) <= window &&...
                index ~= 0 &&...
                index ~= 86400 / period 
            sizeOfData = sizeOfData + 1;
        end
    end
end

A = zeros(sizeOfData, 32 + (86400 / period - 1) * (mode * 3 + 1));
B = zeros(sizeOfData, 1);
E = wgs84Ellipsoid;
RE = E.SemiminorAxis;
H = 450000;
baseLLA = ecef2lla(base_position, 'WGS84');
latBase = baseLLA(1);
lonBase = baseLLA(2);
coef = RE / (RE + H);
counter = 0;

for i = 1 : 32
    if isempty(TEC_cell{i})
        continue
    end
    
    for k = 1 : size(TEC_cell{i}, 1)
        time = TEC_cell{i}(k, 1);
        index = round(time / period);
        
        if abs(time - index * period) > window ||...
                index == 0 || index == 86400 / period
            continue
        end
        
        counter = counter + 1;
        angle = TEC_cell{i}(k, 2);
        s = 1 / (cos(asin(coef * sin(alpha * (pi / 2 - angle)))));
        lat = TEC_cell{i}(k, 3);
        lon = TEC_cell{i}(k, 4);
        deltaLat = lat - latBase;
        deltaLon = lon - lonBase;
        deltaTime = time - index * period;
        
        
        A(counter, 1 + (index - 1) * (mode * 3 + 1)) = s;
        
        if mode == 1 || mode == 2
            A(counter, 2 + (index - 1) * (mode * 3 + 1)) =...
                s * deltaLat;
            A(counter, 3 + (index - 1) * (mode * 3 + 1)) =...
                s * deltaLon;
            A(counter, 4 + (index - 1) * (mode * 3 + 1)) =...
                s * deltaTime;
        end
        
        if mode == 2
            A(counter, 5 + (index - 1) * (mode * 3 + 1)) =...
                s * deltaLat ^ 2;
            A(counter, 6 + (index - 1) * (mode * 3 + 1)) =...
                s * deltaLon ^ 2;
            A(counter, 7 + (index - 1) * (mode * 3 + 1)) =...
                s * deltaTime ^ 2;
        end
        
        A(counter, end - 32 + i) = 1;
        B(counter, 1) = TEC_cell{i}(k, 8);
    end
end

S = sparse(A);
x = S \ B;
save(['slae_', file(7 : end)], 'S', 'x', 'B', 'mode');
end

