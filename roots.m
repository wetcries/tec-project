function roots(file)
load(file, 'S', 'y');

x = S \ y;

save(file, 'x', 'S', 'y');

