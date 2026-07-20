
clear all
close all

% do_human = 0; do_livestock = 1;
% filename = '/Users/nlm136/Desktop/NASA_CMS/data/respiration/livestock_emissions_v2.nc';
% title_text = 'Livestock respiration (TgC yr-1)'; % 
% limits = [0 0.008];
% 
do_human = 1; do_livestock = 0;
filename = '/Users/nlm136/Desktop/NASA_CMS/data/respiration/human_emissions_density_v3.nc';
title_text = 'Human respiration (TgC yr-1)'; % 
% gC m-2 yr-1 are the units of the file, then multiply by the area of each
% grid cell in m2, then divide by 10^12
limits = [0 0.0008];


% info = ncinfo(filename);
% disp(info)
% info.Variables.Name

%%
info = ncinfo(filename);

fprintf('NetCDF file: %s\n\n', filename);

% Dimensions
fprintf('Dimensions:\n');
for i = 1:length(info.Dimensions)
    d = info.Dimensions(i);
    fprintf('  %s = %d\n', d.Name, d.Length);
end
fprintf('\n');

% Variables
fprintf('Variables:\n');
for i = 1:length(info.Variables)
    v = info.Variables(i);
    fprintf('  %s (%s)\n', v.Name, v.Datatype);
    for j = 1:length(v.Dimensions)
        fprintf('    Dimension: %s (%d)\n', ...
            v.Dimensions(j).Name, v.Dimensions(j).Length);
    end
end
fprintf('\n');

% Global attributes
fprintf('Global attributes:\n');
for i = 1:length(info.Attributes)
    fprintf('  %s = %s\n', info.Attributes(i).Name, string(info.Attributes(i).Value));
end
%%

lat = ncread(filename, 'y');
lon = ncread(filename, 'x');
yr = ncread(filename, 'year');
if do_livestock
    resp = ncread(filename,'mean_estimate');
    band = ncread(filename,'band');
    spatial_ref = ncread(filename,'spatial_ref');
    CV = ncread(filename,'CV');
end
if do_human
    resp = ncread(filename,'__xarray_dataarray_variable__');
    band = ncread(filename,'band');
    spatial_ref = ncread(filename,'spatial_ref');
end

nlat = length(lat);
nlon = length(lon);
nyears = length(yr);

% info = ncinfo(testFile)
% gC m^-2 yr^-1 ACTUALLY 10/10/2025

resp = resp .* 10^(-12); % convert from g to Tg

cmap = [140,81,10; 191,129,45; 223,194,125; 246,232,195; 256,256,256; 199,234,229; 128,205,193; ...
    53,151,143; 1,102,94]./256;
cmap_one_sided = [256,256,256; 199,234,229; 128,205,193; 53,151,143; 1,102,94]./256;
cmap=flipud(cmap);
n = 9;cmap5=cmap_one_sided;
% Interpolate between the 5 colors:
x = linspace(1,5,5);              % original indices
xi = linspace(1,5,n);             % desired 9-level indices
cmap_one_sided_9_levels = interp1(x, cmap5, xi, 'linear');  % gives 9×3 matrix
%cmap_one_sided_9_levels = flipud(cmap_one_sided_9_levels);

states = shaperead('usastatehi.shp','UseGeoCoords',true); %

[LonGrid, LatGrid] = meshgrid(lon, lat);
R = 6.371*10^6; % Earth radius in meters
dlat = abs(lat(2) - lat(1)); % 0.1 for human
dlon = abs(lon(2) - lon(1)); % 0.1 for human

% Area per cell in m² (approximate)
cellArea = (pi/180) * R^2 * abs(sind(lat + dlat/2) - sind(lat - dlat/2))' * dlon;

% Broadcast to match grid
[~, areaGrid] = meshgrid(lon, cellArea);

if do_human
% 2015 - 2020; 16:21 this is only correct for human respiration
% actually 2020 is not availble, it's all zeros in the file
% so this is 2015 - 2019 average
flux = squeeze(mean(resp(:,:,16:20),3))' .* areaGrid ; %  in each grid cell
end
if do_livestock
% 2015 - 2018; 15:18 (size(yr)=19, starting at 2000)
flux = squeeze(mean(resp(:,:,15:18),3))' .* areaGrid ; %  in each grid cell
end


fh = figure;
fh.Position = [50, 50, 1200, 800];
plot_flux = flux; %
sum(isnan(plot_flux(:)))
plot_flux(isnan(plot_flux))=0; % so imagesc plots as white
maplatlimit = [24 50];
maplonlimit = [-125 -66];
h=imagesc(lon,lat,plot_flux);axis xy;
hold on;
geoshow((states),'defaultfacecolor','none','defaultedgecolor','k');
colormap(cmap_one_sided_9_levels);
clim([limits]);
xlim(maplonlimit);ylim(maplatlimit);
colorbar;title(title_text);set(gca,'fontsize',12);

stateTotals = struct();

for k = 1:length(states)
    % Extract state name and polygon
    stateName = states(k).Name;
    latPoly = states(k).Lat;
    lonPoly = states(k).Lon;

    % Create a mask: true for grid cells inside the polygon
    inMask = inpolygon(LonGrid, LatGrid, lonPoly, latPoly);

    % Apply the mask to your data
    maskedData = flux(:,:);
    maskedArea = areaGrid;
    areaInside = nansum(nansum(areaGrid .* inMask));

    % Handle NaNs or missing values
    maskedData(~inMask) = NaN;
    maskedArea(~inMask) = NaN;

    % Sum total for this state (ignoring NaNs)
    %stateSum = nansum(maskedData(:)); % doesn't take into account the area
    stateSum = nansum(nansum(maskedData )); % 
    stateArea = nansum(nansum(maskedArea )); 
    areaInside = nansum(nansum(areaGrid .* inMask)); % same as stateArea

    % Save the total to the output struct
    stateTotals(k).Name = stateName;
    stateTotals(k).Total = stateSum; % Tg C year^{-1}
    stateTotals(k).Area = stateArea/1e6; % km^2
   
end

stateTable = struct2table(stateTotals);  % Has columns: Name, Total
allTotals = stateTable.Total;
% load US_State_Areas_km2.mat ; the Areas calculated above are somewhat low

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

% Get state names 
allStateNames = {states.Name};  % or from stateTable.Name

%for m = 1:12
    % Loop through each region
    for r = 1:length(regionNames)
        stateList = regionStates{r};
        % Logical mask for states in this region
        mask = ismember(allStateNames, stateList);
        % Compute total using the mask
        regionalC(r) = sum(allTotals(mask));
        % assume evenly distributed throughout the year, average to get the yearly total
        regionalArea_km2(r) = sum([stateTotals(mask).Area]); % km2
    end
%end

%regionalTotals(8,:)=sum(regionalTotals,1);

return

regionalFraction = regionalArea_km2 / sum(regionalArea_km2);
area_percent = regionalFraction *100

% save regional_area.mat area_percent


% for variable name to be consistent with previous code
% to be compatible with previous code, copy mean over years into 2015-2020

regionalTotals.human_respiration = (repmat(regionalC, 6, 1))'; % only 70% of calories come from crops directly ...
regionalComponents = regionalTotals;

% save human_resp_yinon_bar_on.mat regionalComponents % only worrying about this one
% save livestock_resp_yinon_bar_on.mat regionalComponents

cd('/Users/nlm136/Desktop/NASA_CMS/lateral_transport/')


