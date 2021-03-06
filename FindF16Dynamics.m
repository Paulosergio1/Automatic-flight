%================================================
%     Matlab Script File used to linearize the 
%     non-linear F-16 model. The program will 
%     Extract the longitudal and lateral 
%     direction matrices.  These system matrices 
%     will be used to create pole-zero mapping
%     and the bode plots of each to each control
%     input.
% Author: Richard S. Russell
% 
%================================================
clear;

addpath obsmutoolsfornewermatlabversions -END % required for some new MATLAB versions

global fi_flag_Simulink

newline = sprintf('\n');

%% Trim aircraft to desired altitude and velocity
%%
altitude = input('Enter the altitude for the simulation (ft)  :  ');
velocity = input('Enter the velocity for the simulation (ft/s):  ');

%% Initial guess for trim
%%
thrust = 5000;          % thrust, lbs
elevator = -0.09;       % elevator, degrees
alpha = 8.49;              % AOA, degrees
rudder = -0.01;             % rudder angle, degrees
aileron = 0.01;            % aileron, degrees

%% Find trim for Hifi model at desired altitude and velocity
%%
disp('Trimming High Fidelity Model:');
fi_flag_Simulink = 1;
[trim_state_hi, trim_thrust_hi, trim_control_hi, dLEF, xu_hi] = trim_F16(thrust, elevator, alpha, aileron, rudder, velocity, altitude);

%% Find the state space model for the hifi model at the desired alt and vel.
%%
trim_state_lin = trim_state_hi; trim_thrust_lin = trim_thrust_hi; trim_control_lin = trim_control_hi;
[A_hi,B_hi,C_hi,D_hi] = linmod('LIN_F16Block', [trim_state_lin; trim_thrust_lin; trim_control_lin(1); trim_control_lin(2); trim_control_lin(3); ...
		dLEF; -trim_state_lin(8)*180/pi], [trim_thrust_lin; trim_control_lin(1); trim_control_lin(2); trim_control_lin(3)]);

%% Find trim for Hifi model at desired altitude and velocity
%%
disp('Trimming Low Fidelity Model:');
fi_flag_Simulink = 0;
[trim_state_lo, trim_thrust_lo, trim_control_lo, dLEF, xu_lo] = trim_F16(thrust, elevator, alpha, aileron, rudder, velocity, altitude);

%% Find the state space model for the hifi model at the desired alt and vel.
%%
trim_state_lin = trim_state_lo; trim_thrust_lin = trim_thrust_lo; trim_control_lin = trim_control_lo;
[A_lo,B_lo,C_lo,D_lo] = linmod('LIN_F16Block', [trim_state_lin; trim_thrust_lin; trim_control_lin(1); trim_control_lin(2); trim_control_lin(3);...
		dLEF; -trim_state_lin(8)*180/pi], [trim_thrust_lin; trim_control_lin(1); trim_control_lin(2); trim_control_lin(3)]);

%% Make state space model
%%
SS_hi = ss(A_hi,B_hi,C_hi,D_hi);
SS_lo = ss(A_lo,B_lo,C_lo,D_lo);


%% Make MATLAB matrix
%%
mat_hi = [A_hi B_hi; C_hi D_hi];
mat_lo = [A_lo B_lo; C_lo D_lo];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Longitudal Directional %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Select the components that make up the longitude A matrix
%%
A_longitude_hi = mat_hi([3 5 7 8 11 13 14], [3 5 7 8 11 13 14]);
A_longitude_lo = mat_lo([3 5 7 8 11 13 14], [3 5 7 8 11 13 14]);

%% Select the components that make up the longitude B matrix
%%
B_longitude_hi = mat_hi([3 5 7 8 11 13 14], [19 20]);
B_longitude_lo = mat_lo([3 5 7 8 11 13 14], [19 20]);

%% Select the components that make up the longitude C matrix
%%
C_longitude_hi = mat_hi([21 23 25 26 29], [3 5 7 8 11 13 14]);
C_longitude_lo = mat_lo([21 23 25 26 29], [3 5 7 8 11 13 14]);

%% Select the components that make up the longitude D matrix
%%
D_longitude_hi = mat_hi([21 23 25 26 29], [19 20]);
D_longitude_lo = mat_lo([21 23 25 26 29], [19 20]);

SS_long_hi = ss(A_longitude_hi, B_longitude_hi, C_longitude_hi, D_longitude_hi);
SS_long_lo = ss(A_longitude_lo, B_longitude_lo, C_longitude_lo, D_longitude_lo);

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Lateral Directional %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Select the components that make up the lateral A matrix
%%
A_lateral_hi = mat_hi([4 6 7 9 10 12 13 15 16], [4 6 7 9 10 12 13 15 16]);
A_lateral_lo = mat_lo([4 6 7 9 10 12 13 15 16], [4 6 7 9 10 12 13 15 16]);

%% Select the components that make up the lateral B matrix
%%
B_lateral_hi = mat_hi([4 6 7 9 10 12 13 15 16], [19 21 22]);
B_lateral_lo = mat_lo([4 6 7 9 10 12 13 15 16], [19 21 22]);

%% Select the components that make up the lateral C matrix
%%
C_lateral_hi = mat_hi([22 24 25 27 28 30], [4 6 7 9 10 12 13 15 16]);
C_lateral_lo = mat_lo([22 24 25 27 28 30], [4 6 7 9 10 12 13 15 16]);

%% Select the components that make up the lateral D matrix
%%
D_lateral_hi = mat_hi([22 24 25 27 28 30], [19 21 22]);
D_lateral_lo = mat_lo([22 24 25 27 28 30], [19 21 22]);

SS_lat_hi = ss(A_lateral_hi, B_lateral_hi, C_lateral_hi, D_lateral_hi);
SS_lat_lo = ss(A_lateral_lo, B_lateral_lo, C_lateral_lo, D_lateral_lo);

%% Make longitudal direction SYSTEM matrix
%%
sys_long_hi = pck(A_longitude_hi, B_longitude_hi, C_longitude_hi, D_longitude_hi);
sys_long_lo = pck(A_longitude_lo, B_longitude_lo, C_longitude_lo, D_longitude_lo);

%% Make lateral direction SYSTEM matrix and Find poles for hifi
%%
sys_lat_hi = pck(A_lateral_hi, B_lateral_hi, C_lateral_hi, D_lateral_hi);

long_poles_hi = spoles(sys_long_hi);
lat_poles_hi = spoles(sys_lat_hi);



%% Make lateral direction SYSTEM matrix and Find poles for lofi
%%
sys_lat_lo = pck(A_lateral_lo, B_lateral_lo, C_lateral_lo, D_lateral_lo);

long_poles_lo = spoles(sys_long_lo);
lat_poles_lo = spoles(sys_lat_lo);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Display results


clc;

% disp(sprintf('Altitude: %.3f ft.', altitude));
% disp(sprintf('Velocity: %.3f ft/s\n\n', velocity));
% 
% disp('For HIFI Model:  ');
% disp('Longitudal Direction:  ');
% disp(newline);
% 
% disp('A =')
% for i=1:length( A_longitude_hi(:,1) )
%     mprintf([ A_longitude_hi(i,:) ],'  %.3e ')
% end %for
% 
% disp('B =')
% for i=1:length( B_longitude_hi(:,1) )
%     mprintf([ B_longitude_hi(i,:) ],'  %.3e ')
% end %for
% 
% disp('C =')
% for i=1:length( C_longitude_hi(:,1) )
%     mprintf([ C_longitude_hi(i,:) ],'  %.3e ')
% end %for
% 
% disp('D =')
% for i=1:length( D_longitude_hi(:,1) )
%     mprintf([ D_longitude_hi(i,:) ],'  %.3e ')
% end %for
% 
% rifd(long_poles_hi)
% 
% disp(newline);
% 
% disp('Lateral Direaction:  ');
% 
% disp(newline);
% 
% disp('A =')
% for i=1:length( A_lateral_hi(:,1) )
%     mprintf([ A_lateral_hi(i,:) ],'  %.3e ')
% end %for
% 
% disp('B =')
% for i=1:length( B_lateral_hi(:,1) )
%     mprintf([ B_lateral_hi(i,:) ],'  %.3e ')
% end %for
% 
% disp('C =')
% for i=1:length( C_lateral_hi(:,1) )
%     mprintf([ C_lateral_hi(i,:) ],'  %.3e ')
% end %for
% 
% disp('D =')
% for i=1:length( D_lateral_hi(:,1) )
%     mprintf([ D_lateral_hi(i,:) ],'  %.3e ')
% end %for
% 
% rifd(lat_poles_hi)
% 
% disp(newline);
% disp(newline);
% disp('For LOFI Model:  ');
% disp('Longitudal Direction:  ');
% disp(newline);
% 
% disp('A =')
% for i=1:length( A_longitude_lo(:,1) )
%     mprintf([ A_longitude_lo(i,:) ],'  %.3e ')
% end %for
% 
% disp('B =')
% for i=1:length( B_longitude_lo(:,1) )
%     mprintf([ B_longitude_lo(i,:) ],'  %.3e ')
% end %for
% 
% disp('C =')
% for i=1:length( C_longitude_lo(:,1) )
%     mprintf([ C_longitude_lo(i,:) ],'  %.3e ')
% end %for
% 
% disp('D =')
% for i=1:length( D_longitude_lo(:,1) )
%     mprintf([ D_longitude_lo(i,:) ],'  %.3e ')
% end %for
% 
% % Display the real, imaginary, frequency (magnitude) and damping ratios
% rifd(long_poles_lo)
% 
% disp(newline);
% 
% disp('Lateral Direaction:  ');
% 
% disp(newline);
% 
% disp('A =')
% for i=1:length( A_lateral_lo(:,1) )
%     mprintf([ A_lateral_lo(i,:) ],'  %.3e ')
% end %for
% 
% disp('B =')
% for i=1:length( B_lateral_lo(:,1) )
%     mprintf([ B_lateral_lo(i,:) ],'  %.3e ')
% end %for
% 
% disp('C =')
% for i=1:length( C_lateral_lo(:,1) )
%     mprintf([ C_lateral_lo(i,:) ],'  %.3e ')
% end %for
% 
% disp('D =')
% for i=1:length( D_lateral_lo(:,1) )
%     mprintf([ D_lateral_lo(i,:) ],'  %.3e ')
% end %for
% 
% % Display the real, imaginary, frequency (magnitude) and damping ratios
% rifd(lat_poles_lo)
% 
% %% All Poles
% figure(1); 
% pzmap(SS_hi, 'r', SS_lo, 'b');
% title_string = sprintf('Altitude = %.2f ft Velocity = %.2f ft/s\nAll Poles\n Blue = lofi Red = hifi.', altitude, velocity);
% title(title_string);
% sgrid;
% 
% %% Long. Poles
% %%
% figure(2); 
% pzmap(SS_long_hi, 'r', SS_long_lo, 'b');
% title_string = sprintf('Altitude = %.2f ft Velocity = %.2f ft/s\nLongitudal Directional Poles\n Blue = lofi Red = hifi.', altitude, velocity);
% title(title_string);
% sgrid;
% 
% %% Lat. Poles
% %%
% figure(3); 
% pzmap(SS_lat_hi, 'r', SS_lat_lo, 'b');
% title_string = sprintf('Altitude = %.2f ft Velocity = %.2f ft/s\nLateral Directional Poles\n Blue = lofi Red = hifi.', altitude, velocity);
% title(title_string);
% sgrid;

% Create Bode Plots

% omega = logspace(-2,2,100);
% 
% sysg_lat_hi = frsp(sys_lat_hi,omega);
% sysg_lat_lo = frsp(sys_lat_lo,omega);
% 
% sysg_long_hi = frsp(sys_long_hi,omega);
% sysg_long_lo = frsp(sys_long_lo,omega);

% figure;
% BodeCount = 0;
% for state = 1:1:5
%     for control = 1:1:2
%         BodeCount = BodeCount +1;
%         title_string = sprintf('Bode Plot #%d\n State = %d\n Control = %d', BodeCount,state,control);
%         vplot('bode', sel(sysg_long_hi,state,control), 'b--', sel(sysg_long_lo,state,control), 'r');
%         disp(title_string);
%         legend('hifi', 'lofi');
%         pause;
%     end
% end
% 
% for state = 1:1:6
%     for control = 1:1:3
%         BodeCount = BodeCount + 1;
%         title_string = sprintf('Bode Plot #%d\n State = %d\n Control = %d', BodeCount,state,control);
%         vplot('bode', sel(sysg_lat_hi,state,control), 'b--', sel(sysg_lat_lo,state,control), 'r');
%         disp(title_string);
%         legend('hifi', 'lofi');
%         pause;
%     end
% end

% transferfunctions=tf(SS_lo);
% elevator=minreal(transferfunctions(19,2));
% opt=stepDataOptions('StepAmplitude', -1);
% t=[0:0.01:5];
% y= step(elevator,opt,t);
% figure(1)
% figure(4); 
% plot(t,y)
% figure(5); 
% pzmap(elevator)

red_sys_lon=reduce_lon(A_lo,C_longitude_lo);
red_sys_lat=reduce_lat(A_lo,C_lateral_lo);
red_sys_sp=reduce_sp(A_lo,C_lo);
[a_lat,b_lat,c_lat,d_lat]=ssdata(red_sys_lat);
ss_ar=ss(a_lat,b_lat(:,1),c_lat,d_lat(:,2));
ss_dr=ss(a_lat,b_lat(:,2),c_lat,d_lat(:,2));

dt=0.001;
t_ar=0:dt:5;
u_ar=zeros(1,5/dt+1);

for i=1/dt:2/dt
    u_ar(i)=1;
end
figure(1);
ar=lsim(ss_ar,u_ar,t_ar);
for i=1:4
     subplot(4,1,i)
     plot(ar(:,i,1))
     xlim([0, 5000])
end

t_dr=0:dt:20;
u_dr=zeros(1,20/dt+1);

for i=2/dt:3/dt
    u_dr(:,i)=5;
end
for i=3/dt:4/dt
    u_dr(:,i)=-5;
end
figure(2);
dr=lsim(ss_dr,u_dr,t_dr);
for i=1:4
     subplot(4,1,i)
     plot(dr(:,i,1))
     xlim([0 20000])
end

t_sp=0:dt:10;
u_sp=zeros(1,10/dt+1);
for i=2/dt:3/dt
    u_sp(i)=1;
end
figure(3);
sp=lsim(red_sys_lon,u_sp,t_sp)
for i=1:4
     subplot(4,1,i)
     plot(sp(:,i,1))
     xlim([0 10000])
end
t_ph=0:dt:300;
u_ph=zeros(1,300/dt+1);
for i=2/dt:3/dt
    u_ph(i)=1;
end
figure(4);
ph=lsim(red_sys_lon,u_ph,t_ph);
for i=1:4
     subplot(4,1,i)
     plot(ph(:,i,1))
     xlim([0 300000])
end
t_spi=0:dt:300;
u_spi=zeros(1,300/dt+1);
for i=1/dt:5/dt
    u_spi(i)=10;
end
figure(5);
spi=lsim(ss_ar,u_ph,t_ph);
for i=1:4
     subplot(4,1,i)
     plot(spi(:,i,1))
     xlim([0 300000])
end
% figure(1);
% [x,t]=step(red_sys_sp);
% plot(t,x(:,2))
% figure(2);
% [y,time]=step(red_sys_lon);
% plot(t,y(1:length(t),4))
% figure(3);
% step(red_sys_lon)
% figure(4);
% impulse(red_sys_lon)
% figure(5);
% ar=step(red_sys_lat, 800);
% for i=1:4
%     subplot(4,1,i)
%     plot(ar(:,i,1))
% end
% figure(6);
% dr=impulse(red_sys_lat);
% for i=1:4
%     subplot(4,1,i)
%     plot(dr(:,i,1))
% end


[a_lon,b_lon,c_lon,d_lon]=ssdata(red_sys_lon);
[a_lat,b_lat,c_lat,d_lat]=ssdata(red_sys_lat);
damp(a_lon)
damp(a_lat)

%Chapter 7
[a_sp, b_sp, c_sp, d_sp]=ssdata(red_sys_sp);
c_sp=eye(2);

K=place(a_sp, b_sp, [-2.743-4.75102i,-2.743+4.75102i]);
a_new_sp=a_sp-b_sp*K;

sys_sp_new=ss(a_new_sp,b_sp,c_sp,d_sp);
tf_sys=tf(sys_sp_new);
tf_q=tf_sys(2);
s=tf('s');
z=zero(tf_q);
tf_new=tf_sys*(s+4.1148)/(s-z);
dt=0.001;
t=0:dt:3;
u=[0 zeros(1,1/dt) ones(1,2/dt)];
figure(8);
lsim(tf_new(1),u,t)
figure(9);
lsim(tf_new(2),u,t)


sys_new=feedback(K(2)*red_sys_sp,[1 1]);
sys_new_2=feedback(K(1)*sys_new,[1 1]);

CAP=(5.4864^2/182.88)*9.80665*0.2430;
DB=0.2430-2*0.5/5.4864;

function red_sys_lon=reduce_lon(A_lo,C_longitude_lo)
    A_reduced_lon=[A_lo(7,[7 8 5 11 14]); A_lo(8,[7 8 5 11 14]); A_lo(5,[7 8 5 11 14]); A_lo(11,[7 8 5 11 14]); A_lo(14,[7 8 5 11 14])];
    A_ac_lon=A_reduced_lon(1:4,1:4);
    B_ac_lon=A_reduced_lon(1:4,5);
%     C_reduced_lon=[C_lo(7,[7 8 5 11 14]); C_lo(8,[7 8 5 11 14]); C_lo(5,[7 8 5 11 14]); C_lo(11,[7 8 5 11 14]); C_lo(14,[7 8 5 11 14])];
%     C_ac_lon=A_reduced_lon(1:4,1:4);
%     D_ac_lon=A_reduced_lon(1:4,5);
    C_ac_lon=C_longitude_lo([3 4 2 5],[3 4 2 5]);
    D_ac_lon=zeros(4,1);
    red_sys_lon=ss(A_ac_lon,B_ac_lon,C_ac_lon,D_ac_lon);
end

function red_sys_lat=reduce_lat(A_lo,C_lateral_lo)
    A_reduced_lat=[A_lo(9,[9 4 10 12 15 16]); A_lo(4,[9 4 10 12 15 16]); A_lo(10,[9 4 10 12 15 16]); A_lo(12,[9 4 10 12 15 16]); A_lo(15,[9 4 10 12 15 16]); A_lo(16,[9 4 10 12 15 16])];
    A_ac_lat=A_reduced_lat(1:4,1:4);
    B_ac_lat=A_reduced_lat(1:4,5:6);
    %C_reduced_lat=[C_lo(9,[9 4 10 12 15 16]); C_lo(4,[9 4 10 12 15 16]); C_lo(10,[9 4 10 12 15 16]); C_lo(12,[9 4 10 12 15 16]); C_lo(15,[9 4 10 12 15 16]); C_lo(16,[9 4 10 12 15 16])];
    %C_ac_lat=A_reduced_lat(1:4,1:4);
    %D_ac_lat=A_reduced_lat(1:4,5:6);
    C_ac_lat = C_lateral_lo([4 1 5 6],[4 1 5 6]);
    D_ac_lat = zeros(4,2);
    red_sys_lat=ss(A_ac_lat,B_ac_lat,C_ac_lat,D_ac_lat);
end

function red_sys_sp=reduce_sp(A_lo,C_longitude_lo)
    A_reduced_sp=[A_lo(8,[8 11 14]); A_lo(11,[8 11 14]); A_lo(14,[8 11 14])];
    A_ac_sp=A_reduced_sp(1:2,1:2);
    B_ac_sp=A_reduced_sp(1:2,3);
%     C_reduced_sp=[C_lo(8,[8 11 14]); C_lo(11,[8 11 14]); C_lo(14,[8 11 14])];
%     C_ac_sp=A_reduced_sp(1:2,1:2);
%     D_ac_sp=A_reduced_sp(1:2,3);
    C_ac_sp=C_longitude_lo([4 5],[4 5]);
    D_ac_sp=zeros(2,1);
    red_sys_sp=ss(A_ac_sp,B_ac_sp,C_ac_sp,D_ac_sp);
end

