
clear all
close all

state2 = shaperead('landareas.shp','UseGeoCoords', true); %
states = shaperead('usastatehi.shp','UseGeoCoords',true); %

regionalTotalsFire = zeros(7, 1);

cd ../data/GFEDv5/

years = 2015:2020;                         % <-- ADDED
regionalTotals_all = zeros(7,length(years)); % <-- ADDED

for y = 1:length(years)                    % <-- ADDED LOOP

flnc = ['GFED5.1_monthly_' num2str(years(y)) '.nc'];  % <-- ADDED

info = ncinfo(flnc);
disp(info)
info.Variables.Name

info = ncinfo(flnc,'C');                   % <-- MODIFIED (was fixed 2015)
info.Attributes

lat = ncread(flnc,'lat');
lon = ncread(flnc,'lon');

C = ncread(flnc,'C');

annual_total = sum(C, 3, 'omitnan');  % g C /grid cell/yr
annual_total=annual_total';
annual_total = annual_total/10^12;

figure
imagesc(lon, lat, annual_total)
set(gca,'YDir','normal')
colorbar
caxis([0 0.01])
xlim([-130 -70]);
ylim([20 60])

%%
[LonGrid, LatGrid] = meshgrid(lon, lat);
stateTotals = struct();

for k = 1:length(states)
    stateName = states(k).Name;
    latPoly = states(k).Lat;
    lonPoly = states(k).Lon;

    inMask = inpolygon(LonGrid, LatGrid, lonPoly, latPoly);

    maskedData = annual_total; 
    maskedData(~inMask) = NaN;

    stateSum = nansum(maskedData(:)); 
    
    stateTotals(k).Name = stateName;
    stateTotals(k).Total = stateSum;
end

%%
stateTable = struct2table(stateTotals);
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

allStateNames = {states.Name};

regionalTotals = zeros(length(regionNames), 1);

for r = 1:length(regionNames)
    stateList = regionStates{r};
    mask = ismember(allStateNames, stateList);
    regionalTotals(r) = sum(allTotals(mask));
end

regionalTotals_all(:,y) = regionalTotals;   % <-- ADDED store per year

end                                          % <-- END LOOP
%%

regionalTotalsFire = mean(regionalTotals_all,2); % <-- ADDED MEAN

regionalTotalsFire(8)=sum(regionalTotalsFire);

% as a test (uses last year loaded)
global_TgC = nansum(annual_total, 'all');

mask = LonGrid >= -125 & LonGrid <= -66 & LatGrid >= 25 & LatGrid <= 50;
conus_box = nansum(annual_total(mask));
regionNames{8}='TOTAL';

cmap_t = [191,129,45; 223,194,125; 246,232,195; 256,256,256; 199,234,229; 128,205,193; ...
    53,151,143]./256;
% Create figure
    fh = figure;
    fh.Position = [50, 50, 350, 350];
    % Bar chart (grouped)
    y1=regionalTotalsFire;
b = bar(y1, 'grouped');
hold on
% Apply colors — use two from the colormap (e.g., first and last)
b(1).FaceColor = cmap_t(1,:); % First dataset color
%b(2).FaceColor = cmap_t(end,:); % Second dataset color
% Number of groups
ngroups = size(y1,1);
nbars = 1;

% Calculate x positions for each bar
x = nan(ngroups, nbars);
for i = 1:nbars
    x(:,i) = b(i).XEndPoints;
end


hold off

% Add labels and formatting
set(gca, 'XTickLabel', regionNames, 'XTick', 1:length(regionNames));
set(gca,'FontSize',12)
xtickangle(30);
ylabel('Fire Emissions (Tg C/yr)');
%legend({'Non-NA','NA'}, 'Location', 'northwest');
    ylim([-10 50]);
ax=axis; ymin=ax(3); ymax=ax(4);
yticks(linspace(ymin, ymax, 4))
% Improve layout
box on;
hold off;

% cd /Users/nlm136/Desktop/NASA_CMS/lateral_transport/
% save gfed5_1.mat regionalTotalsFire