load('slae_p0592530.mat');
tec = x(1 : mode * 3 + 1 :end - 32);
period = 86400 / (size(tec, 1) + 1);
time = period : period : 86400 - period;
time = time / 3600;

figure;
plot(time, tec);
axis([0, 24, 0, max(tec) + 1]);
xticks(0:24);