% read_livestock_resp_data.m

clear all
close all

threshold = 1;        % Threshold in standard deviations, 
cvThreshold = 0.2;%0.5;      % Minimum coefficient of variation, set to 0 to not filter based on this
ChooseState = 'Any';    % Set to a specific state like 'TEXAS' or 'Any'

% Read the CSV file
filename = 'livestock_resp_tCCO2_results_county_20240216.csv';  % <-- Replace with actual filename
T = readtable(filename);

% Extract needed columns
state    = string(T{:,1});
district = string(T{:,2});
county   = string(T{:,3});
year     = T{:,4};
value    = T{:,5};  % LivestockRespiration (ton C-CO2)

% Create a unique county ID using state, district, and county
countyID = state + " - " + district + " - " + county;
uniqueCounties = unique(countyID);

% Marker symbols to cycle through
markers = {'o', 's', 'd', '^', 'v', '>', '<', 'p', 'h', '+'};
nMarkers = length(markers);

% Set up figure
figure;
hold on;
legendEntries = {};

% Keep track of missing years
allYears = unique(year);
missingYearsSummary = [];

% Loop through each unique county
plotCount = 0;
for i = 1:length(uniqueCounties)
    thisCounty = uniqueCounties(i);
    
    % Get rows corresponding to this county
    idx = countyID == thisCounty;
    
    % Filter by state
    thisState = unique(state(idx));
    if ~(strcmp(ChooseState, 'Any') || strcmp(thisState, ChooseState))
        continue;
    end

    y = value(idx);
    t = year(idx);



    % Check for missing years
    missingYears = setdiff(allYears, t);
    if ~isempty(missingYears)
        missingYearsSummary = [missingYearsSummary; {thisCounty, missingYears}];
    end

    % Skip if less than 2 data points
    if sum(~isnan(y)) < 2
        continue;
    end

    mu = mean(y, 'omitnan');
    sigma = std(y, 'omitnan');
    deviationRatios = abs(y - mu) / sigma;
    maxRatio = max(deviationRatios);
    cv = sigma / abs(mu);

    % Filter counties based on criteria
    if maxRatio > threshold && cv > cvThreshold
        plotCount = plotCount + 1;
        marker = markers{mod(plotCount-1, nMarkers)+1};
        plot(t, y, ['-' marker], 'MarkerSize', 8, 'LineWidth', 1.5);
        
        legendLabel = sprintf('%s (max σ = %.2f, σ/μ = %.2f)', thisCounty, maxRatio, cv);
        legendEntries{end+1} = legendLabel;
    end
end

xlabel('Year');
ylabel('Livestock Respiration (ton C-CO₂)');
title(sprintf('Counties in %s with max σ > %.2f & σ/μ > %.2f', ...
    ChooseState, threshold, cvThreshold));
legend(legendEntries, 'Location', 'bestoutside');
set(gca,'FontSize',14)
grid on;

%%%%%%%%

disp('Counties with missing years:');
for i = 1:size(missingYearsSummary,1)
    countyName = missingYearsSummary{i,1};
    missing = missingYearsSummary{i,2};
    yearStr = strjoin(string(missing), ', ');
    fprintf('%s is missing years: %s\n', countyName, yearStr);
end

totalCounties = length(unique(countyID));
fprintf('Total number of unique counties: %d\n', totalCounties);


state
year 
value
state = cellfun(@(s) regexprep(lower(s), '(^|\s)([a-z])', '${upper($2)}'), state, 'UniformOutput', false);


states = shaperead('usastatehi.shp','UseGeoCoords',true); %
for i = 1:length(states)
     name = states(i).Name;   
      states(i).Name = strrep(name, ' ', '');                  % Remove spaces
end


years = 2015:2020;
regionNames = {'Northwest', 'Southwest', 'N GreatPlains', 'S GreatPlains', ...
    'Midwest', 'Southeast', 'Northeast'};
regionStates = {
    {'Washington', 'Idaho', 'Oregon'}, ...
    {'California', 'Arizona', 'NewMexico', 'Colorado', 'Utah', 'Nevada'}, ...
    {'Wyoming', 'Montana', 'NorthDakota', 'SouthDakota', 'Nebraska'}, ...
    {'Kansas', 'Oklahoma', 'Texas'}, ...
    {'Minnesota', 'Wisconsin', 'Iowa', 'Missouri', 'Illinois', 'Indiana', 'Ohio'}, ...
    {'Louisiana', 'Arkansas', 'Alabama', 'Mississippi', 'Georgia', 'Florida', ...
    'SouthCarolina', 'NorthCarolina', 'Tennessee', 'Kentucky','Michigan'}, ...
    {'WestVirginia', 'Virginia', 'Pennsylvania', 'Maryland', 'NewJersey', ...
    'NewYork', 'NewHampshire', 'Vermont', 'RhodeIsland', 'Massachusetts', ...
    'Maine', 'Connecticut','DistrictOfColumbia','Delaware'}
    };


for k = 1:length(states)
    stateName = states(k).Name;
    for j = 1:length(years)
        % Use strcmpi for case-insensitive string comparison
        indices = find(strcmpi(state, stateName) & year == years(j));
        state_total_by_year(k,j) = sum(value(indices));
    end
end

regional_total_by_year = zeros(length(regionNames), length(years));

for r = 1:length(regionNames)
    currentRegionStates = regionStates{r};
    for s = 1:length(currentRegionStates)
        stateName = currentRegionStates{s};

        % Find index in states matching this name
        stateIndex = find(strcmpi({states.Name}, stateName));

        if isempty(stateIndex)
            warning('State "%s" not found in states struct.', stateName);
            continue
        end

        % Add that state's yearly totals to the regional total
        regional_total_by_year(r, :) = regional_total_by_year(r, :) + state_total_by_year(stateIndex, :);
    end
end

regionNames
years
regional_total_by_year

regionalTotals.livestock_respiration = regional_total_by_year*10^(-6); % convert from metric tons to TgC

return
% only do "on purpose"

regionalComponents = regionalTotals

save livestock_respiration.mat regionalComponents 