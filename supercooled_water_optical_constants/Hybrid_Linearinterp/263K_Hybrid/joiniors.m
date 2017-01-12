% Joins IORs of Wagner and Zasetsky

!pwd

load Water_Zasetsky_263K.txt
load Water_Wagner_258K.txt;
load Water_Wagner_269K.txt;

% Decide on the region limits
wcut1 = 900;
wcut2 = 1000;

% Interpolate Wagner
fW258 = (269-263)/(269-258);
fW269 = (263-258)/(269-258);
Water_Wagner_263K = [Water_Wagner_258K(:,1) Water_Wagner_258K(:,2:3)*fW258+Water_Wagner_269K(:,2:3)*fW269];

% Extract the "pure" and "mixed" regions
IWpure = find(Water_Wagner_263K(:,1) > wcut2);
IZpure = find(Water_Zasetsky_263K(:,1)< wcut1);
IWmixd = find(Water_Wagner_263K(:,1)   >= wcut1 & Water_Wagner_263K(:,1)   <= wcut2);
IZmixd = find(Water_Zasetsky_263K(:,1) >= wcut1 & Water_Zasetsky_263K(:,1) <= wcut2);

% Interpolate Wagner onto the Zasetsky grid and do the merging
Water_Wagner_263K_Zgrid = interp1(Water_Wagner_263K(:,1),Water_Wagner_263K(:,2:3),Water_Zasetsky_263K(IZmixd,1),'linear');
Nmix = length(IZmixd);
f_Wagner = (1:Nmix)'/Nmix;
Water_Hybrid_263K_wnum = Water_Zasetsky_263K(IZmixd,1);
Water_Hybrid_263K_n = f_Wagner.*Water_Wagner_263K_Zgrid(:,1) + (1-f_Wagner).*Water_Zasetsky_263K(IZmixd,2);
Water_Hybrid_263K_k = f_Wagner.*Water_Wagner_263K_Zgrid(:,2) + (1-f_Wagner).*Water_Zasetsky_263K(IZmixd,3);
Water_Hybrid_263K_mixd = [Water_Hybrid_263K_wnum Water_Hybrid_263K_n Water_Hybrid_263K_k];

% Combine the pure and mixed regions
Water_Hybrid_263K = [Water_Zasetsky_263K(IZpure,:); Water_Hybrid_263K_mixd; flipud(Water_Wagner_263K(IWpure,:))];

% Graphics
for i = 2:3
    figure(i)
    plot( ... 
        Water_Wagner_258K(:,1),Water_Wagner_258K(:,i), 'x', ...
        Water_Wagner_269K(:,1),Water_Wagner_269K(:,i), '+', ...
        Water_Wagner_263K(:,1),Water_Wagner_263K(:,i), 'o', ...
        Water_Zasetsky_263K(:,1),Water_Zasetsky_263K(:,i), '*', ...
        Water_Hybrid_263K(:,1),Water_Hybrid_263K(:,i), ...
        'linewidth',1);
    legend('W258','W269','W263','Z263','Hybrid')
    grid
end

% Save it
save 'Water_Hybrid_263K.txt' Water_Hybrid_263K -ascii; % this is the "iors.txt" for makemieset.m