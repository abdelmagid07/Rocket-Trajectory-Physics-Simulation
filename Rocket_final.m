% Abdel A.
% Rocket Take 3 - Rocket Trajectory Simulation
% This simulates a rocket launch considering thrust, fuel burn,
% changing mass, gravity variation with altitude, and plots everything

clear all;
close all;
clc;

% Constants and Initial Conditions

gBase = -9.8;                  % Acceleration due to gravity at Earth's surface (m/s^2)
Radius_earth = 6.4e6;          % Earth's radius in meters

rocketMass = 1500;             % Dry mass of the rocket in kg
fuelMass = 2000;               % Initial fuel mass in kg
mass = rocketMass + fuelMass;  % Total initial mass in kg

burnRate = 5;                  % Fuel consumption rate in kg/s
timeStep = 1;                  % Time step size in seconds

launchAngle = 80;              % Launch angle in degrees from horizontal
thrust = 45000;                % Constant thrust produced by rocket in newtons

% Calculate thrust components along X and Y directions
thrustY = thrust * sind(launchAngle);  
thrustX = thrust * cosd(launchAngle);

%% Initialize Data Arrays

velX(1) = 0;       % Horizontal velocity (m/s)
velY(1) = 0;       % Vertical velocity (m/s)
vel(1) = 0;        % Total velocity magnitude (m/s)
acc(1) = 0;        % Acceleration magnitude (m/s^2)
alt(1) = 0;        % Altitude (m)
Downrange(1) = 0;  % Horizontal distance traveled (m)
timer(1) = 0;      % Time since launch (s)

i = 1;             % Loop counter

%% Simulation Loop
% Continue looping while vertical velocity is non-negative (ascending)

while velY(i) >= 0
    if fuelMass > 0
        % Calculate new vertical velocity with thrust and gravity
        velY(i+1) = velY(i) + (thrustY/mass + gBase * (Radius_earth/(Radius_earth + alt(i)))^2) * timeStep;
        % Calculate new horizontal velocity with thrust only 
        velX(i+1) = velX(i) + (thrustX / mass) * timeStep;
        
        % Burn fuel
        fuelMass = fuelMass - burnRate * timeStep;
        if fuelMass < 0
            fuelMass = 0; % Prevent negative fuel mass
        end
        x = i; % Record index at fuel burnout 
    else
        % No thrust, only gravity affects vertical velocity
        velY(i+1) = velY(i) + gBase * (Radius_earth/(Radius_earth + alt(i)))^2 * timeStep;
        % Horizontal velocity remains constant without thrust
        velX(i+1) = velX(i);
    end
    
    % Update total velocity magnitude
    vel(i+1) = sqrt(velX(i+1)^2 + velY(i+1)^2);
    
    % Calculate average velocities over time step for altitude and downrange calculation
    avgVelY = (velY(i+1) + velY(i)) / 2;
    avgVelX = (velX(i+1) + velX(i)) / 2;
    
    % Update altitude and downrange using average velocities
    alt(i+1) = alt(i) + avgVelY * timeStep;
    Downrange(i+1) = Downrange(i) + avgVelX * timeStep;
    
    % Calculate acceleration magnitude (rate of change of velocity)
    acc(i+1) = (vel(i+1) - vel(i)) / timeStep;
    
    % Update time
    timer(i+1) = timer(i) + timeStep;
    
    % Update mass (dry rocket + remaining fuel)
    mass = rocketMass + fuelMass;
    
    i = i + 1; % Increment loop counter
end

%% Display Results

fprintf('Immediately After Fuel Burnout:\n');
fprintf('Velocity = %.1f mph\nAltitude = %.1f miles\nRange = %.1f miles\nTime = %.1f seconds\n', ...
    vel(x)*3600/1609.34, alt(x)/1609.34, Downrange(x)/1609.34, timer(x));

fprintf('\nAt Maximum Altitude:\n');
fprintf('Velocity = %.1f mph\nAltitude = %.1f miles\nRange = %.1f miles\nTime = %.1f seconds\n', ...
    vel(end)*3600/1609.34, alt(end)/1609.34, Downrange(end)/1609.34, timer(end));

%% Plotting

figure(1);
plot(timer, alt, timer(x), alt(x), 'or');
title('Rocket Vertical Motion');
xlabel('Time (seconds)');
ylabel('Altitude (meters)');
grid on;

figure(2);
plot(timer, velY, timer(x), velY(x), 'or');
title('Vertical Velocity Over Time');
xlabel('Time (seconds)');
ylabel('Vertical Velocity (m/s)');
grid on;

figure(3);
plot(timer, Downrange, timer(x), Downrange(x), 'or');
title('Downrange Distance Over Time');
xlabel('Time (seconds)');
ylabel('Downrange Distance (meters)');
grid on;

figure(4);
plot(timer, velX, timer(x), velX(x), 'or');
title('Horizontal Velocity Over Time');
xlabel('Time (seconds)');
ylabel('Horizontal Velocity (m/s)');
grid on;
