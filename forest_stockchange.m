

clear all
close all

% Filename
filename = 'county_level_FRF_and_LCF_flux_in_MMTC_2015-2020_20230711.csv';

% Read the table
dataTable = readtable(filename);

% Extract columns
fips        = dataTable.fips;	
statecd     = dataTable.statecd;
Years       = dataTable.year;
totalFlux   = dataTable.Total_C_flux;

years = 2015:2020;
nyears = length(years);
nstates = max(statecd);

% Aggregate by state and year
totalFlux_State = nan(nstates, nyears);

for j = 1:nyears
    for i = 1:nstates
        totalFlux_State(i,j) = sum(totalFlux(statecd == i & Years == years(j)), 'omitnan');
    end
end

% State map (from util.py)
stateMap = containers.Map(...
    [1, 2, 4, 5, 6, 8, 9, 10, 11, 12, 13, 15, 16, 17, 18, 19, 20, 21, 22, 23, ...
     24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, ...
     42, 44, 45, 46, 47, 48, 49, 50, 51, 53, 54, 55, 56], ...
    {'Alabama','Alaska','Arizona','Arkansas','California','Colorado','Connecticut','Delaware','District Of Columbia','Florida', ...
     'Georgia','Hawaii','Idaho','Illinois','Indiana','Iowa','Kansas','Kentucky','Louisiana','Maine', ...
     'Maryland','Massachusetts','Michigan','Minnesota','Mississippi','Missouri','Montana','Nebraska','Nevada','New Hampshire', ...
     'New Jersey','New Mexico','New York','North Carolina','North Dakota','Ohio','Oklahoma','Oregon', ...
     'Pennsylvania','Rhode Island','South Carolina','South Dakota','Tennessee','Texas','Utah','Vermont', ...
     'Virginia','Washington','West Virginia','Wisconsin','Wyoming'});

% Build stateTotals struct array for each year
stateTotals = struct('Name', {}, 'Total', {});
count = 0;
for j = 1:nyears
    for i = 1:nstates
        if isKey(stateMap, i)
            count = count + 1;
            stateTotals(count).Name = stateMap(i);
            stateTotals(count).Year = years(j);
            stateTotals(count).Total = totalFlux_State(i, j);
        end
    end
end

% Convert to table for easier access
stateTable = struct2table(stateTotals);

% Load state shapefile
states = shaperead('usastatehi', 'UseGeoCoords', true);

% Create colormap
cmap_one_sided_9_levels = [
    59, 76, 192;
    68, 90, 204;
    77, 104, 215;
    87, 117, 225;
    98, 130, 234;
    108, 142, 241;
    119, 154, 247;
    130, 165, 251;
    255, 255, 255
]/255;

% Choose year to plot
targetYear = 2020;

% Get values for plotting
allTotals = nan(length(states),1);
colorIdx = nan(length(states),1);

for k = 1:length(states)
    stateName = states(k).Name;
    idx = strcmp(stateTable.Name, stateName) & stateTable.Year == targetYear;

    if any(idx)
        value = stateTable.Total(idx);
        allTotals(k) = value;

        % Bin values into 9 color levels
        if value < -140
            colorIdx(k) = 1;
        elseif value < -120
            colorIdx(k) = 2;
        elseif value < -100
            colorIdx(k) = 3;
        elseif value < -80
            colorIdx(k) = 4;
        elseif value < -60
            colorIdx(k) = 5;
        elseif value < -40
            colorIdx(k) = 6;
        elseif value < -20
            colorIdx(k) = 7;
        elseif value < 0
            colorIdx(k) = 8;
        else
            colorIdx(k) = 9;
        end
    end
end

% Plot the map
figure;
axesm('mercator','MapLatLimit',[25 50],'MapLonLimit',[-125 -66]);
framem on; gridm off; axis off; tightmap;

for k = 1:length(states)
    if ~isnan(colorIdx(k))
        fillm(states(k).Lat, states(k).Lon, cmap_one_sided_9_levels(colorIdx(k),:));
    else
        fillm(states(k).Lat, states(k).Lon, [0.8 0.8 0.8]);
    end
end

% Colorbar
colormap(cmap_one_sided_9_levels);
cb = colorbar;
cb.Ticks = linspace(1/9, 8/9, 9);
cb.TickLabels = { ...
    '< -140', '-140 to -120', '-120 to -100', '-100 to -80', ...
     '-80 to -60', '-60 to -40', '-40 to -20', '-20 to 0', '> 0'};
cb.TickDirection = 'out';
cb.Box = 'off';
title(['Forest Stockchange Totals (Tg/yr) – ', num2str(targetYear)]);

% Regional totals
regionNames = {'Northwest', 'Southwest', 'N GreatPlains', 'S GreatPlains', ...
    'Midwest', 'Southeast', 'Northeast'};

regionStates = {
    {'Washington', 'Idaho', 'Oregon'}, ...
    {'California', 'Arizona', 'New Mexico', 'Colorado', 'Utah', 'Nevada'}, ...
    {'Wyoming', 'Montana', 'North Dakota', 'South Dakota', 'Nebraska'}, ...
    {'Kansas', 'Oklahoma', 'Texas'}, ...
    {'Minnesota', 'Wisconsin', 'Iowa', 'Missouri', 'Illinois', 'Indiana', 'Ohio'}, ...
    {'Louisiana', 'Arkansas', 'Alabama', 'Mississippi', 'Georgia', 'Florida', ...
     'South Carolina', 'North Carolina', 'Tennessee', 'Kentucky'}, ...
    {'West Virginia', 'Virginia', 'Pennsylvania', 'Maryland', 'New Jersey', ...
     'New York', 'New Hampshire', 'Vermont', 'Rhode Island', 'Massachusetts', ...
     'Maine', 'Connecticut','District Of Columbia'}};

regionalTotals = nan(length(regionNames), nyears);

for j = 1:nyears
    thisYear = years(j);
    for r = 1:length(regionNames)
        stateList = regionStates{r};
        idx = ismember(stateTable.Name, stateList) & stateTable.Year == thisYear;
        regionalTotals(r,j) = sum(stateTable.Total(idx), 'omitnan');
    end
end

disp('Regional totals by year:');
disp(array2table(regionalTotals, 'VariableNames', cellstr(string(years)), ...
    'RowNames', regionNames));


%%

regionNames
regionalTotals

return
% only run "on purpose"


regionalComponents.forest_stockchange = regionalTotals;

% save forest_stockchange.mat regionalComponents regionNames years