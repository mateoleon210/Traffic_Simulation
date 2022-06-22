function[Ptls,greenPtls,redPtls, yellowPtls] =tlOperator(tt, offset, cycle, tls, Ptls, iPtls, gPtls)
% natural state for traffic lights is being red, only when they turn green
% then we switch their position (not their graphing position) so that they
% no longer interact with cars
greenPtls = [0,0];
redPtls = [0,0];
yellowPtls = [0,0];

greencounter = 0;             % indicates how many traffic lights are green 
redcounter = 0;                 % indicates how many traffuc lights are red
yellowcounter = 0;           % indicates how many traffuc lights are yellow

far_vector = [100000,10];  % whenever a light turns green, its position will be set so that it is very far away so that it doesn't interfere with the cars


for i= 1:tls                              % loop through all traffic lights 
    if tt >= (i-1)*offset  &&  tt <= cycle/2 + (i-1)*offset %green 
        Ptls(i,:) = far_vector;                   % takes care of positions

        greencounter = greencounter + 1;
        greenPtls(greencounter,:) = gPtls(i,:);
        
    else %red
        Ptls(i,:) = iPtls(i,:);                   % takes care of positions

        if  tt >= cycle/2 + (i-1)*offset && tt <= cycle/2 + (i-1)*offset +4
        yellowcounter = yellowcounter + 1;
        yellowPtls(yellowcounter,:) = gPtls(i,:);
        end

        redcounter = redcounter + 1;
        redPtls(redcounter,:) = gPtls(i,:);

    end
end



