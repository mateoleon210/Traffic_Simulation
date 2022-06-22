% Main code:
% Code setup to try any number of cars per lane. To do this, change ncpl.
% also, feel free to input any array of offsets to try

clear

% World parameters
    dt=1;                           % change in time: one second at a time
    tmax =200;                      % how long simulation will run for
    tls = 5;                        % number of traffic lights
    ncpl = 8;                       % number of cars per lane 
    nc = ncpl*tls;                  % total number of cars
    %offset = 8;                    % offset
    cycle = 150;                    % traffic light cycle length

 
offsetArray = [0 5 10 15 20];

len= length(offsetArray);

Energy_array = zeros(2,len);    % stores the energy spent with each different offset for a given number of cars per lane ncpl

for h = 1:len
    offset = offsetArray(1,h);

    Vel =  zeros(nc+tls+1,2);   % initial velocity for every car
    Acc =  zeros(nc+tls+1,2);   % initial acceleraiton for everycar    
 
    % Energy Parameters 
    Energy = zeros(nc,1);  % initialize
    m = 1500;     % average mass of a car
    g = 9.8;      % m/s2 
    Mu = 0.7;     % Coefficient of kinnetic friction
    EI = 16705;   % energy spent iddiling per sec 


% Storing matrix initiation
    Px=zeros(tmax,nc); % Position tensor for all cars at any time
    Vx=zeros(tmax,nc); % Velocity tensor for all cars at any time
    Ax=zeros(tmax,nc); % Acceleration tensor for all cars at any time
    Ix=zeros(tmax,nc); % keeps track of what car is interacting with what
    Dx=zeros(tmax,nc,nc+tls+1);
   

% Columbia information
    %location of the destination   
     PosC = [1500,10]; 

   
% Create cars and positions
    Pcars = ones(nc,2);
    Pcars(:,2) = 10;   % all cars will be at a y of 10
    p = 81;             % position of car 1
    dist = 85 ;        % how far apart will every car be

    for i = 1:tls        % First cars on teh intersection
        Pcars(i,1) = p;
        p = p + dist;
    end
        Index = tls+1;
    for i = 2:ncpl       % creaste cars right behind
        for j = 1:tls
        Pcars(Index,1) =  Pcars(j,1) - 10*(i-1);
        Index = Index + 1;
        end
    end

% Create traffic lights and positions
    iPtls = ones(tls,2);
    gPtls = ones(tls,2);       
    ptls= 85;                 % position of traffic light 1
    dist_tls = 85;            % how far apart will every car be
    

    for i = 1:tls
        iPtls(i,:) = [ptls, 10];  % all traffic lights will be at a y of 10
        gPtls(i,:) = [ptls, 20];      % traffic lights graphed at a y of 20
        ptls = ptls + dist_tls;           % positions of the traffic lights
    end

    Ptls = iPtls;  % Ptls will change when red but iPtls will stay the same

% traffic lights
    tt = 0;  % traffic light timer 

    d = ptls;

    I_Pos=[ Pcars; Ptls; PosC];  % Gather all the positions for every car + traffic light + columbia 

    Pos = I_Pos;                  % Pos will change at every time iteration


    % initialize distance matrix
    D = zeros(nc,nc+tls+1);       % cars vertically will interact with every other item horizontally
    inc = 100000;

    incumbent = inc * ones(nc,1); % this is used to determine who the closest car is at evey point
    I = zeros(nc,1); % Matrix of indexes for interaction


t =0;% traffic light operation
while Pos(nc-(tls-1))< 500
    t = t+1;
    % when the traffic light is red, the traffic light will act as a static
    % object on the way. However, when the traffic light is green the traffic light
    % will be set to a very far away location as if it didnt exist
    
    tt= tt+1;         % traffic light timer: keeps track of time for lights       

    [Ptls,greenPtls,redPtls, yellowPtls] = tlOperator(tt, offset,cycle, tls, Ptls, iPtls, gPtls);

       scatter(greenPtls(:,1),greenPtls(:,2), 60,'filled','green','c');
       hold on
       scatter(redPtls(:,1),redPtls(:,2), 60,'filled','red','c');
       hold on
       scatter(yellowPtls(:,1),yellowPtls(:,2), 60,'filled','yellow','c');
       hold on
                                                               

    if tt/cycle - 1 == 0            % restart traffic light cycle
        tt=0;
    end
   
    Pos(nc+1 : nc+ tls , :) =Ptls;     % include position of the traffic lights on the Pos vector

    for i = 1:nc
        for j = 1:nc+tls+1
            D(i,j)= Pos(j)-Pos(i);
            if D(i,j) <=0
                D(i,j) =inc;
            end
        end
    end



    for i = 1 : nc                % decide who is the smallest distance apart   
          [p, I(i)] = min(D(i,:));
    end 
    
    for i = 1:nc
    [New_Posx, New_Velx, Accx, EnergyCar] = Potential11( Pos(i,1), Pos(I(i,1)), Vel(i,1), EI);

    Vel(i,1) = New_Velx;
    Pos(i,1) = New_Posx;

    % Px, Vx and Ax keep track pf the position, time, and acceleration for
    % every time step
    Px(t,1) = t;   % keep track of time 
    Vx(t,1) = t;
    Ax(t,1) = t;
    Ix(t,1) = t;
    Px(t,i+1) = Pos(i,1);    
    Vx(t,i+1) = Vel(i,1);
    Ax(t,i+1) = Accx;
    Dx(t,:,:) = D;       % D tracks all the distances.
    Ix(t,i+1) = I(i);    % I tracks the index of what every car is interacting with
        

    Energy(i)= Energy(i) + EnergyCar; 
    end 

    
    plot([0 d],[1 1],LineWidth=8,Color=[0.3010 0.7450 0.9330])
    hold on
    scatter(Pos(1:nc,1),Pos(1:nc,2),50,'filled','s','ColorVariable','y');
    hold on
    grid on
    grid minor 
    xlim([0 d])
    ylim([-100 100])
    title('time =', tt )
    xlabel('distance in meters') 
    set(gcf, 'Position', get(0, 'Screensize'));
    hold off
    pause(.1)

end

Total_energy = sum(Energy, 'all');

Energy_array(1,h) = offset
Energy_array(2,h) = Total_energy

end
