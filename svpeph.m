%                          svpeph.m 
%  Scope:   This MATLAB macro computes ECEF satellite position based on  
%           satellite ephemeris data; WGS-84 constants are used. 
%  Usage:   pse = svpeph(tsim,edata) 
%  Description of parameters: 
%           tsim      - input, tsim, GPS system time at time of transmission, 
%                       i.e. GPS time corrected for transit time  
%                       (range/speed of light), in seconds 
%           edata(1)  - input, toe, reference time ephemeris, in seconds          
%           edata(2)  - input, smaxis (a), semi-major axis, in meters 
%           edata(3)  - input, ecc (e), satellite eccentricity   
%           edata(4)  - input, izero (I_0), inclination angle at reference time,  
%                       in radians  
%           edata(5)  - input, razero (OMEGA_0), right ascension at reference  
%                       time, in radians (longitude of ascending node of orbit  
%                       plane at weekly epoch) 
%           edata(6)  - input, argper (omega), argument of perigee, in radians 
%           edata(7)  - input, mzero (M_0), mean anomaly at reference time, in  
%                       radians       
%           edata(8)  - input, radot (OMEGA_DOT), rate of right ascension, in  
%                       radians/second  
%           edata(9)  - input, deln (delta_n), mean motion difference from  
%                       computed value, in radians/second  
%           edata(10) - input, idot (I_DOT), rate of inclination angle, in  
%                       radians/second  
%           edata(11) - input, cic, amplitude of the cosine harmonic 
%                       correction term to the angle of inclination, in radians 
%           edata(12) - input, cis, amplitude of the sine harmonic correction 
%                       term to the angle of inclination, in radians 
%           edata(13) - input, crc, amplitude of the cosine harmonic correction 
%                       term to the orbit radius, in meters 
%           edata(14) - input, crs, amplitude of the sine harmonic correction 
%                       term to the orbit radius, in meters 
%           edata(15) - input, cuc, amplitude of the cosine harmonic correction 
%                       term to the argument of latitude, in radians 
%           edata(16) - input, cus, amplitude of the sine harmonic correction 
%                       term to the argument of latitude, in radians 
%           pse       - output, ECEF satellite position vector, the components  
%                       are in meters 
%  External Matlab macros used:  wgs84con 
%  Last update:  11/09/00 
%  Copyright (C) 1996-00 by LL Consulting. All Rights Reserved. 
 
function   pse = svpeph(tsim,edata)  

%WGS-84
a_smaxis = 6378137.0;  
b_smaxis = 6356752.314245179; 
eccentr  = 0.08181919084265;     %  eccentr = sqrt(1 - (b_smaxis/a_smaxis)^2) 
eccentr2 = 6.69437999014e-3;     %  eccentr2 = flatness * (2. - flatness) 
flatness = 0.00335281066475;     %  1. / 298.257223563 = 1 - b_smaxis/a_smaxis 
eprime   = 0.0820944379496;      %  eprime = (a_smaxis/b_smaxis)* eccentr 
eprime2  = 6.73949674227e-3;     %  eprime2 = eprime^2 
onemecc2 = 0.99330562000986;     %  1. - eccentr2  
 
gravpar  = 3.986005e+14; 
rot_rate = 7.2921151467e-5;  
c_speed  = 2.99792458e+8; 
ucgrav   = 6.673e-11; 


[nrow,ncol] = size(edata); 
if  ncol ~= 16 
   error('Error  -  SVPEPH; check the dimension of the inputs'); 
end 
 
%  Constants and initialization 

% global constants used: gravpar, rot_rate 
 
toe    = edata(1);  
smaxis = edata(2);  
ecc    = edata(3);  % Экцентриситет
izero  = edata(4);  
razero = edata(5);  
argper = edata(6);  
mzero  = edata(7);  % Средняя аномалия
radot  = edata(8);  % Прямое восхождение
deln   = edata(9);  % Изменение средней угловой скорости
idot   = edata(10); 
cic    = edata(11); 
cis    = edata(12); 
crc    = edata(13); 
crs    = edata(14); 
cuc    = edata(15); 
cus    = edata(16); 
 
%  Compute GPS time of week at which SV position is computed 
 
ttr = tsim;    
tk = ttr - toe;   %  time from ephemeris reference epoch, in seconds 
if  tk > 302400. 
  tk = tk - 604800; 
elseif  tk < -302400. 
  tk = tk + 604800; 
end 
 
%  Initialization  
           
mmot = sqrt(gravpar/smaxis/smaxis/smaxis) + deln; 
r1mecc2 = sqrt(1. - ecc * ecc); 
sinw = sin(argper); 
cosw = cos(argper); 
izero = izero + idot * tk; 
sinio = sin(izero); 
cosio = cos(izero); 
 
%  Compute mean anomaly 
 
meanom = mzero + mmot * tk; 
 
%  Compute eccentric anomaly  (Keppler's equation) 
 
eccano = meanom + ecc * sin(meanom);  %  initial guess  
for j = 1:6     % number of iterations can be changed if necessary 
   temp1 = 1. - ecc * cos(eccano); 
   temp2 = sin(eccano) - eccano * cos(eccano); 
   eccano = (ecc * temp2 + meanom) / temp1; 
end 
 
%  Compute sine and cosine of eccentric anomaly, and rho 
 
sine = sin(eccano); 
cose = cos(eccano); 
rho = 1. - ecc * cose; 
 
%  Compute sine and cosine of true anomaly 
 
cosv = (cose - ecc) / rho; 
sinv = r1mecc2 * sine / rho; 
 
%  Compute sine and cosine of argument of latitude 
 
sinphi = cosv * sinw + cosw * sinv; 
cosphi = cosv * cosw - sinv * sinw; 
cos2phi = 1. - 2. * sinphi * sinphi; 
sin2phi = 2. * sinphi * cosphi; 
 
%  Correct argument of latitude 
 
delu = cus * sin2phi + cuc * cos2phi; 
sindelu = sin(delu); 
cosdelu = cos(delu); 
sinu = cosdelu * sinphi + sindelu * cosphi; 
cosu = cosdelu * cosphi - sindelu * sinphi; 
 
%  Compute satellite position in orbital plane 
 
delr = crs * sin2phi + crc * cos2phi; 
orbrad = smaxis * rho + delr; 
xprime = orbrad * cosu; 
yprime = orbrad * sinu; 
 
%  Correct inclination 
 
deli = cis * sin2phi + cic * cos2phi; 
sindeli = sin(deli); 
cosdeli = cos(deli); 
sini = cosdeli * sinio + sindeli * cosio; 
cosi = cosdeli * cosio - sindeli * sinio; 
 
%  Compute longitude of ascending node, its sine and cosine 
 
omega = razero + radot * tk - rot_rate * ttr; 
sinome = sin(omega); 
cosome = cos(omega); 
 
%  Compute satellite position in ECEF, in meters 
 
pse(1) = xprime * cosome - yprime * cosi * sinome; 
pse(2) = xprime * sinome + yprime * cosi * cosome; 
pse(3) = yprime * sini; 