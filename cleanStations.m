stations = {'zada';'ware';'ven1';'prat';'pore';...
    'pasa';'msel';'mops';'kunz';'dent';'ctab';'cako';'bute'};

for k = 1 : size(stations, 1)
    file = [stations{k}, '2530.mat'];
    try
        load([folder, '\slae\', 'slae_1_', file]);
    catch
        fprintf('No such file: %s\n', file);
        continue;
    end
        
    if isempty(S)
        continue
    end
    load([folder, '\mat\', file], 'year', 'month', 'day');
    load([folder, '\cell\', 'cell_', file], 'base_position');
    tec = x(1 : mode * 3 + 1 :end - 32);
    timeDer = x(4 : mode * 3 + 1 : end - 32);
    time = period : period : 86400 - period;
    time = time / 3600;
    
    lla = ecef2lla(base_position, 'WGS84');
    lla = round(lla);
    mtime = 0.25 : 0.25 : 24 - 0.25;
    mtec = M_tec(1:end-1, 91 + lla(1), 181 + lla(2));
    etec = M_dtec(1:end-1, 91 + lla(1), 181 + lla(2));
    
    mtec = mtec + (mean(tec) - mean(mtec));
    
    if size(mtec) == size(tec)
        dist = norm(pdist([mtec, tec]));
        if isnan(dist)
            continue
        end
    else
        continue
    end
    
    normdist = dist / norm(mtec);
    
    figure;
    hold on;
    yyaxis left;
    plot(time, tec);
    errorbar(mtime, mtec, etec);
    ylabel('TECU');
    xlabel('time');
    xlim([15.5, 16.5])
    yyaxis right;
    plot(time, timeDer);
    ylabel('dTEC/dt')
    title(stations{k});
end