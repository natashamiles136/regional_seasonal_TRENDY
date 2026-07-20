
clear all
close all

% Load mapping from state number to name 
% this came from Brendans util.py
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

% no mapping for 3 (AS), 7, 14, 43, 52 
% American Samoa (AS),Guam (GU), Northern Mariana Islands (MP), Puerto Rico (PR),  U.S. Virgin Islands (VI)

% no data for 3, 7, 11, 14, 15, 43, 52, 56 (11 is DC, 15 is Hawaii, 56 is Wyoming
% states surrounding Wyoming have very low forest harvest

% % Full list of 50 states + D.C.
% allStates = {'Alabama','Alaska','Arizona','Arkansas','California','Colorado',...
%     'Connecticut','Delaware','DistrictOfColumbia','Florida','Georgia','Hawaii','Idaho',...
%     'Illinois','Indiana','Iowa','Kansas','Kentucky','Louisiana','Maine','Maryland',...
%     'Massachusetts','Michigan','Minnesota','Mississippi','Missouri','Montana','Nebraska',...
%     'Nevada','NewHampshire','NewJersey','NewMexico','NewYork','NorthCarolina','NorthDakota',...
%     'Ohio','Oklahoma','Oregon','Pennsylvania','RhodeIsland','SouthCarolina','SouthDakota',...
%     'Tennessee','Texas','Utah','Vermont','Virginia','Washington','WestVirginia','Wisconsin','Wyoming'};


% Load file
filename = 'CMS_state_harvest_removals_082823.csv';
T = readtable(filename);

% Extract state numbers and values
stateNums = T{:,1};
values = T{:,2};

% Initialize struct array
stateTotals = struct('Name', {}, 'Total', {});

% Populate struct array
count = 0;
for i = 1:length(stateNums)
    stateNum = stateNums(i);
    if isKey(stateMap, stateNum)
        count = count + 1;
        stateTotals(count).Name = stateMap(stateNum);
        stateTotals(count).Total = values(i);
    else
        warning('Unknown state number: %d', stateNum);
    end
end


% Load state shapefile (lat/lon format)
states = shaperead('usastatehi', 'UseGeoCoords', true);  % Built-in in many MATLAB versions

% Convert struct to table for easier lookups
stateTable = struct2table(stateTotals);

% Create colormap (9-level sequential)
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
cmap_one_sided_9_levels = flipud(cmap_one_sided_9_levels);

% Match each state shape to the total harvest value
allTotals = nan(length(states),1);
colorIdx = nan(length(states),1);

% Loop through states to assign totals and color index
for k = 1:length(states)
    stateName = states(k).Name;
    idx = find(strcmp(stateTable.Name, stateName));

    if ~isempty(idx)
        value = stateTable.Total(idx);
        allTotals(k) = value;

        % Assign color category based on value
        if value < 3
            colorIdx(k) = 1;
        elseif value >= 3 && value < 4
            colorIdx(k) = 2;
        elseif value >= 4 && value < 5
            colorIdx(k) = 3;
        elseif value >= 5 && value < 6
            colorIdx(k) = 4;
        elseif value >= 6 && value < 7
            colorIdx(k) = 5;
        elseif value >= 7 && value < 8
            colorIdx(k) = 6;
        elseif value >= 8 && value < 9
            colorIdx(k) = 7;
        elseif value >= 9 && value < 10
            colorIdx(k) = 8;
        else
            colorIdx(k) = 9;
        end
    end
end

% Draw the map
f = figure;
f.Position = [100 100 540 400];
axesm('mercator','MapLatLimit',[25 50],'MapLonLimit',[-125 -66]); 
framem on; gridm off; axis off; tightmap;

for k = 1:length(states)
    if ~isnan(colorIdx(k))
        fillm(states(k).Lat, states(k).Lon, cmap_one_sided_9_levels(colorIdx(k),:));
    else
        fillm(states(k).Lat, states(k).Lon, [0.8 0.8 0.8]);  % Gray for missing
    end
end

% Colorbar setup (manually label ranges)
colormap(cmap_one_sided_9_levels);
cb = colorbar;
cb.Ticks = linspace(1/9, 8/9, 9);  % 9 ticks
cb.TickLabels = { ...
    '< 0', '0 to 1', '1 to 2', '2 to 3', ...
     '3 to 4', '4 to 5', '5 to 6', '6 to 7', '> 7'};
cb.TickDirection = 'out';
cb.Box = 'off';
title('Wood Harvest Totals (Tg/yr)');


%%%


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
    'Maine', 'Connecticut','District of Columbia'}
    };

% Get state names from your data
allStateNames = {states.Name};  

% Initialize totals
regionalTotals = zeros(length(regionNames),1);

% Loop through each region
for r = 1:length(regionNames)
    stateList = regionStates{r};

    % Logical mask for states in this region
    %mask = ismember(allStateNames, stateList);
   
    mask = ismember({stateTotals.Name}', stateList);

    % Subset of stateTotals
    tmp = stateTotals(mask);

    % Assign to struct with fields
   % regionalTotals(r).Name = regionNames{r};
    regionalTotals(r) = sum([tmp.Total]);
end


regionNames
regionalTotals


return


temporary = repmat(regionalTotals(:), 1, 6);
% 2015 - 2020 (assume each year is the same
years = 2015:2020;

regionalComponents.forest_harvest = -1*temporary; % removal from atm

% save forest_harvest.mat regionalComponents