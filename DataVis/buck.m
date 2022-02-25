s = tf('s');
% opamp model
A = 300e3;
GBW = 1.5e6; %MHz
wp = 2*pi*(GBW/A);
H = A/(1+s/wp);
%H = A;

VM = 10;
% loop gain, without feedback factor
Vin = 10;
L = 10e-6;
C = 100e-6;
R = 1e5;
Q = R*sqrt(C/L);
wn = 1/sqrt(L*C);
Gvd = tf([Vin], [1/(wn^2), 1/(Q*wn), 1]);

% non-ideal LC
RL = 2e-2;
RC = 2e-2;
Gvd2 = Vin*tf([C*RC, 1], [L*C*(R+RC)/R, L/R+RC*C+RL*C+RL*RC*C/R, 1+RL/R]);
%bode(Gvd2);

forward = H*Gvd2/VM;
f = logspace(1,5,100);
v = bode(forward, 2*pi*f);
%loglog(f, v(:,:));
grid on;
xlabel('Freq Hz');
ylabel('Fwd');

%rlocus(forward, [0.5, 1]);
hold on;
bode(H*Gvd/VM)
bode(forward)
title('Lossless vs Lossy');
legend({'Lossless','Lossy'},'Location','southwest')
%bode(Gvd)
grid on;

%%
fprintf("\nCalculating Filter Component Values\n");
fprintf("-----------------------------------\n");
% crossover freq
wcross = wn * 4;
fprintf("f_cross: %f, f_filter: %f\n", wcross/(2*pi), wn/(2*pi));

wz1 = wn*0.1; % set first zero
%wz1 = 1/(R1C3)
R1 = 27e3; % arbitrary
C3 = 1/(R1*wz1); 

wp1 = wcross; % set first pole
R3 = 1/(C3*wp1);

% set compensator gain
H_compcross = 1/abs(evalfr(Gvd2,wcross)/VM)
R2 = (R1*R3/(R1+R3))*H_compcross;

% set second zero
wz0 = wn*0.3;
C2 = 1/(R2*wz0);

% set second pole
wp0 = wcross*10;
C1 = 1/(R2*wp0);

fprintf("R1: %f, R2: %d, R3: %d, \nC1: %d, C2: %d, C3: %d\n", R1, R2, R3, C1, C2, C3);

beta = R1*R3*C1*s*(s+(C1+C2)/(C1*C2*R2))*(s+1/(R3*C3))/((R1+R3)*(s+1/(R2*C2))*(s+1/((R1+R3)*C3)));
hold on;
%bode(beta)
Hcomp = H/(1+H*beta);
% compare closed loop vs 1/beta
bode(Hcomp)
bode(1/beta)
grid on;
title('Closed Loop vs 1/beta');
legend({'Closed Loop Form','1/beta'},'Location','northwest')
%%
% delay
hold on;
%bode(Hcomp*Gvd/VM);
bode(Hcomp*Gvd2/VM);
% 400kHz equivalent since dual slope from the triangle
delay = tf(1,1,'InputDelay',1/(400e3));
bode(Hcomp*Gvd2*delay/VM,{1,200000});
grid on;
title('No delay vs w/delay');
legend({'No delay','w/Delay'},'Location','northwest')