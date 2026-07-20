% CONUS_data_create_regional.m

close all
clear all

components = {'forest_residual','PIC_SWDS_stockchange','wood_trade',...
    'crop_residual', 'crop_landfill_stockchange','crop_trade',...
    'river_emissions','lake_emissions','lake_river_burial','coastal_carbon_export'}

CONUS.forest_residual = 67.7; % Tg/yr
CONUS.PIC_SWDS_stockchange = -14.0 - 18.6; % Tg/yr
CONUS.wood_trade = 16.5 - 19.7; % Tg/yr

CONUS.crop_residual = 58; % Tg/yr with new human respiration numbers (Yinon)
% +8 is to account for the fact that only 70% of calories come from crops
% directly (removed)
CONUS.crop_landfill_stockchange = -0.9; % Tg/yr
CONUS.crop_trade = 15.1 - 65.4; % Tg/yr

CONUS.river_emissions = 69.3 ; % Tg/yr
CONUS.lake_emissions = 16.0; % Tg/yr
CONUS.lake_river_burial = -20.6; % Tg/yr
CONUS.coastal_carbon_export = -41.5; % Tg/yr

% calculate fractional regional area for the regions

regionNames = {'Northwest', 'Southwest', 'N GreatPlains', 'S GreatPlains', ...
    'Midwest', 'Southeast', 'Northeast'};

regionStates = {
    {'Washington', 'Idaho', 'Oregon'}, ...
    {'California', 'Arizona', 'NewMexico', 'Colorado', 'Utah', 'Nevada'}, ...
    {'Wyoming', 'Montana', 'NorthDakota', 'SouthDakota', 'Nebraska'}, ...
    {'Kansas', 'Oklahoma', 'Texas'}, ...
    {'Minnesota', 'Wisconsin', 'Iowa', 'Missouri', 'Illinois', 'Indiana', 'Ohio','Michigan'}, ...
    {'Louisiana', 'Arkansas', 'Alabama', 'Mississippi', 'Georgia', 'Florida', ...
    'SouthCarolina', 'NorthCarolina', 'Tennessee', 'Kentucky'}, ...
    {'WestVirginia', 'Virginia', 'Pennsylvania', 'Maryland', 'NewJersey', ...
    'NewYork', 'NewHampshire', 'Vermont', 'RhodeIsland', 'Massachusetts', ...
    'Maine', 'Connecticut','DistrictOfColumbia','Delaware'}
    };

% U.S. state land areas in km² (approx, from US Census data)
stateArea_km2 = containers.Map(...
    {'Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California', 'Colorado', ...
     'Connecticut', 'Delaware', 'DistrictOfColumbia', 'Florida', 'Georgia', ...
     'Hawaii', 'Idaho', 'Illinois', 'Indiana', 'Iowa', 'Kansas', 'Kentucky', ...
     'Louisiana', 'Maine', 'Maryland', 'Massachusetts', 'Michigan', 'Minnesota', ...
     'Mississippi', 'Missouri', 'Montana', 'Nebraska', 'Nevada', 'NewHampshire', ...
     'NewJersey', 'NewMexico', 'NewYork', 'NorthCarolina', 'NorthDakota', ...
     'Ohio', 'Oklahoma', 'Oregon', 'Pennsylvania', 'RhodeIsland', ...
     'SouthCarolina', 'SouthDakota', 'Tennessee', 'Texas', 'Utah', 'Vermont', ...
     'Virginia', 'Washington', 'WestVirginia', 'Wisconsin', 'Wyoming'}, ...
    [131171, 1477953, 294207, 134771, 403466, 268431, ...
     12542, 5047, 158, 138887, 149976, 28313, 216443, 143793, 94321, 145746, ...
     211754, 102269, 111898, 79883, 25142, 20202, 250487, 225163, ...
     121530, 178040, 376962, 200330, 284332, 23187, ...
     19047, 314917, 122057, 125920, 183108, ...
     106798, 181037, 254799, 116075, 2678, ...
     77857, 199729, 109153, 695662, 212819, 24906, ...
     102548, 184661, 62259, 145496, 253335]);

% U.S. state water areas (km²), from U.S. Census Bureau data
stateWaterArea_km2 = containers.Map( ...
    {'Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California', 'Colorado', ...
     'Connecticut', 'Delaware', 'DistrictOfColumbia', 'Florida', 'Georgia', ...
     'Hawaii', 'Idaho', 'Illinois', 'Indiana', 'Iowa', 'Kansas', 'Kentucky', ...
     'Louisiana', 'Maine', 'Maryland', 'Massachusetts', 'Michigan', 'Minnesota', ...
     'Mississippi', 'Missouri', 'Montana', 'Nebraska', 'Nevada', 'NewHampshire', ...
     'NewJersey', 'NewMexico', 'NewYork', 'NorthCarolina', 'NorthDakota', ...
     'Ohio', 'Oklahoma', 'Oregon', 'Pennsylvania', 'RhodeIsland', ...
     'SouthCarolina', 'SouthDakota', 'Tennessee', 'Texas', 'Utah', 'Vermont', ...
     'Virginia', 'Washington', 'WestVirginia', 'Wisconsin', 'Wyoming'}, ...
    [4595, 245383, 957, 3208, 20191, 1005, ...
     1816, 1322, 18, 31424, 4880, 11683, 2398, 6208, 1533, 1068, ...
     1392, 3460, 22964, 11824, 6978, 7110, 104050, 18924, ...
     3995, 2471, 3813, 1168, 1982, 1024, ...
     3352, 727, 19754, 13260, 4142, 1039, ...
     10610, 3226, 6176, 1332, ...
     5056, 1117, 2440, 19016, 7482, 799, ...
     8397, 12092, 482, 29403, 1912]);


% Compute total land area per region
numRegions = length(regionNames);
regionAreas = zeros(1, numRegions);
regionWater = zeros(1, numRegions);

for i = 1:numRegions
    states = regionStates{i};
    for j = 1:length(states)
        state = states{j};
        if isKey(stateArea_km2, state)
            regionAreas(i) = regionAreas(i) + stateArea_km2(state);
            regionWater(i) = regionWater(i) + stateWaterArea_km2(state);
        else
            warning('Missing area for state: %s', state);
        end
    end
end

% Calculate fractional area
totalArea = sum(regionAreas);
fractionalArea = regionAreas / totalArea;
totalWaterArea = sum(regionWater);
fractionalWaterArea = regionWater / totalWaterArea;
water_percent=fractionalWaterArea*100;

% save frArea.mat fractionalArea
% save frWaterArea.mat water_percent 

% Display results
fprintf('Region\t\tFractional Area\n');
for i = 1:numRegions
    fprintf('%-12s\t%.4f\n', regionNames{i}, fractionalArea(i));
end

% Calculate region-scaled carbon component totals
for i = 1:length(components)
    componentName = components{i};  % Fix: extract from cell
    for j = 1:length(regionNames)
        regionalTotals_annual.(componentName)(j) = CONUS.(componentName) * fractionalArea(j);
    end
end



years = 2015:2020
regionNames
regionalTotals_annual
% 
% for j=1:length(years)
% regionalTotals(j) = regionalTotals_annual;
% end
% 
% regionalTotals

return
% only run "on purpose"

% 2015 - 2020 (assume each year is the same

fields = fieldnames(regionalTotals_annual);

for i = 1:length(fields)
    field = fields{i};
    vec = regionalTotals_annual.(field);  % 1×7 vector
    % Convert to 7×6 by repeating the column 6 times
    regionalTotals.(field) = repmat(vec(:), 1, 6);  % vec(:) makes it a column vector
end

% These are all distributed uniformally over CONUS (so based on fractional
% area).  This distribution is not necessarily used in the final
% calculations.  

regionalComponents = regionalTotals

save CONUS_data.mat regionalComponents 