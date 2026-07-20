

clear all
close all

states = shaperead('usastatehi.shp','UseGeoCoords',true); %

cd('/Users/nlm136/Desktop/NASA_CMS/lateral_transport/')

% README.TXT
%%%%%% OCO2-MIP LNLGIS%%%%%%%%%
%   The OCO-2 MIP project is making these fluxes available for use by
%   the general scientific community. Users are expected to contact each
%   modeling group before using their fluxes in a publication or
%   scientific presentation. If the ensemble mean or standard deviation
%   are used, users should contact all modelers.
% 
%   These v10 MIP fluxes are very preliminary, and there is no citation
%   for them at this time. Please contact the individual modeler listed
%   below if you want to use these fluxes in a manuscript. 
% 
% MODEL	     MODELER(S)
% 
% Baker	     David Baker <david.f.baker@noaa.gov>
% CAMS	     Frédéric Chevallier <Frederic.Chevallier@lsce.ipsl.fr>
% CSU	     Andrew Schuh <aschuh@atmos.colostate.edu>
% CT	     Andy Jacobson <andy.jacobson@noaa.gov>
% OU	     Sean Crowell <scrowell@ou.edu>, Helene Peiro
% UT	     Feng Deng <dengf@atmosp.physics.utoronto.ca>
% WOMBAT	     Michael Bertolacci <m.bertolacci@gmail.com>, Andrew Zammit Mangion <azm@uow.edu.au>, Noel Cressie <ncressie@uow.edu.au>
% 
% EnsMean	     Ensemble-mean fluxes (even weighting of each model)
% EnsStd	     Ensemble standard deviation (even weighting of each model
% Each netCDF file has a structure like this:
% 
%   dimensions:
%         latitude = 180 ;
%         longitude = 360 ;
%         time = 48 ;
%         date_component = 3 ;
%   variables:
%         short time(time) ;
%         float land(time, latitude, longitude) ;
%                 land:units = "gC per m2 per year" ;
%         float ocean(time, latitude, longitude) ;
%                 ocean:units = "gC per m2 per year" ;
%         float net(time, latitude, longitude) ;
%                 net:units = "gC per m2 per year" ;
%         float latitude(latitude) ;
%         float longitude(longitude) ;
%         short start_date(time, date_component) ;
% 
% The "net" variable is ocean + land.

% Make an ensemble mean by month, averaging over the specified year(s)

year_f = 2015:2020; % original files are 2015 - 2020

year_s = [2015:2020]; % can be one or more years

oco2_models={'AMES','BAKER','CAMS','CMS FLUX','COLA','CSU','CT','JHU','LoFI','NIES','OU','TM5 4DVAR','UT','WOMBAT'}

for y = 1:length(year_s)
    yr = year_s(y);
for m = 1:12

for j=1:14
    switch j
        case 1
flnc='../data/OCO_2_v10MIP_gridded_fluxes_LNLGIS/Ames_gridded_fluxes_LNLGIS.nc4';
model = 'AMES';
        case 2
flnc='../data/OCO_2_v10MIP_gridded_fluxes_LNLGIS/Baker_gridded_fluxes_LNLGIS.nc4';
model = 'BAKER';
        case 3
flnc='../data/OCO_2_v10MIP_gridded_fluxes_LNLGIS/CAMS_gridded_fluxes_LNLGIS.nc4';
model = 'CAMS';
        case 4
flnc='../data/OCO_2_v10MIP_gridded_fluxes_LNLGIS/CMS_FLUX_gridded_fluxes_LNLGIS.nc4';
model = 'CMS FLUX';
        case 5
flnc='../data/OCO_2_v10MIP_gridded_fluxes_LNLGIS/COLA_gridded_fluxes_LNLGIS.nc4';
model = 'COLA';
        case 6
flnc='../data/OCO_2_v10MIP_gridded_fluxes_LNLGIS/CSU_gridded_fluxes_LNLGIS.nc4';
model = 'CSU';
        case 7
flnc='../data/OCO_2_v10MIP_gridded_fluxes_LNLGIS/CT_gridded_fluxes_LNLGIS.nc4';
model = 'CT';
        case 8
flnc='../data/OCO_2_v10MIP_gridded_fluxes_LNLGIS/JHU_gridded_fluxes_LNLGIS.nc4';
model = 'JHU';
        case 9
flnc='../data/OCO_2_v10MIP_gridded_fluxes_LNLGIS/LoFI_gridded_fluxes_LNLGIS.nc4';
model = 'LoFI';
        case 10
flnc='../data/OCO_2_v10MIP_gridded_fluxes_LNLGIS/NIES_gridded_fluxes_LNLGIS.nc4';
model = 'NIES';
        case 11
flnc='../data/OCO_2_v10MIP_gridded_fluxes_LNLGIS/OU_gridded_fluxes_LNLGIS.nc4';
model = 'OU';
        case 12
flnc='../data/OCO_2_v10MIP_gridded_fluxes_LNLGIS/TM5_4DVAR_gridded_fluxes_LNLGIS.nc4';
model = 'TM5 4DVAR';
        case 13
flnc='../data/OCO_2_v10MIP_gridded_fluxes_LNLGIS/UT_gridded_fluxes_LNLGIS.nc4';
model = 'UT';
        case 14
flnc='../data/OCO_2_v10MIP_gridded_fluxes_LNLGIS/WOMBAT_gridded_fluxes_LNLGIS.nc4';
model = 'WOMBAT';
    end

invModelNames={'AMES','BAKER','CAMS','CMS FLUX','COLA','CSU','CT','JHU','LoFI','NIES','OU','TM5 4DVAR','UT','WOMBAT'};

% flnc='../data/OCO_2_v10MIP_gridded_fluxes_LNLGIS/EnsMean_gridded_fluxes_LNLGIS.nc4';
% model = 'EnsMean';

% EnsMean does not have time variable
% monthly 1/2015 - 12/2020
% one of them had start dates in the middle of the months instead of the beginning 
% LoFI: 72 time steps, no start_date variable in the file, presumably the same

info = ncinfo(flnc);
disp(info)
info.Variables.Name

lat = ncread(flnc,'latitude');
lon = ncread(flnc,'longitude');
%start_date = ncread(flnc,'start_date'); %LoFI doesn't have this
time = ncread(flnc,'time');
% https://gml.noaa.gov/ccgg/OCO2_v10mip/download.php
land = ncread(flnc,'land');
ocean = ncread(flnc,'ocean');
net = ncread(flnc,'net'); % ocean + land

[LonGrid, LatGrid] = meshgrid(lon, lat);
stateTotals = struct();

for k = 1:length(states)
    % Extract state name and polygon
    stateName = states(k).Name;
    latPoly = states(k).Lat;
    lonPoly = states(k).Lon;

    % Create a mask: true for grid cells inside the polygon
    inMask = inpolygon(LonGrid, LatGrid, lonPoly, latPoly);

    % Apply the mask to your data
   % maskedData = mean(net,3)'; % time mean 2015 - 2020
    maskedData = net(:,:,m+(12*(y-1)))'; % select one month

    % Handle NaNs or missing values
    maskedData(~inMask) = NaN;

    % Sum total for this state (ignoring NaNs)
    stateSum = nansum(maskedData(:)); % doesn't take into account the area

    R = 6.371*10^6; % Earth radius in meters
    dlat = abs(lat(2) - lat(1));
    dlon = abs(lon(2) - lon(1));

    % Area per cell in m² (approximate)
    cellArea = (pi/180) * R^2 * abs(sind(lat + dlat/2) - sind(lat - dlat/2))' * dlon;

    % Broadcast to match grid
    [~, areaGrid] = meshgrid(lon, cellArea);
    stateSum = nansum(nansum(maskedData .* areaGrid)); % Multiply data by area before summing

   % flux = mean(net,3)' .* areaGrid ; % g C year^{-1} in each grid cell

    % s the total to the output struct
    stateTotals(k).Name = stateName;
    stateTotals(k).Total = stateSum; % g C year^{-1}
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

% Initialize totals
%regionalTotals = zeros(length(regionNames), 1);

% Loop through each region
for r = 1:length(regionNames)
    stateList = regionStates{r};

    % Logical mask for states in this region
    mask = ismember(allStateNames, stateList);

    % Compute total using the mask
    regionalTotals(r,m,y,j) = sum(allTotals(mask));
end



end % for j = 1:14 (models)

end % month
end % year

%%

% regionalTotals dimensions:
% 7 regions x 12 months x 6 years x 14 models
regionalTotals=regionalTotals* 10^(-12); % Tg C / yr

regionalT=regionalTotals;
% Add 8th region = sum of first 7 regions
regionalT(8,:,:,:) = nansum(regionalT(1:7,:,:,:),1);

% regionalT dimensions:
% 8 regions x 12 months x 6 years x 14 models

% Days in each month
daysInMonth = [31 28 31 30 31 30 31 31 30 31 30 31];

% Reshape weights for broadcasting
weights = reshape(daysInMonth,[1 12 1 1]);

% Weighted monthly mean, then average over years
regionalC = squeeze( ...
    nanmean( ...
        nansum(regionalT .* weights,2) ./ ...
        nansum(~isnan(regionalT) .* weights,2) ...
    ,3) );
% Result dimensions:
% 8 regions x 14 models

% Add 15th "model" = ensemble median across models 1:14
regionalC(:,15) = median(regionalC(:,1:14),2,'omitnan');
% Result dimensions:
% 8 regions x 15 models


% Average over years (preserving monthly structure)
regionalM = squeeze(nanmean(regionalT,3));

% Result after this step:
% 8 regions x 12 months x 14 models

% Add 15th model = ensemble median across models
regionalM(:,:,15) = ...
    median(regionalM(:,:,1:14),3,'omitnan') ;

% Final dimensions:
% 8 regions x 12 months x 15 models

ens_median_OCO2_MIP = regionalM; % 8 regions x 12 months x 15 models
array_for_mean_plot = regionalC; % 8 regions x 15 models

ens_mean_OCO2_MIP = mean(mean(regionalTotals,3),4);%* 10^(-12); % average over year_s and models
%ens_median_OCO2_MIP = median(mean(regionalTotals,3),4)* 10^(-12); % average over year_s and models
% so this is 7 regions x 12 months

%array_for_mean_plot = squeeze(squeeze(mean(mean(regionalTotals,2),3)))* 10^(-12); %  average month and year

% save inversions_2015_2020_new.mat array_for_mean_plot % THIS
% save ens_mean_inversion_2015_2020.mat ens_mean_OCO2_MIP
% save ens_median_inversion_2015_2020_new.mat ens_median_OCO2_MIP % THIS

%%

fh = figure(100);
clf(fh);  % Clear any old content
% [ha, pos] = tight_subplot(Nh, Nw, gap, marg_h, marg_w)
fh.Position = [50, 50, 1200, 800];  % bigger window for more space
[ha,pos]=tight_subplot(4,3,[0.05 0.04],[0.07 0.03],[0.1 0.03]);

ens_mean = ens_mean_OCO2_MIP  ; %convert from gC/yr to TgC/yr 
%%

format longG
mean(ens_mean, 2) % average over the months to keep units TgC/yr

% Units of the inversion results are TgC/yr and they are every month, so we
% need to average instead of summing to get the total for the year.
% For the bottom-up data, it's all annual, TgC/yr.  We need to keep the
% units in TgC/yr and AVERAGE to get the total for the year. 

load('../lateral_transport/state_level_data.mat');
temp = (mean(regionalComponents.ff_and_ippu(:,min(year_s)-min(year_f)+1:max(year_s)-min(year_f)+1),2)); 
% DO NOT divide by 12, see above
% take the mean of the selected years 
% assume even distribution across the months for now
fossil = repmat(temp,1,12);

mean(ens_mean+fossil, 2); 
mean(ens_mean, 2)
mean(fossil, 2)

nbe = ens_mean ; % it's negative -360 so they must have subtracted out fossil already
nce = ens_mean + fossil ; % NCE

for m = 1:12 
    if m==12; axes(ha(1)); % plot DJF, MAM, JJA, SON
    else axes(ha(m+1));
    end
    ax = axesm('mercator','MapLatLimit',[24 50],'MapLonLimit',[-125 -66]);
    setm(ax,'Frame','on','Grid','off','MeridianLabel','on','ParallelLabel','on');
    axis off; tightmap
    
    % Assign region values for this month
   % regionVals = ens_mean(:, m);
    regionVals = nce(:, m);
    
    % Normalize color scale for visual consistency
    clim = [min(nce(:)), max(nce(:))];
    cmap = parula(100); % Choose colormap 
    %%%
cmap = [140,81,10; 191,129,45; 223,194,125; 246,232,195; 256,256,256; 199,234,229; 128,205,193; ...
    53,151,143; 1,102,94]./256;
cmap_one_sided = [256,256,256; 199,234,229; 128,205,193; 53,151,143; 1,102,94]./256;;
% We want to spread these 5 "knots" into 9 output colors:
n = 100;
% Interpolate between the 5 colors:
x = linspace(1,5,5);              % original indices
xi = linspace(1,5,n);             % desired 9-level indices
cmap = interp1(x, cmap_one_sided, xi, 'linear');  % gives 100×3 matrix
cmap = flipud(cmap);
%%%
    % Draw each state with its region's color
    for s = 1:length(states)
        stateName = states(s).Name;
        regionIdx = find(cellfun(@(rs) any(strcmp(stateName, rs)), regionStates));
        
        if ~isempty(regionIdx)
            val = regionVals(regionIdx);
            colorIdx = round((val - clim(1)) / (clim(2) - clim(1)) * (size(cmap,1)-1)) + 1;
            colorIdx = min(max(colorIdx, 1), size(cmap,1)); % clamp
            fillm(states(s).Lat, states(s).Lon, cmap(colorIdx,:)); % , 'EdgeColor', 'none'
        else
            fillm(states(s).Lat, states(s).Lon, [0.8 0.8 0.8]); % gray for unmatched
        end
    end

    colormap(cmap);
    c = colorbar;
    c.Label.String = 'CO_2 flux (TgC/yr)'; % Tg = 10^{12} g
    caxis(clim);
    title(sprintf('Mean OCO-2 MIP + FF - Month %02d', m));
    text(-0.4, 0.5, num2str(mean(sum(nce(:,m)))))
end


%%
oco2_mip = squeeze(mean(regionalTotals,3))* 10^(-12); % average over year_s

% save oco2_mip_2015_2020_median.mat oco2_mip