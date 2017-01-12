% Joins IORs of Wagner and Zasetsky

!pwd

load Water_Zasetsky_240K.txt
load Water_Wagner_238K.txt;
load Water_Wagner_252K.txt;

% Decide on the region limits
wcut1 = 900;
wcut2 = 1000;

% Interpolate Wagner
fW238 = (252-240)/(252-238);
fW252 = (240-238)/(252-238);
Water_Wagner_240K = [Water_Wagner_238K(:,1) Water_Wagner_238K(:,2:3)*fW238+Water_Wagner_252K(:,2:3)*fW252];

% Extract the "pure" and "mixed" regions
IWpure = find(Water_Wagner_240K(:,1) > wcut2);
IZpure = find(Water_Zasetsky_240K(:,1)< wcut1);
IWmixd = find(Water_Wagner_240K(:,1)   >= wcut1 & Water_Wagner_240K(:,1)   <= wcut2);
IZmixd = find(Water_Zasetsky_240K(:,1) >= wcut1 & Water_Zasetsky_240K(:,1) <= wcut2);

% Interpolate Wagner onto the Zasetsky grid and do the merging
Water_Wagner_240K_Zgrid = interp1(Water_Wagner_240K(:,1),Water_Wagner_240K(:,2:3),Water_Zasetsky_240K(IZmixd,1),'linear');
Nmix = length(IZmixd);
f_Wagner = (1:Nmix)'/Nmix;
Water_Hybrid_240K_wnum = Water_Zasetsky_240K(IZmixd,1);
Water_Hybrid_240K_n = f_Wagner.*Water_Wagner_240K_Zgrid(:,1) + (1-f_Wagner).*Water_Zasetsky_240K(IZmixd,2);
Water_Hybrid_240K_k = f_Wagner.*Water_Wagner_240K_Zgrid(:,2) + (1-f_Wagner).*Water_Zasetsky_240K(IZmixd,3);
Water_Hybrid_240K_mixd = [Water_Hybrid_240K_wnum Water_Hybrid_240K_n Water_Hybrid_240K_k];

% Combine the pure and mixed regions
Water_Hybrid_240K = [Water_Zasetsky_240K(IZpure,:); Water_Hybrid_240K_mixd; flipud(Water_Wagner_240K(IWpure,:))];

% Graphics
for i = 2:3
    figure(i)
    plot( ... 
        Water_Wagner_238K(:,1),Water_Wagner_238K(:,i), 'x', ...
        Water_Wagner_252K(:,1),Water_Wagner_252K(:,i), '+', ...
        Water_Wagner_240K(:,1),Water_Wagner_240K(:,i), 'o', ...
        Water_Zasetsky_240K(:,1),Water_Zasetsky_240K(:,i), '*', ...
        Water_Hybrid_240K(:,1),Water_Hybrid_240K(:,i), ...
        'linewidth',1);
    legend('W238','W252','W240','Z240','Hybrid')
    grid
end

% Save it
save 'Water_Hybrid_240K.txt' Water_Hybrid_240K -ascii; % this is the "iors.txt" for makemieset.m