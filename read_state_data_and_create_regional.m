% read_state_data_and_create_regional.m


clear all
close all

% List of files to process
files = {
    'State_Biofuel_Biodiesel_Transportation.csv'
    'State_Biofuel_Ethanol_Commercial.csv'
    'State_Biofuel_Ethanol_Industrial.csv'
    'State_Biofuel_Ethanol_Transportation.csv'
    'State_Biomass_Wood_Commercial.csv'
    'State_Biomass_Wood_Electric.csv'
    'State_Biomass_Wood_Industrial.csv'
    'State_Biomass_Wood_Residential.csv'
    'State_FF_and_IPPU.csv'
    'State_Incineration_of_Waste.csv'
    'State_Industrial_landfill.csv'
    'State_MSW_landfill.csv'
};

% Define the years corresponding to the columns
years = 2015:2020;

regionNames = {'Northwest', 'Southwest', 'N GreatPlains', 'S GreatPlains', ...
    'Midwest', 'Southeast', 'Northeast'};

% Initialize totals
regional_totals = zeros(length(regionNames),length(years));
componentTotals = zeros(12,length(years));

% Define marker styles and line styles to cycle through
markers = {'o','s','^','v','d','>','<','p','h','x','+','*'};
lineStyles = {'-','--',':','-.'};

% Loop through each file
for i = 1:length(files)
    filename = files{i};
    
    % Read the file into a table
    T = readtable(filename);

    % Remove any rows where year data is not numeric
    data = T{:, 3:end}; % numerical data columns
    validRows = all(~ismissing(data) & isnumeric(data), 2);

    % Keep only valid rows
    T = T(validRows, :);
    data = T{2:end, 3:end};
    %states = T{2:end, 1};
    states = regexprep(lower(T{2:end, 1}), '(^|\s)([a-z])', '${upper($2)}');

    componentTotals(i,:) = sum(data,1); % sum over all states for comparison

    % Create a more readable title/label (replace underscores with spaces)
    [~, nameNoExt, ~] = fileparts(filename);
    cleanTitle = strrep(nameNoExt, '_', ' ');
    cleanFilename = strrep(nameNoExt, ' ', '_');  % for saving file

    % Create a figure
    fig = figure('Name', cleanTitle, 'NumberTitle', 'off', 'Position', [100, 100, 1200, 900]);
    hold on

    % Plot each state's data with distinct styles
    for j = 1:size(data, 1)
        marker = markers{mod(j-1, length(markers)) + 1};
        lineStyle = lineStyles{mod(floor((j-1)/length(markers)), length(lineStyles)) + 1};
        plot(years, data(j, :), ...
            'LineStyle', lineStyle, ...
            'Marker', marker, ...
            'LineWidth', 1.5, ...
            'MarkerSize', 8, ...
            'DisplayName', string(states{j}));
    end

    % Annotate the figure
    title(cleanTitle, 'Interpreter', 'none');
    ylabel(cleanTitle, 'Interpreter', 'none');
    set(gca, 'XTick', years); 
    set(gca, 'FontSize', 14)
    xlabel('Year');
    legend('Location', 'eastoutside');
    grid on
    hold off


    % Save figure as JPEG
    exportgraphics(fig, [cleanFilename '.jpg'], 'Resolution', 300);



% Determine regional totals for each year for each component.  
% Average the six available years to compare to Brendan's summary table.  

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

% Get state names
allStateNames = states;  % 

% Loop through each year
for yr = 1:length(years)

% Loop through each region
for r = 1:length(regionNames)
    stateList = regionStates{r};

    % Logical mask for states in this region
    mask = ismember(allStateNames, stateList);

    % Compute total using the mask
    regionalTotalsPieces(r,yr,i) = sum(data(mask,yr),1);
end
end
end



% Biofuel
regional_totals(:,:,1) = sum(regionalTotalsPieces(:,:,1:4),3)*12/44;
% Biomass
regional_totals(:,:,2) = sum(regionalTotalsPieces(:,:,5:8),3)*12/44;
% FF_and_IPPU
regional_totals(:,:,3) = sum(regionalTotalsPieces(:,:,9),3)*12/44;
% Incineration
regional_totals(:,:,4) = sum(regionalTotalsPieces(:,:,10),3)*12/44;
% Landfills % this doesn't seem to be used 
regional_totals(:,:,5) = sum(regionalTotalsPieces(:,:,12:12),3)*12/44;
mean(sum(regional_totals,1),2)

missingStates = setdiff(states, [regionStates{:}]);
disp("States not matched to a region:")
disp(missingStates)

componentTotals'-squeeze(sum(regionalTotalsPieces,1));
% 12 components and 6 years
% temporarily add Alaska and Hawaii to a region to see that these are
% indeed equal

regional_totals % 7 x 6 x 5 (5th is landfills, possiblly not used)

components = {'crop_biofuel','forest_biofuel','ff_and_ippu','incineration'};

regionalTotals.crop_biofuel = sum(regionalTotalsPieces(:,:,1:4),3)*12/44;
regionalTotals.forest_biofuel = sum(regionalTotalsPieces(:,:,5:8),3)*12/44;
regionalTotals.ff_and_ippu = sum(regionalTotalsPieces(:,:,9),3)*12/44;
regionalTotals.incineration = sum(regionalTotalsPieces(:,:,10),3)*12/44;

years
regionNames
regionalTotals


return
% only do "on purpose"

regionalComponents = regionalTotals

save state_level_data.mat regionalComponents 