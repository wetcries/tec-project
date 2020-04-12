path = 'C:\Users\meDaddy\Documents\MATLAB\2020\bias\CAS0MGXRAP_20172500000_01D_01D_DCB.BSX';
fd =fopen(path, 'r');
while true
    line = fgetl(fd);
    if ~contains(line, 'BIAS/SOLUTION')
        continue;
    else
        break;
    end
end

bias_cell = cell(32, 1);
for i = 1 : 32
    bias_cell{i} = cell(0, 4);
end

while ~feof(fd)
    line = fgetl(fd);
    
    if ~contains(line, 'DSB')
        continue;
    end
    
    if line(12) ~= 'G'
        continue;
    end
    
    if line(13) == ' '
        break;
    end
    
    prn = int64(str2double(line(13:14)));
    bias_cell{prn}{end + 1, 1} = line(26:29);
    bias_cell{prn}{end, 2} = line(31:34);
    bias_cell{prn}{end, 3} = str2double(line(71:91));
    bias_cell{prn}{end, 4} = str2double(line(93:103));
    
end

save('bias.mat', 'bias_cell');
clear
    
    
