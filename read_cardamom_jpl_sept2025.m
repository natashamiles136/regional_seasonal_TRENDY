
% clear all
close all

% cycle through these four options by hand and then save them all
% === Config ===
 baseDir = '/Users/nlm136/Desktop/NASA_CMS/data/CARDAMOM/CARDAMOM_CONUS_DIURNAL_FLUXES_JUL25/MONTHLY/NBE/CARDAMOM';
% baseDir = '/Users/nlm136/Desktop/NASA_CMS/data/CARDAMOM/CARDAMOM_CONUS_DIURNAL_FLUXES_JUL25/MONTHLY/NEE/CARDAMOM';
% baseDir = '/Users/nlm136/Desktop/NASA_CMS/data/CARDAMOM/CARDAMOM_CONUS_DIURNAL_FLUXES_JUL25_EXP1/MONTHLY/NBE/CARDAMOM';
% baseDir = '/Users/nlm136/Desktop/NASA_CMS/data/CARDAMOM/CARDAMOM_CONUS_DIURNAL_FLUXES_JUL25_EXP1/MONTHLY/NEE/CARDAMOM';

% per Anthony Bloom Oct 2025, EXP1 = BASE, and the other one is with CROP HARVEST!
years = 2015:2020;
months = 1:12;

% --- Inspect one file to get grid size ---
testFile = fullfile(baseDir, num2str(years(1)), '01.nc');
lat = ncread(testFile, 'latitude');
lon = ncread(testFile, 'longitude');
nlat = length(lat);
nlon = length(lon);
nyears = length(years);
nmonths = length(months);

% info = ncinfo(testFile)
% 'Kg C/Km^2/sec'

% Preallocate [lat x lon x month x year]
NBE_all = nan(nlat, nlon, nmonths, nyears);
unc_all = nan(nlat, nlon, nmonths, nyears);

% --- Loop over years and months ---
for iy = 1:nyears
    y = years(iy);
    for im = 1:nmonths
        % File name (zero-padded month)
        fName = fullfile(baseDir, num2str(y), sprintf('%02d.nc', im));
        
        if isfile(fName)
            % Read CO2_Flux (NBE)
            data = ncread(fName, 'CO2_Flux');
            data_2 = ncread(fName, 'Uncertainty');
            
            % Store
            FLUX_all_temp(:,:,im,iy) = data';
            unc_all_temp(:,:,im,iy) = data_2';
        else
            warning('File not found: %s', fName);
        end
    end
end

% convert Kg C/Km^2/sec to Tg C/m^2/yr

secsPerYear = 365.25 * 24 * 3600;      % = 31,536,000 (use 365.25*24*3600 for climatological year)
convFactor = secsPerYear * 1e-15;   % kg to Tg (1e-9) and km^-2 to m^-2 (1e-6)
FLUX_all = FLUX_all_temp * convFactor;      % now in Tg C / m^2 / yr
unc_all = unc_all_temp * convFactor;      % now in Tg C / m^2 / yr

cmap = [140,81,10; 191,129,45; 223,194,125; 246,232,195; 256,256,256; 199,234,229; 128,205,193; ...
    53,151,143; 1,102,94]./256;
cmap_one_sided = [256,256,256; 199,234,229; 128,205,193; 53,151,143; 1,102,94]./256;
cmap=flipud(cmap);
n = 9;cmap5=cmap_one_sided;
% Interpolate between the 5 colors:
x = linspace(1,5,5);              % original indices
xi = linspace(1,5,n);             % desired 9-level indices
cmap_one_sided_9_levels = interp1(x, cmap5, xi, 'linear');  % gives 9×3 matrix
cmap_one_sided_9_levels = flipud(cmap_one_sided_9_levels);

states = shaperead('usastatehi.shp','UseGeoCoords',true); %

[LonGrid, LatGrid] = meshgrid(lon, lat);
R = 6.371*10^6; % Earth radius in meters
dlat = abs(lat(2) - lat(1));
dlon = abs(lon(2) - lon(1));

% Area per cell in m² (approximate)
cellArea = (pi/180) * R^2 * abs(sind(lat + dlat/2) - sind(lat - dlat/2))' * dlon;

% Broadcast to match grid
[~, areaGrid] = meshgrid(lon, cellArea);

% 2015 - 2020
flux = mean(mean(FLUX_all,3),4) .* areaGrid ; % Tg C year^{-1} in each grid cell
flux = mean(FLUX_all(:,:,8,:),4) .* areaGrid ; % August composite for the plot instead
% FLUX Tg/m2/yr, flux Tg/yr
uncertainty = mean(mean(unc_all,3),4) .* areaGrid ; 

fh = figure;
fh.Position = [50, 50, 1200, 800];
plot_flux = flux; % 2015 - 2020 mean
sum(isnan(plot_flux(:)))
plot_flux(isnan(plot_flux))=0; % so imagesc plots as white
title_text = 'CARDAMOM-JPL (TgC/yr)';
limits=[-1.5 1.5]; %
limits = [-5 5];
maplatlimit = [24 50];
maplonlimit = [-125 -66];
h=imagesc(lon,lat,plot_flux);axis xy;
hold on;
geoshow((states),'defaultfacecolor','none','defaultedgecolor','k');
colormap((cmap));
%clim([limits]);
xlim(maplonlimit);ylim(maplatlimit);
colorbar;title(title_text);set(gca,'fontsize',12);

fh = figure;
fh.Position = [50, 50, 1200, 800];
plot_unc = uncertainty; % 2015 - 2020 mean
plot_unc(isnan(plot_unc))=0; % so imagesc plots as white
title_text = 'CARDAMOM-JPL UNCERTAINTY (UNKNOWN TgC/yr)';
limits=[0 1500]; %
maplatlimit = [24 50];
maplonlimit = [-125 -66];
h=imagesc(lon,lat,plot_unc);axis xy;
hold on;
geoshow((states),'defaultfacecolor','none','defaultedgecolor','k');
colormap((cmap));
%clim([limits]);
xlim(maplonlimit);ylim(maplatlimit);
colorbar;title(title_text);set(gca,'fontsize',12);

FLUX = mean(FLUX_all,4); % composite of 2015 - 2020
% FLUX Tg/m2/yr, flux Tg/yr

for m = 1:12 % 1:length(FLUX) % 

    stateTotals = struct();

    for k = 1:length(states)
        % Extract state name and polygon
        stateName = states(k).Name;
        latPoly = states(k).Lat;
        lonPoly = states(k).Lon;

        % Create a mask: true for grid cells inside the polygon
        inMask = inpolygon(LonGrid, LatGrid, lonPoly, latPoly);

        % Apply the mask to your data
        maskedData = FLUX(:,:,m); % FLUX Tg/m2/yr, flux Tg/yr

        % Handle NaNs or missing values
        maskedData(~inMask) = NaN;

        % Sum total for this state (ignoring NaNs)
        %stateSum = nansum(maskedData(:)); % doesn't take into account the area
        stateSum = nansum(nansum(maskedData .* areaGrid)); % Multiply data by area before summing

        % Save the total to the output struct
        stateTotals(k).Name = stateName;
        stateTotals(k).Total = stateSum; % Tg C year^{-1}
    end

    stateTable = struct2table(stateTotals);  % Has columns: Name, Total
    allTotals = stateTable.Total;

    regionNames = {'Northwest', 'Southwest', 'N GreatPlains', 'S GreatPlains', ...
        'Midwest', 'Southeast', 'Northeast'};

    regionStates = {
        {'Washington', 'Idaho', 'Oregon'}, ...
        {'California', 'Arizona', 'New Mexico', 'Colorado', 'Utah', 'Nevada'}, ...
        {'Wyoming', 'Montana', 'North Dakota', 'South Dakota', 'Nebraska'}, ...
        {'Kansas', 'Oklahoma', 'Texas'}, ...
        {'Minnesota', 'Wisconsin', 'Iowa', 'Missouri', 'Illinois', 'Indiana', 'Ohio','Michigan'}, ...
        {'Louisiana', 'Arkansas', 'Alabama', 'Mississippi', 'Georgia', 'Florida', ...
        'South Carolina', 'North Carolina', 'Tennessee', 'Kentucky'}, ...
        {'West Virginia', 'Virginia', 'Pennsylvania', 'Maryland', 'New Jersey', ...
        'New York', 'New Hampshire', 'Vermont', 'Rhode Island', 'Massachusetts', ...
        'Maine', 'Connecticut','Delaware','District of Columbia'}
        };

    % Get state names from your data
    allStateNames = {states.Name};  % or from stateTable.Name

    % Loop through each region
    for r = 1:length(regionNames)
        stateList = regionStates{r};
        % Logical mask for states in this region
        mask = ismember(allStateNames, stateList);
        % Compute total using the mask
        regionalTotals(r,m) = sum(allTotals(mask));
    end

end  % m


regionalTotals_composite = regionalTotals;
% for variable name to be consistent with previous code


% % % Ken : sign convention for NEE is different than that for NBE
% % % CARD_JPL_NEE=-1*regionalTotals_composite
% % % CARD_JPL_EXP1_NEE=-1*regionalTotals_composite 

% CARD_JPL_NBE_BASE=regionalTotals_composite
% CARD_JPL_NBE_CROP_HARVEST=regionalTotals_composite

% save CARDAMOM_JPL.mat CARD_JPL_NBE CARD_JPL_EXP1_NBE CARD_JPL_NEE CARD_JPL_EXP1_NEE
% save CARDAMOM_JPL_OCT2025.mat CARD_JPL_NBE_BASE CARD_JPL_NBE_CROP_HARVEST


cd('/Users/nlm136/Desktop/NASA_CMS/lateral_transport/')


