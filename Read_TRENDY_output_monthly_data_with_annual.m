
clear all
close all

cd /Users/nlm136/Desktop/NASA_CMS/matlab_code/

state2 = shaperead('landareas.shp','UseGeoCoords', true); %
states = shaperead('usastatehi.shp','UseGeoCoords',true); %

fh = figure(100);
clf(fh);  % Clear any old content
% [ha, pos] = tight_subplot(Nh, Nw, gap, marg_h, marg_w)
fh.Position = [50, 50, 1200, 800];  % bigger window for more space
[ha,pos]=tight_subplot(4,5,[0.05 0.04],[0.07 0.03],[0.1 0.03])

% time, latitude, longitude, nbp

% THIS NEEDS TO BE CHECKED FOR UNITS!!!! 6/18/2025, don't forget!
% and what is the time range!
% some say "annual" which were the only files for nbp.
% FIX UNITS LABELS!
% there are N-S and E-W gradients, at least 4 regions
% most have 3876 time data points.  3876/12 = 323 years
% SDVGM csv file starts at year 1700.  So likely these are years 1700-2022.
% some have 323 time data points, suggesting annual values.
% CARDAMOM has 240 time data points.  I'd guess monthly values for 20
% years. Need to figure this out so that I'm comparing the same years.

% OCO2-MIP results are 2015-2020, last 6 years of TRENDY is 2017-2022
%d = 1; % duration, in years
%e = 2; % ending year, compared to 2022.  So e = 2 corresponds to 2020; e = 0 for 2022;

% d = 1; % this is to plot the average for only one year
% last_yr_avail = 2022; % do not change
% plot_yr = 2020; % put 2022 to plot the average for only year 2022
% e = last_yr_avail-plot_yr;

% CABLE-POP kg m-2 s-1
% CLASSIC: KgC/m2.s
% ORCHIDEE: kgC/m2/s

% 

for j=1:18%1:18% 19 is visit which contains garbage
    switch j
        case 1
            flnc=['../data/Global_CARBON_Project/GCB_GITHUB_v12/CABLEPOP_S3_nbp.nc']; %1
            model = 'CABLEPOP'; %time_inx_avg_beg=3876-(12*(d+e))+1;time_inx_avg_end=3876-(12*e);
             monthly = 1;annual =0;
        case 2
            flnc=['../data/Global_CARBON_Project/GCB_GITHUB_v12/CARDAMOM_S3_nbp.nc']; %2
            model = 'CARDAMOM';%time_inx_avg_beg=240-(12*(d+e))+1;time_inx_avg_end=240-(12*e); % only 20 years
             monthly = 1;annual =0;
        case 3
            flnc=['../data/Global_CARBON_Project/GCB_GITHUB_v12/CLASSIC_S3_nbp.nc']; %3
            model = 'CLASSIC';
            %time_inx_avg_beg=3864-(12*(d+e-1))+1;time_inx_avg_end=3864-(12*(e-1));
            %  this one is 1700-2021
             monthly = 1;annual =0;
                   case 4
flnc=['../data/Global_CARBON_Project/GCB_GITHUB_v12/CLM5.0_S3_nbp.nc']; %14
model = 'CLM5';%time_inx_avg_beg=323-d-e+1;time_inx_avg_end=323-e;
 monthly = 1;annual =0; %3864 % -90:90 for lat and 0 360 for lon (instead of -180:180 for lon)
        case 5
            flnc=['../data/Global_CARBON_Project/GCB_GITHUB_v12/E3SM_S3_nbp.nc']; %4
            model = 'E3SM';%time_inx_avg_beg=3876-(12*(d+e))+1;time_inx_avg_end=3876-(12*e);
             monthly = 1;annual =0;
        case 6
            flnc=['../data/Global_CARBON_Project/GCB_GITHUB_v12/EDv3_S3_nbp.nc']; %5
            model = 'EDv3';%time_inx_avg_beg=3876-(12*(d+e))+1;time_inx_avg_end=3876-(12*e);
             monthly = 1;annual =0;
        case 7
            flnc=['../data/Global_CARBON_Project/GCB_GITHUB_v12/IBIS_S3_nbp.nc']; %6
            model = 'IBIS';%time_inx_avg_beg=3876-(12*(d+e))+1;time_inx_avg_end=3876-(12*e);
             monthly = 1;annual =0;
        case 8
            flnc=['../data/Global_CARBON_Project/GCB_GITHUB_v12/ISBA_CTRIP_S3_nbp.nc']; %7
            model = 'ISBA CTRIP';%time_inx_avg_beg=3876-(12*(d+e))+1;time_inx_avg_end=3876-(12*e);
             monthly = 1;annual =0;
        case 9
            flnc=['../data/Global_CARBON_Project/GCB_GITHUB_v12/JSBACH_S3_nbp.nc']; %8
            model = 'JSBACH'; %time_inx_avg_beg=3876-(12*(d+e))+1;time_inx_avg_end=3876-(12*e);
             monthly = 1;annual =0;
        case 10
            flnc=['../data/Global_CARBON_Project/GCB_GITHUB_v12/LPJwsl_S3_nbp.nc']; %9
            model = 'LPwsl';%time_inx_avg_beg=3876-(12*(d+e))+1;time_inx_avg_end=3876-(12*e);
             monthly = 1;annual =0;
        case 11
            flnc=['../data/Global_CARBON_Project/GCB_GITHUB_v12/LPX_Bern_S3_nbp.nc']; %10
            model = 'LPX Bern';%time_inx_avg_beg=3876-(12*(d+e))+1;time_inx_avg_end=3876-(12*e);
             monthly = 1;annual =0;
        case 12
            flnc=['../data/Global_CARBON_Project/GCB_GITHUB_v12/OCN_S3_nbp.nc']; %11
            model = 'OCN';%time_inx_avg_beg=3876-(12*(d+e))+1;time_inx_avg_end=3876-(12*e);
             monthly = 1;annual =0;
        case 13
            flnc=['../data/Global_CARBON_Project/GCB_GITHUB_v12/ORCHIDEE_S3_nbp.nc']; %12
            model = 'ORCHIDEE';%time_inx_avg_beg=3876-(12*(d+e))+1;time_inx_avg_end=3876-(12*e);
             monthly = 1;annual =0;
        case 14
            flnc=['../data/Global_CARBON_Project/GCB_GITHUB_v12/YIBs_S3_Monthly_nbp.nc']; %13
            model = 'YIBs';%time_inx_avg_beg=3876-(12*(d+e))+1;time_inx_avg_end=3876-(12*e);
 monthly = 1;annual =0;

        case 15 %
            flnc=['../data/Global_CARBON_Project/GCB_GITHUB_v12/DLEM_S3_nbp.nc']; %15
model = 'DLEM';%time_inx_avg_beg=323-d-e+1;time_inx_avg_end=323-e;
monthly = 0;annual =1; % 323 years
case 16
flnc=['../data/Global_CARBON_Project/GCB_GITHUB_v12/LPJmL_S3_nbp.nc']; %16
model = 'LPJmL';%time_inx_avg_beg=323-d-e+1;time_inx_avg_end=323-e;
monthly = 0;annual =1;% 323 years
        case 17
flnc=['../data/Global_CARBON_Project/GCB_GITHUB_v12/LPJ_GUESS_S3_nbp.nc']; %17
model = 'LPJ GUESS';%time_inx_avg_beg=323-d-e+1;time_inx_avg_end=323-e;
monthly = 0;annual =1; % 323 years       
      case 18
flnc=['../data/Global_CARBON_Project/GCB_GITHUB_v12/SDGVM_S3_nbpAnnual.nc']; %18
model = 'SDGVM';%time_inx_avg_beg=323-d-e+1;time_inx_avg_end=323-e;
 monthly = 0;annual =1;% 323 years
      case 19  % IGNORE!
flnc=['../data/Global_CARBON_Project/GCB_GITHUB_v12/VISIT_S3_gpp.nc']; %19
model = 'VISIT';%time_inx_avg_beg=323-d-e+1;time_inx_avg_end=323-e;
monthly = 1;annual =0;
% % has 1956 values in the time array, that's 163 years, maybe 
% others have 323 years and start at 1700
% start date must be 1860
% UNCLEAR START DATE
% values seem to be 0 on land and 3.1557e+03 on ocean
    end % switch  % 20: JULES and 21: ISAM don't have CONUS output

    % models 15-18 are annual

    % CLM5.0 DLEM LPJmL LPJ-GUESS SDGVM VISIT

    info = ncinfo(flnc);
    disp(info)
    info.Variables.Name

    if j==10|j==4|j==15|j==19
        lat = ncread(flnc,'lat');
        lon = ncread(flnc,'lon');
        time = ncread(flnc,'time');
        nbp = ncread(flnc,'nbp');
    elseif j==8
        lat = ncread(flnc,'lat_FULL');
        lon = ncread(flnc,'lon_FULL');
        time = ncread(flnc,'time_counter');
        nbp = ncread(flnc,'nbp');
        elseif j==18
        lat = ncread(flnc,'latitude');
        lon = ncread(flnc,'longitude');
        time = ncread(flnc,'time');
        nbp = ncread(flnc,'nbpAnnual');
    else
        lat = ncread(flnc,'latitude');
        lon = ncread(flnc,'longitude');
        time = ncread(flnc,'time');
        nbp = ncread(flnc,'nbp');
    end
    length_time=length(time);
    if j==4
        lon=lon-358.75/2;
    end

    % time:

    R = 6.371*10^6; % Earth radius in meters
    dlat = abs(lat(2) - lat(1));
    dlon = abs(lon(2) - lon(1));
    % Area per cell in m² (approximate)
    cellArea = (pi/180) * R^2 * abs(sind(lat + dlat/2) - sind(lat - dlat/2))' * dlon;
    % Broadcast to match grid
    [~, areaGrid] = meshgrid(lon, cellArea);

    nbp=-1*nbp; % any reasonable person knows sinks are negative ! :) % 28 June 2025
    % kg m-2 s-1 
    nbp=nbp*365.25*24*60*60/10^(9); % Tg/yr /m2
    % for monthly, take the average to get the total for the year
    % for annual, 

    for yr = 2015:2020%2020
        for month = 1:12% 1:12

            cmap = [140,81,10; 191,129,45; 223,194,125; 246,232,195; 256,256,256; 199,234,229; 128,205,193; ...
                53,151,143; 1,102,94]./256;
            cmap_one_sided = [256,256,256; 199,234,229; 128,205,193; 53,151,143; 1,102,94]./256;
            cmap=flipud(cmap);
            % cmap_one_sided_9_levels =[247,252,253; 229,245,249; 204,236,230; 153,216,201; 102,194,164; ...
            %     65,174,118; 35,139,69; 0,109,44; 0,68,27]/256;
            % We want to spread these 5 "knots" into 9 output colors:
            n = 9;cmap5=cmap_one_sided;
            % Interpolate between the 5 colors:
            x = linspace(1,5,5);              % original indices
            xi = linspace(1,5,n);             % desired 9-level indices
            cmap_one_sided_9_levels = interp1(x, cmap5, xi, 'linear');  % gives 9×3 matrix
            cmap_one_sided_9_levels = flipud(cmap_one_sided_9_levels);

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
                % temp = nanmean(nbp(:,:,time_inx_avg_beg:time_inx_avg_end),3); %%% nbp
                % the above was doing averaging over 6 years
                if monthly == 1 & annual == 0
                if j==2
                    temp = nbp(:,:,12*(yr-2003)+month); % CARDAMOM is 2003-2022
                elseif j==19
                    temp = nbp(:,:,12*(yr-1860)+month); % VISIT start date is 1860 (not sure, tbh)
                else
                    temp = nbp(:,:,12*(yr-1700)+month); % 3865 to 3876 is last year available, 2022
                end
                end
                if annual == 1 & monthly == 0
                    if month == 12 % put the annual value in month 12 for that year
                    temp = nbp(:,:,yr-1700+1); % 
                    else
                        temp = (nbp(:,:,1))*NaN; % other months
                    end
                end
           

                maskedData = temp'; % temp'
                % Handle NaNs or missing values
                maskedData(~inMask) = NaN;
                % Sum total for this state (ignoring NaNs)
                %%stateSum = nansum(maskedData(:)); % doesn't take into account the area
                stateSum = nansum(nansum(maskedData .* areaGrid)); % Multiply data by area before summing
                %%temp2 = nanmean(nbp(:,:,time_inx_avg_beg:time_inx_avg_end),3); %%% nbp
                %%flux = temp2' .* areaGrid ; % kg C s^{-1} in each grid cell
                % Save the total to the output struct
                stateTotals(k).Name = stateName;
                stateTotals(k).Total = stateSum; % kg C s^{-1}
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
            regionalTotals = zeros(length(regionNames), 1);

            % Loop through each region
            for r = 1:length(regionNames)
                stateList = regionStates{r};
                % Logical mask for states in this region
                mask = ismember(allStateNames, stateList);
                % Compute total using the mask
                regionalTotals(r) = sum(allTotals(mask));
            end

            %figure(100)
            %figure('name','bar_charts','position',[300 300 900 600])
            figure(fh);
            %subplot(5,3,j);% need tightsubplot
            %[ha,pos]=tight_subplot(4,4,[0.05 0.04],[0.07 0.03],[0.1 0.03])
            axes(ha(j));
            b = bar(regionalTotals);
            b.FaceColor = 'flat';  % Enable individual coloring
            numBars = length(regionalTotals);
            set(ha(j),'Fontsize',12);
            % Define default color (e.g., teal)
            defaultColor = [1, 102, 94]/256;
            % Define highlight color (e.g., brown)
            highlightColor = [140, 81, 10]/256;
            % Initialize CData with default color
            b.CData = repmat(defaultColor, numBars, 1);
            % Find indices where regionalTotals > 0
            bh = find(regionalTotals > 0);
            % Assign highlight color to bars with positive values
            b.CData(bh, :) = repmat(highlightColor, length(bh), 1);
            ylim([-2000 2000]); %
            if j>=10
                set(ha(j),'XTickLabel', regionNames, 'XTick', 1:length(regionNames));
            else
                set(ha(j),'XTickLabel',{});
            end
            if j==1|j==5|j==9|j==13
               % ylabel(ha(j), 'CO_2 Flux (kgC/s)')
               ylabel(ha(j), 'CO_2 Flux (TgC/yr)')
            end
            title(strcat(model,' regional totals '))
            set(ha(14), 'Visible', 'off');set(ha(15), 'Visible', 'off');set(ha(16), 'Visible', 'off');

            text(1, -150, num2str(length_time) );
            text(1,-1000,num2str(month));
            text(1,-2000,num2str(yr));

            for r = 1:length(regionalTotals)
                regionalTotalsbyModelbyMonthbyYear((r),j,month,yr-2015+1) = regionalTotals(r);
            end
            % interested in 2015-2020 to compare to OCO2-MIP inversions

        end % month
    end % yr

end % models


% figure(100); print -djpeg regional_means_TRENDY_2015_2020
% figure(13); print -djpeg CT_map_OCO2MIP_LNLGIS
% figure(11); print -djpeg CSU_map_OCO2MIP_LNLGIS
% figure(7); print -djpeg CMS_map_OCO2MIP_LNLGIS


% save TRENDY_with_annual_TEST.mat regionalTotalsbyModelbyMonthbyYear
% without doing the NaN thing below

regionalTotalsbyModelbyMonthbyYear(regionalTotalsbyModelbyMonthbyYear==0)=NaN;
% save TRENDY_with_annual.mat regionalTotalsbyModelbyMonthbyYear

figure
plot(squeeze(nansum(regionalTotalsbyModelbyMonthbyYear(5,18,:,:),3)),'-');



figure
imagesc(lon, lat, nbp(:,:,1)');
set(gca,'YDir','normal')   % critical: prevents flipped latitude
hold on

geoshow(states,'DisplayType','polygon','FaceColor','none','EdgeColor','k');
colorbar