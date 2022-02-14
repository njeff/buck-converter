s = tf('s');
% opamp model
A = 300e3;
GBW = 1.5e6; %MHz
wp = 2*pi*(GBW/A);
H = A/(1+s/wp);
%H = A;

VM = 3;
% loop gain, without feedback factor
Vin = 10;
L = 10e-6;
C = 100e-6;
R = 1e5;
Q = R*sqrt(C/L);
wn = 1/sqrt(L*C);
Gvd = tf([Vin], [1/(wn^2), 1/(Q*wn), 1]);

% non-ideal LC
RL = 1e-2;
RC = 1e-2;
Gvd2 = Vin*tf([C*RC, 1], [L*C*(R+RC)/R, L/R+RC*C+RL*C+RL*RC*C/R, 1+RL/R]);
%bode(Gvd2);

%lag compensator
zero = 2*pi*(wn*0.3);
pole = 2*pi*(30000);
G = (1+s/zero)*(1+s/(zero))/(1+s/pole);

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
figure;
fb = feedback(forward, tf([1], [2]));
bode(fb);
%%
R1 = 31e3;
R2 = 5e3;
R3 = 5e3;
C1 = 150e-12;
C2 = 20e-9;
C3 = 3e-9;
beta = R1*R3*C1*s*(s+(C1+C2)/(C1*C2*R2))*(s+1/(R3*C3))/((R1+R3)*(s+1/(R2*C2))*(s+1/((R1+R3)*C3)));
hold on;
%bode(beta)
Hcomp = H/(1+H*beta);
bode(Hcomp)
bode(Hcomp*Gvd/VM);
bode(Hcomp*Gvd2/VM);
delay = tf(1,1,'InputDelay',3e-5/2);
bode(Hcomp*Gvd2*delay/VM,{1,100000});
grid on;