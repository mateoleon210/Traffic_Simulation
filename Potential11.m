function[New_Posx,  New_Velx,  Accx, EnergyCar] =Potential11(Pos1x,Pos2x,Vel1x, EI)


d = Pos2x - Pos1x;

Accx = sign(d-16);

New_Velx = Vel1x + Accx;



if New_Velx >= 4
    New_Velx = 4;
elseif New_Velx <= 0
    New_Velx = 0;
end

New_Posx = Pos1x + New_Velx;

% Energy 
    deltaPos = New_Posx -Pos1x;

EnergyI = 0;  % initialize it in case there is no idling 
EnergyS = 0;  % initialize it in case there is no movement
EnergyF = 0;  % initialize it in case there is no movement

if New_Posx <= 500 % objective, stop storing data after
    AvgVel = (New_Velx + Vel1x)/2;  %Average velocity for the time interval of one sec
    
    if   New_Velx - Vel1x > 0            % work from accelerating to speed.
        EnergyS = (1500/2)*(New_Velx - Vel1x)^2;     
    elseif New_Velx - Vel1x <= 0         % idiling will happen 
        EnergyI= EI;
    end 
    
    if AvgVel> 0                         % force of friction
        EnergyF =   deltaPos*(10291 + 0.459*AvgVel^2);
    end
end   
    EnergyCar  = EnergyS + EnergyI+ EnergyF;