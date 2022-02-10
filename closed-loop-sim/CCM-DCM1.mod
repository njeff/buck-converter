*CCM-DCM1
.subckt CCM-DCM1 1 2 3 4 5
+ params: L=10u fs=1e5
Et 1 2 value={(1-v(u))*v(3,4)/v(u)}
Gd 4 3 value={(1-v(u))*i(Et)/v(u)}
Ga 0 a value={MAX(i(Et),0)}
Va a b
Ra b 0 1k
Eu u 0 table {MAX(v(5),
+ v(5)*v(5)/(v(5)*v(5) + 2*L*fs*i(Va)/v(3,4)))} (0 0) (1 1)
.ends
