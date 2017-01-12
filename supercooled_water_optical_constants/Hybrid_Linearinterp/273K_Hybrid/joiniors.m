% Joins IORs of Wagner, Bertie & Lan, and Zasetsky (yielding 273 K)

!pwd

Water_Zasetsky_273 = load ('Water_Zasetsky_273K.txt');
Water_Wagner_269 = load ('Water_Wagner_269K.txt');
Water_BL_298 = load ('Water_BL_298.txt');
Water_DW_300 = load('Water_DW_300.txt');

% Decide on the region limits
wcut1 = 900;
wcut2 = 1000;

% Interpolate DW to Wagner grid
Water_DWW_300_n = interp1(Water_DW_300(:,1),Water_DW_300(:,2),Water_Wagner_269(:,1));
Water_DWW_300_k = interp1(Water_DW_300(:,1),Water_DW_300(:,3),Water_Wagner_269(:,1));
Water_DWW_300 = [Water_Wagner_269(:,1) Water_DWW_300_n Water_DWW_300_k];

% Interpolate Wagner+DW to 273K
fW269 = (300-273)/(300-269)
fW300 = (273-269)/(300-269)
Water_Wagner_273 = [Water_Wagner_269(:,1) Water_Wagner_269(:,2:3)*fW269+Water_DWW_300(:,2:3)*fW300];

% Extract the "pure" and "mixed" regions
IWpure = find(Water_Wagner_273(:,1) > wcut2);
IZpure = find(Water_Zasetsky_273(:,1)< wcut1);
IWmixd = find(Water_Wagner_273(:,1)   >= wcut1 & Water_Wagner_273(:,1)   <= wcut2);
IZmixd = find(Water_Zasetsky_273(:,1) >= wcut1 & Water_Zasetsky_273(:,1) <= wcut2);

% Interpolate Wagner onto the Zasetsky grid and do the merging
Water_Wagner_273_Zgrid = interp1(Water_Wagner_273(:,1),Water_Wagner_273(:,2:3),Water_Zasetsky_273(IZmixd,1),'linear');
Nmix = length(IZmixd);
f_Wagner = (1:Nmix)'/Nmix;
Water_Hybrid_273_wnum = Water_Zasetsky_273(IZmixd,1);
Water_Hybrid_273_n = f_Wagner.*Water_Wagner_273_Zgrid(:,1) + (1-f_Wagner).*Water_Zasetsky_273(IZmixd,2);
Water_Hybrid_273_k = f_Wagner.*Water_Wagner_273_Zgrid(:,2) + (1-f_Wagner).*Water_Zasetsky_273(IZmixd,3);
Water_Hybrid_273_mixd = [Water_Hybrid_273_wnum Water_Hybrid_273_n Water_Hybrid_273_k];

% Combine the pure and mixed regions
Water_Hybrid_273 = [Water_Zasetsky_273(IZpure,:); Water_Hybrid_273_mixd; flipud(Water_Wagner_273(IWpure,:))];

% Graphics
for i = 2:3
    figure(i)
    plot( ... 
        Water_Wagner_269(:,1),Water_Wagner_269(:,i), 'x', ...
        Water_DWW_300(:,1),Water_DWW_300(:,i), '+', ...
        Water_Wagner_273(:,1),Water_Wagner_273(:,i), 'o', ...
        Water_Zasetsky_273(:,1),Water_Zasetsky_273(:,i), '*', ...
        Water_Hybrid_273(:,1),Water_Hybrid_273(:,i), ...
        'linewidth',1);
    legend('W269','DW300','W/DW273','Z273','Hybrid')
    grid
end


% plot(...
%     Water_Zasetsky_273(:,1),Water_Zasetsky_273(:,3),...
%     Water_Wagner_269(:,1),Water_Wagner_269(:,3),...
%     Water_Wagner_300(:,1),Water_Wagner_300(:,3),'o',...
%     Water_DW_300(:,1),Water_DW_300(:,3))
% legend('Z','W','W/DW','DW')


% Save the "iors.txt" for makemieset.m
save 'Water_Hybrid_273K.txt' Water_Hybrid_273 -ascii; 
save 'Water_Wagner_273K.txt' Water_Wagner_273 -ascii;