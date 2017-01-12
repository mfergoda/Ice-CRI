% Joins IORs of Wagner and Zasetsky

!pwd

load Water_Zasetsky_253K.txt
load Water_Wagner_252K.txt;
load Water_Wagner_258K.txt;

% Decide on the region limits
wcut1 = 900;
wcut2 = 1000;

% Interpolate Wagner
fW252 = (258-253)/(258-252);
fW258 = (253-252)/(258-252);
Water_Wagner_253K = [Water_Wagner_252K(:,1) Water_Wagner_252K(:,2:3)*fW252+Water_Wagner_258K(:,2:3)*fW258];

% Extract the "pure" and "mixed" regions
IWpure = find(Water_Wagner_253K(:,1) > wcut2);
IZpure = find(Water_Zasetsky_253K(:,1)< wcut1);
IWmixd = find(Water_Wagner_253K(:,1)   >= wcut1 & Water_Wagner_253K(:,1)   <= wcut2);
IZmixd = find(Water_Zasetsky_253K(:,1) >= wcut1 & Water_Zasetsky_253K(:,1) <= wcut2);

% Interpolate Wagner onto the Zasetsky grid and do the merging
Water_Wagner_253K_Zgrid = interp1(Water_Wagner_253K(:,1),Water_Wagner_253K(:,2:3),Water_Zasetsky_253K(IZmixd,1),'linear');
Nmix = length(IZmixd);
f_Wagner = (1:Nmix)'/Nmix;
Water_Hybrid_253K_wnum = Water_Zasetsky_253K(IZmixd,1);
Water_Hybrid_253K_n = f_Wagner.*Water_Wagner_253K_Zgrid(:,1) + (1-f_Wagner).*Water_Zasetsky_253K(IZmixd,2);
Water_Hybrid_253K_k = f_Wagner.*Water_Wagner_253K_Zgrid(:,2) + (1-f_Wagner).*Water_Zasetsky_253K(IZmixd,3);
Water_Hybrid_253K_mixd = [Water_Hybrid_253K_wnum Water_Hybrid_253K_n Water_Hybrid_253K_k];

% Combine the pure and mixed regions
Water_Hybrid_253K = [Water_Zasetsky_253K(IZpure,:); Water_Hybrid_253K_mixd; flipud(Water_Wagner_253K(IWpure,:))];

% Graphics
for i = 2:3
    figure(i)
    plot( ... 
        Water_Wagner_252K(:,1),Water_Wagner_252K(:,i), 'x', ...
        Water_Wagner_258K(:,1),Water_Wagner_258K(:,i), '+', ...
        Water_Wagner_253K(:,1),Water_Wagner_253K(:,i), 'o', ...
        Water_Zasetsky_253K(:,1),Water_Zasetsky_253K(:,i), '*', ...
        Water_Hybrid_253K(:,1),Water_Hybrid_253K(:,i), ...
        'linewidth',1);
    legend('W252','W258','W253','Z253','Hybrid')
    grid
end

% Save it
save 'Water_Hybrid_253K.txt' Water_Hybrid_253K -ascii; % this is the "iors.txt" for makemieset.m