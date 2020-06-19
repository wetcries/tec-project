folder = 'C:\Users\meDaddy\Documents\MATLAB\273';

files = dir(folder);
compactRinexFiles = cell(0, 1);

for i = 1 : size(files, 1)
    if contains(files(i).name(end), 'd')
        compactRinexFiles{end + 1, 1} = i;
    end
end

for i = 1 : size(compactRinexFiles, 1)
    fileName = files(compactRinexFiles{i}).name;
    system(['crx2rnx.exe', ' ', folder, '\',...
        fileName, ' - > ', folder, '\',...
        fileName(1 : end - 1), 'o']);
end