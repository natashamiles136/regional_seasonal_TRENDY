clear all
close all

% year_s = 2015:2018; % specific
year_f = 2015:2020; % years in the files

load CARDAMOM_JPL.mat % CARD_JPL_NBE CARD_JPL_NEE CARD_JPL_EXP1_NBE CARD_JPL_EXP1_NEE
% 7 x 12
CARD_JPL_NBE(8, :) = sum(CARD_JPL_NBE, 1); % total row
CARD_JPL_EXP1_NBE(8, :) = sum(CARD_JPL_EXP1_NBE, 1);
CARD_JPL_NEE(8, :) = sum(CARD_JPL_NEE, 1);
CARD_JPL_EXP1_NEE(8, :) = sum(CARD_JPL_EXP1_NEE, 1);

% above is not really needed and EXP1 is actually BASE, BTW

load CARDAMOM_JPL_OCT2025.mat %CARD_JPL_NBE_BASE CARD_JPL_NBE_CROP_HARVEST
CARD_JPL_NBE_BASE(8, :) = sum(CARD_JPL_NBE_BASE, 1); % total row
CARD_JPL_NBE_CROP_HARVEST(8, :) = sum(CARD_JPL_NBE_CROP_HARVEST, 1); % total row

CARD_JPL_NBE_CROP_HARVEST = CARD_JPL_NBE_CROP_HARVEST*NaN; % not including in paper

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


% save inversions_2015_2020.mat array_for_mean_plot 
load inversions_2015_2020_new.mat ; %(8 regions x 15 models) 
% array_for_mean_plot (median)
% this is for the figure in the supplement

 % ens_mean_OCO2_MIP
load('ens_median_inversion_2015_2020_new.mat') % now doing median
% ens_median_OCO2_MIP; % 8 regions x 12 months x 15 models (including ens mean)
oco2_mip = ens_median_OCO2_MIP; % 8 regions x 12 months x 15 models (including ens mean)
% this is for the figure with all the seasonal patterns for the regions

ens_mean = ens_median_OCO2_MIP(:,:,15); % ensemble median for 8 regions and 12 months % 

ens_mean_annual = array_for_mean_plot(:,15); % the ensemble median, annual, for the 8 regions
% this is for most of the calculations

ens_median_annual = ens_mean_annual ; % so I don't have to change everywhere, sorry.

%load TRENDY.mat % regionalTotalsbyModelbyMonthbyYear
load TRENDY_with_annual.mat % models 15-18 are annual, month 12 is the annual value, other months are NaN
trendy_by_year = regionalTotalsbyModelbyMonthbyYear;
trendy_by_year(8, :, :, :) = sum(trendy_by_year, 1);
tby=trendy_by_year(:,1:14,:,:); % only look at the monthly ones, for now. (1,6,10) are ED, others are non-ED.
trendy = mean(tby,4);

CARD_JPL_NBE = reshape(CARD_JPL_NBE, [8 1 12]);
CARD_JPL_NEE = reshape(CARD_JPL_NEE, [8 1 12]);
CARD_JPL_EXP1_NBE = reshape(CARD_JPL_EXP1_NBE, [8 1 12]);
CARD_JPL_EXP1_NEE = reshape(CARD_JPL_EXP1_NEE, [8 1 12]);

CARD_JPL_NBE_BASE = reshape(CARD_JPL_NBE_BASE, [8 1 12]);
CARD_JPL_NBE_CROP_HARVEST = reshape(CARD_JPL_NBE_CROP_HARVEST, [8 1 12]);

%%
fh = figure;
    fh.Position = [50, 50, 600, 400];
% Bar chart (grouped)

b = bar([mean(squeeze(CARD_JPL_NBE_BASE),2),mean(squeeze(CARD_JPL_NBE_CROP_HARVEST),2)], 'grouped');
cmap_t = [191,129,45; 223,194,125; 246,232,195; 256,256,256; 199,234,229; 128,205,193; ...
    53,151,143]./256;
% Apply colors — use two from the colormap (e.g., first and last)
b(1).FaceColor = cmap_t(1,:); % First dataset color
b(2).FaceColor = cmap_t(end,:); % Second dataset color
% Add labels and formatting
set(gca, 'XTickLabel', [regionNames,'Total'], 'XTick', 1:length(regionNames)+1);
set(gca,'FontSize',14)
xtickangle(30);
ylabel('CO_2 Flux (Tg C yr^{-1})');
legend({'JPL BASE','JPL CROPS'}, 'Location', 'northwest');
grid on;

% Improve layout
box on;
hold off;



%%

%trendy = cat(2, trendy, CARD_JPL_EXP1_NBE, CARD_JPL_EXP1_NEE, CARD_JPL_NBE, CARD_JPL_NEE); % CARDAMOM JPL added to comparison
% NBE and -1*NEE are indistinguishable on my plots, but are slightly
% different
%trendy = cat(2, trendy, CARD_JPL_EXP1_NBE, CARD_JPL_NBE); % CARDAMOM JPL added to comparison
trendy = cat(2, trendy, CARD_JPL_NBE_BASE, CARD_JPL_NBE_CROP_HARVEST); % CARDAMOM JPL added to comparison
% 14 annual trendys + 2 jpl

%cmap_one_sided = [256,256,256; 199,234,229; 128,205,193; 53,151,143; 1,102,94]./256;
cmap_one_sided = [256,256,256; 199,234,229; 128,205,193; 53,151,143]./256;
n = 100;
x = linspace(1,4,4);
xi = linspace(1,4,n);
cmap = interp1(x, cmap_one_sided, xi, 'linear');
cmap = flipud(cmap);
tab20 = [
    0.1216 0.4667 0.7059
    0.6824 0.7804 0.9098
    1.0000 0.4980 0.0549
    1.0000 0.7333 0.4706
    0.1725 0.6275 0.1725
    0.5961 0.8745 0.5412
    0.8392 0.1529 0.1569
    1.0000 0.5961 0.5882
    0.5804 0.4039 0.7412
    0.7725 0.6902 0.8353
    0.5490 0.3373 0.2941
    0.7686 0.6118 0.5804
    0.8902 0.4667 0.7608
    0.9686 0.7137 0.8235
    0.4980 0.4980 0.4980
    0.7804 0.7804 0.7804
    0.7373 0.7412 0.1333
    0.8588 0.8588 0.5529
    0.0902 0.7451 0.8118
    0.6196 0.8549 0.8980
    ];
shades_of_gray = [0.8 0.8 0.8;0.6 0.6 0.6; 0.4 0.4 0.4];
shades_of_purple = [0.5804 0.4039 0.7412; 0.6765 0.5471 0.7883;0.7725 0.6902 0.8353];

% Define groups
%group_A = [2 3 4 6 7 8 10 11 12 13];
%group_A = [2 3 4 6 7 8 10 11 12 13 14 15]; %include JPL BASE AND JPL CROP
group_A = [2 3 4 5 7 8 9 11 12 13 14 15]; %include JPL BASE 
group_B = [1 6 10]; %group_B = [1 5 9];
% group_C = [14 15 16 17];
group_C = [15 ]; % CARD-JPL
group_O = []; % O for OCO2-MIP
groups = {group_A, group_B, group_C, group_O};
groupNames = {'Group A','Group B','CARD-JPL','OCO2-MIP only'};

group_annual = [ 17 18 19 20]; % annual models

do_diff = 0; % instead of plotting baseline and crop run for JPL, plot the difference

% addpath '/Users/nlm136/Desktop/NASA_CMS/matlab_code'
% load oco2_mip_2015_2020.mat % oco2_mip (7 regions x 12 months x 14 models)
% oco2_mip(8,:,:,:) = sum(oco2_mip, 1); % total row


for g = 1:5  % loop over groups A, B, C, and oco2mip, and then do oco2_mip models
    fh = figure;
    fh.Position = [50, 50, 1200, 800];
    states = shaperead('usastatehi.shp','UseGeoCoords',true);

    ax = axesm('mercator', 'MapLatLimit', [24 50], 'MapLonLimit', [-125 -66]);
    setm(ax, ...
        'Frame', 'on', 'Grid', 'off', 'MeridianLabel', 'on', 'ParallelLabel', 'on', ...
        'MLabelLocation', 10, 'PLabelLocation', 5, ...
        'MLabelParallel', 24, 'PLabelMeridian', -66, 'FontSize', 14);
    axis off; tightmap
    geoshow(states, 'FaceColor', 'none', 'EdgeColor', 'k'); hold on;

    % Color by annual total
    regionVals = ens_mean_annual;
    climits = [min(regionVals(:)), max(regionVals(:))];
    % cmap=flipud(cmap);
    for s = 1:length(states)
        stateName = states(s).Name;
        regionIdx = find(cellfun(@(rs) any(strcmp(stateName, rs)), regionStates));
        if ~isempty(regionIdx)
            val = regionVals(regionIdx);
            colorIdx = round((val - climits(1)) / (climits(2) - climits(1)) * (size(cmap,1)-1)) + 1;
            colorIdx = min(max(colorIdx, 1), size(cmap,1));
            fillm(states(s).Lat, states(s).Lon, cmap(colorIdx,:));
        else
            fillm(states(s).Lat, states(s).Lon, [0.8 0.8 0.8]);
        end
    end

    colormap(cmap); clim(climits);

    regionNames_full = [regionNames,'TOTAL'];
    regionCentroids = [
        43.5, -117.3;  % Northwest
        36.5, -112;  % Southwest
        43, -104;  % Northern Great Plains
        35, -98;   % Southern Great Plains
        41, -90;   % Midwest
        33, -84;   % Southeast
        39, -73;   % Northeast
        30, -116;   % TOTAL
        ];
    maplatlimit = [24 50];
    maplonlimit = [-125 -66];
    axPos = get(ax, 'Position');

    make_blank = 0;
    if make_blank == 0
        for r = 1:8
            normLon = (regionCentroids(r,2) - maplonlimit(1)) / (maplonlimit(2) - maplonlimit(1));
            normLat = (regionCentroids(r,1) - maplatlimit(1)) / (maplatlimit(2) - maplatlimit(1));
            insetWidth = 0.14;
            insetHeight = 0.14;
            if r == 8
                insetWidth = 0.16;
                insetHeight = 0.16;
            end
            insetLeft = axPos(1) + normLon * axPos(3) - insetWidth/2;
            insetBottom = axPos(2) + normLat * axPos(4) - insetHeight/2;
            insetAx = axes('Position', [insetLeft insetBottom insetWidth insetHeight]);
            if r == 8
                if g~=3
                    rectangle('Position',[0,-9000,13,14000], 'FaceColor',[246,232,195]./246, 'EdgeColor','none'); % yellow translucent
                else
                    rectangle('Position',[0,-9500,13,9500*2], 'FaceColor',[246,232,195]./246, 'EdgeColor','none'); % yellow translucent
                end
                hold on;
                pos = insetAx.Position;  % [left bottom width height]
                % draw rectangle around it
                annotation('rectangle', pos, ...
                    'LineWidth', 3, ...      % thick border
                    'Color', [0 0 0]);       % black color (change as desired)
            end
            if g<=4
                for d = 1:length(groups{g})
                    %if g==1|g==2|g==4
                    if g==2|g==4
                        plot(1:12, squeeze(trendy(r,groups{g}(d),:)), ':', 'LineWidth', 2, 'Color', cmap(d*7,:)); hold on;
                    end
                    if g==1 % this is to plot TRENDY A in green, and TRENDY B in purple
                        % plot(1:12, squeeze(trendy(r,groups{g}(d),:)), ':', 'LineWidth', 2, 'Color', cmap(d*7,:)); hold on;
                        if d<=11% 10
                            plot(1:12, squeeze(trendy(r,groups{g}(d),:)), ':', 'LineWidth', 2, 'Color', cmap(7*2,:)); hold on; %
                        else % 12 or 13 = JPL
                            plot(1:12, squeeze(trendy(r,groups{g}(d),:)), '-', 'LineWidth', 2, 'Color', cmap(7*8,:)); hold on; %
                        end

                     end
                    if g==3
                        if do_diff
                            plot(1:12, squeeze(trendy(r,groups{g}(2),:)-trendy(r,groups{g}(1),:)), '-', 'LineWidth', 2, 'Color', 'k'); hold on;
                            plot(1:12, zeros(1,12), ':', 'LineWidth', 2, 'Color', 'k'); hold on;
                        else
                            plot(1:12, squeeze(trendy(r,groups{g}(d),:)), ':', 'LineWidth', 2, 'Color', cmap(d*30,:)); hold on;
                            % plot(1:12, squeeze(trendy(r,groups{g}(2),:)), ':', 'LineWidth', 2, 'Color', 'r'); hold on;
                        end
                    end
                end
for d=1:length(groups{g})
    if g==1
                        if d<=3 % this is group 2 (g+1)
                        plot(1:12, squeeze(trendy(r,groups{g+1}(d),:)), '-', 'LineWidth', 2, 'Color', shades_of_purple(d,:)); hold on;
                        end
    end
end
            end
            if g==5
                for n=1:size(oco2_mip,3)-1
                   %plot(1:12, squeeze(oco2_mip(r,:,n)), '--', 'LineWidth', 2, 'Color', tab20(n,:)); hold on;
                   plot(1:12, squeeze(oco2_mip(r,:,n)), ':', 'LineWidth', 2, 'Color', cmap(30,:)); hold on; %cmap(n*5,:)
                end
                  % plot(1:12, squeeze(oco2_mip(r,:,14)), ':', 'LineWidth',2, 'Color', 'r'); hold on; %WOMBAT
                  % only fully Bayesian inversion in MIP - is very close to the ensemble mean ... 

            end

            if ~do_diff
                plot(1:12, ens_mean(r,:), '-', 'LineWidth', 2, 'Color', [191,129,45]./256); hold on;
            end
            title(regionNames_full{r}, 'FontSize', 12);
            if g<=4;
                xlim([1 12]); ylim([-2500 1600]); if g==3; ylim([-2700 2700]);end; if g==3&do_diff; ylim([-500 500]);end
            end
            if g==5; xlim([1 12]); ylim([-2500 1000]);end;
            xticks(1:12); set(gca,'XTickLabel',{'J','F','M','A','M','J','J','A','S','O','N','D'});
            set(gca,'FontSize',12); xtickangle(0);
            if r==6
                if g==1
                    %legend('2','3','4','6','7','8','10','11','12','13','OCO2MIP','Location','Southwest')
                    %legend('SCOT CARD','CLASSIC','E3SM','IBIS','ISBA CTRIP','JSBACH','LPX BERN','OCN','ORCHIDEE','YIBs','OCO2MIP','Location','Southwest')
                    %legend('SCOT CARD','CLASSIC','E3SM','IBIS','ISBA CTRIP','JSBACH','LPX BERN','OCN','ORCHIDEE','YIBs','CABLEPOP','EDv3','LPJwsl','JPL BASE','JPL CROP','OCO2MIP','Location','Southwest')
                legend('CARD-EDI','CLASSIC','CLM5.0','E3SM','IBIS','ISBA CTRIP','JSBACH','LPX BERN','OCN','ORCHIDEE','YIBs','CARD-JPL','CABLEPOP','EDv3','LPJwsl','OCO2MIP','Location','Southwest')
                end
                if g==2
                    %legend('1','5','9','OCO2MIP','Location','Southwest')
                    legend('CABLEPOP','EDv3','LPJwsl','OCO2MIP','Location','Southwest')
                end
                if g==3
                    %legend('JPL BASE NBE','JPL BASE NEE','JPL CROPS NBE','JPL CROPS NEE','Location','Southwest')
                    legend('JPL BASE','JPL CROPS','Location','Southwest')
                    if do_diff;legend('JPL CROPS - JPL BASE','Location','Southwest');end
                end
                if g==4
                    legend('OCO2MIP','Location','Southwest')
                end
                if g==5
                    oco2_models={'AMES','BAKER','CAMS','CMS-FLUX','COLA','CSU','CT','JHU','LoFI','NIES','OU','TM5 4DVAR','UT','WOMBAT','ENS MEAN'};
                   % oco2_models={'AMES','CT','OU','ens mean'};
                    legend(oco2_models,'Location','Southwest');
                end
            end
            if r==8&&g<=4; ylim([-9000 5000]); end;  if g==5&&r==8; ylim([-5000 3000]);end;
            if g==3&&r==8; ylim([-9500 9500]);end
        end % r
        if g>1&&g<=4
            %sgtitle(['TgC/year (', groupNames{g}, ')'],'FontSize',14,'FontWeight','bold');
        end
    end
end % g



% figure(1); print -djpeg group_A
% figure(2); print -djpeg group_B
% figure(3); print -djpeg group_C
% figure(4); print -djpeg oco2_mip_only
% figure(5); print -djpeg oco2_mip_individual_examples



%%
% To account for lateral transport due to livestock respiration
% TRENDY MODEL - tlr + lr
% sum over all of CONUS all year is 0
%[tlr, lr, ct] = read_nlt ;
[thr,tlr,tcr_re,tcr_bio,tfo_re,tfo_bio, hr,lr,cr_re,cr_bio,fo_re,fo_bio,rem,lem, tct,tlf,twt,thwp,trem,tlem,tab,taex ]=read_nlt_annual;
% lr = livestock respiration
% tlr = respiration from the crops that the liveestock ate that would have occured
% in crop regions had it not been harvested and moved
% ct = crop trade, would have respired in the crop regions according to
% trendy models, instead zero respiration, so TRENDY - ct + 0
%
lt_rm_components_name={'Human Resp','Livestock Resp','Crop Res','Crop Biofuels','Crop Trade','Crop Landfill',...
    'Forest Res','Forest Biofuels','Forest Trade','Forest HWP','Aquatic Emissions','Aquatic Burial','Coastal Ex','TOTAL'};
lt_rm_c_name={'Human Resp','Human Resp','Livestock Resp','Livestock Resp','Crop Residual','Crop Residual','Crop Biofuels','Crop Biofuels','Crop Trade','Crop Landfill',...
    'Forest Residual','Forest Residual','Forest Biofuels','Forest Biofuels','Forest Trade','Forest HWP','Aquatic Emissions','Aquatic Emissions','Aquatic Burial','Coastal Ex','TOTAL'};

lt_rm_c = [ ...
    hr, -thr, ...
    lr, -tlr, ...
    cr_re, -tcr_re, ...
    cr_bio, -tcr_bio, ...
    -tct, -tlf,...
    fo_re, -tfo_re, ...
    fo_bio, -tfo_bio, ...
    -twt, -thwp, ...
    rem+lem, -trem - tlem, ...
    -tab, -taex]; % individual components for making explanatory figure
% aquatic emissions (rem+lem), those came from the land, don't need to
% subtract b/c not related to harvest



lt_rm_components = [ ...
    hr - thr, ...
    lr - tlr, ...
    cr_re - tcr_re, ...
    cr_bio - tcr_bio, ...
    -tct, -tlf,...
    fo_re - tfo_re, ...
    fo_bio - tfo_bio, ...
    -twt, -thwp, ...
    rem - trem + lem - tlem, ...
    -tab, -taex];
net_lt=sum(lt_rm_components,2); % NN/NL
% net_lt_YR = hr+lr+cr_re+cr_bio+fo_re+fo_bio+rem-trem+lem-tlem-tab-taex; % 12 terms
% net_lt_YL= -1*thr+hr-tlr+lr-tcr_re+cr_re-tcr_bio+cr_bio-tct-tlf+fo_re+fo_bio+rem-trem+lem-tlem-tab-taex;
% net_lt_YRL=-0.5*thr+hr-0.5*tlr+lr-0.5*tcr_re+cr_re-0.5*tcr_bio+cr_bio-0.5*tct-0.5*tlf+fo_re+fo_bio+rem-trem+lem-tlem-tab-taex;

subtracted_terms_crop = thr+tlr+tcr_re+tcr_bio+tct+tlf; % 6 terms
subtracted_terms_forest = tfo_re+tfo_bio+twt+thwp; % 4 terms

net_lt(8)= sum(net_lt); %Eq 6
%net_lt_YR(8)= sum(net_lt_YR);net_lt_YL(8)= sum(net_lt_YL);net_lt_YRL(8)= sum(net_lt_YRL);
subtracted_terms_crop(8)= sum(subtracted_terms_crop(1:7));
subtracted_terms_forest(8)= sum(subtracted_terms_forest(1:7));


net_lt_YR = net_lt + subtracted_terms_crop + subtracted_terms_forest; %Eq 8
net_lt_YL = net_lt + subtracted_terms_forest; %Eq 10

net_lt_NR = net_lt + subtracted_terms_crop; %Eq 9
net_lt_YRL = net_lt_YR;

%% === Performance statistics vs ensemble mean ===
% trendy:    [nRegions x nModels x nMonths]
% ens_mean:  [nRegions x nMonths]

% units are Tg/yr for monthly data - take the mean to get annual



% --- Define model names and order ---
modelNames = { ...
    'CABLEPOP', 'CARD-EDI', 'CLASSIC', 'CLM5.0','E3SM', 'EDv3', 'IBIS', 'ISBA CTRIP', ...
    'JSBACH', 'LPJwsl', 'LPX Bern', 'OCN', 'ORCHIDEE', 'YIBs','CARD-JPL','JPL CROPS', ...
    'DLEM','LPJmL','LPJ-GUESS','SDGVM'};
% original order
 
modelNames(strcmp(modelNames,'JPL CROP')) = [];

%%% 4/1/2026 nlm
%load TRENDY_with_annual.mat % models 15-18 are annual, month 12 is the annual value, other months are NaN
% model 4 wasn't included before, by mistake
% model 19 is not included the file, is messed up (on trendy download page)
% models 20 and 21 do not include CONUS

trendy_by_year_all = regionalTotalsbyModelbyMonthbyYear;
trendy_by_year_all(8, :, :, :) = sum(trendy_by_year_all, 1);
trendy_all = mean(trendy_by_year_all,4);
trendy_annual = trendy_all(:,15:18,:) ; % annual ones 

trendy = cat(2, trendy(:,1:16,:,:),trendy_annual); 
% so now has 20 models
% trendy monthly (alphabetical), JPL-BASE, trendy annual non ED, trendy annual ED
% models 17, 18, 19, 20 are the annual ones

orderIdx = [group_A, group_B, group_annual]; % JPL CROP is not in any of these, so not used
modelNamesOrdered = modelNames(orderIdx);
modelNamesOrdered = [modelNamesOrdered, {'TR ENS MEAN'}];

trendyOrdered    = trendy(:, orderIdx, :);


[nRegions, nModels, nMonths] = size(trendy);
nModels=nModels-1; % not including JPL CROP now

% --- Initialize stats arrays ---
R_mat    = nan(nRegions, nModels);
RMSE_mat = nan(nRegions, nModels);
MB_mat   = nan(nRegions, nModels);
mean_mat   = nan(nRegions, nModels);
MB_mat_LT   = nan(nRegions, nModels);
mean_mat_LT   = nan(nRegions, nModels);

% --- Loop over regions and models ---
for r = 1:nRegions
    ens_series = (squeeze(ens_mean(r,:)))'; % this is now median, apologies
    for m = 1:15%nModels
        mod_series = squeeze(trendyOrdered(r,m,:)); % temp variable
        % mod_series is one TRENDY model results by month
        R_mat(r,m)    = corr(mod_series, ens_series);
        RMSE_mat(r,m) = sqrt(mean((mod_series - ens_series).^2)); % keep this as mean, averaging over months
        MB_mat(r,m)   = mean(mod_series - ens_series); % keep this as mean, averaging over months
        mean_mat(r,m)   = mean(mod_series); % keep this as mean, averaging over months
    end
        for m = 16:19 % the annual ones
            % annual ones are nan for months 1-11 and the annual value is
            % in month 12
        mod_series = squeeze(trendyOrdered(r,m,:)); % temp variable
       % R_mat(r,m)    = NaN;
       % RMSE_mat(r,m) = NaN;
        MB_mat(r,m)   = nanmean(mod_series) - nanmean(ens_series); % keep this as mean, averaging over months
        mean_mat(r,m)   = nanmean(mod_series); % keep this as mean, averaging over months
    end

end

%mean_mat=[mean_mat,ens_mean_annual]; % not adding TRENDY mean for now
%MB_mat(:,16+5)=mean(MB_mat,2); % 20 models now


ll={'CARD-EDI','CLASSIC','E3SM','IBIS','ISBA CTRIP','JSBACH','LPX BERN','OCN','ORCHIDEE','YIBs','CARD-JPL','JPL CROP','CABLEPOP','EDv3','LPJwsl'};
% after using orderIdx, the models are in this order for the above statistics
ll={'CARD-EDI','CLASSIC','CLM5','E3SM','IBIS','ISBA CTRIP','JSBACH','LPX BERN','OCN','ORCHIDEE','YIBs',...
    'CARD-JPL','JPL CROP','CABLEPOP','EDv3','LPJwsl',...
    'DLEM','LPJmL','LPJ-GUESS','SDGVM'};

ll(strcmp(ll,'JPL CROP')) = []; % not going to include JPL CROP, not easy to explain what it is. Eren's paper will describe, but won't be ready for a while.

% 1: No (not North America),   2: Yes (North America)
NA_array = [ ...
    1,... % SCOT CARD (UK)
    2,... % CLASSIC (Canada)
    2,... % CLM5 (NCAR, USA)
    2,... % E3SM (DOE, USA)
    2,... % IBIS (USA)
    1,... % ISBA-CTRIP (France)
    1,... % JSBACH (Germany)
    1,... % LPX-BERN (Switzerland)
    1,... % OCN (Europe, primarily Germany/France)
    1,... % ORCHIDEE (France)
    2,... % YIBs (NASA/Columbia, USA)
    2,... % JPL BASE (NASA JPL, USA)
    0,... % JPL CROP (NASA JPL, USA) (not including)
    1,... % CABLE-POP (Australia)
    2,... % EDv3 (USA)
    1,... % LPJwsl (Sweden)
    2,... % DLEM (USA)
    1,... % LPJmL (Germany)
    1,... % LPJ-GUESS (Sweden)
    1];   % SDGVM (UK)

NA_array(13)=[]; 

% from Freidlingstein 2023
% Wood Harvest / Forest Degradation 
% 0: unknown, 1: No,   2: Yes
WHFD_array =  [2,1,2,2,2,1,2,1,2,2,1,1,2,2,2,2,2,1,2,2,NaN];
WHFD_array(13)=[]; 
%WHFD_array =  [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,NaN]; % this is to apply NN/NL equation to all
% Crop Harvest
% 0: unknown, 1: No,   2: Yes(L),   3: Yes(R+L),   4: Yes(R)
CH_array =  [1,2,4,2,4,4,3,4,3,4,2,1,3,4,3,2,3,3,4,4,NaN];
CH_array(13)=[]; 
%CH_array =  [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,NaN]; % this is to apply NN/NL equation to all
% 1: No,    2: Yes % Ecosystem Demography
ED_array =  [1 1 1 1 1 1 1 1 1 1 1 1 1 2 2 2 1 1 2 2 NaN];
ED_array(13)=[]; 
% ES3M/ELM, IBIS, OCN, YIBs, CABLEPOP, DLEM :  NO FIRE EMISSIONS 
FIRE_array = [ ...
    0,... % SCOT CARD % not going to consider CARD versions
    2,... % CLASSIC
    2,... % CLM5
    1,... % E3SM
    1,... % IBIS
    2,... % ISBA CTRIP
    2,... % JSBACH
    2,... % LPX BERN
    1,... % OCN
    2,... % ORCHIDEE
    1,... % YIBs
    0,... % JPL CARD  % not going to consider CARD versions
    2,... % JPL CROP % this one gets removed in next step 
    1,... % CABLEPOP
    2,... % EDv3
    2,... % LPJwsl
    1,... % DLEM
    2,... % LPJmL
    2,... % LPJ-GUESS
    2];   % SDGVM
FIRE_array(13)=[];

for jj=1:length(WHFD_array)
    if WHFD_array(jj)==1&(CH_array(jj)==1|CH_array(jj)==2)
NN_NL_array(jj) = 1;
    else 
        NN_NL_array(jj) = 0;
    end
end

% net_lt % if WHFD_array == 1 and CH_array == 1 or 2
% net_lt_YR % if WHFD_array == 2 and CH_array == 4
% net_lt_YL % if WHFD_array == 2 and CH_array == 1 or 2
% net_lt_YRL % if WHFD_array == 2 and CH_array == 3
% net_lt_NR % if WHFD_array == 1 and CH_array == 4

trendy_before_LT = trendyOrdered;

    for m = 1:nModels
        if WHFD_array(m)==1&(CH_array(m)==1|CH_array(m)==2);LT = net_lt;end % NN/NL
        if WHFD_array(m)==2&CH_array(m)==4;LT = net_lt;end % net_lt_YR 
        if WHFD_array(m)==2&(CH_array(m)==1|CH_array(m)==2);LT = net_lt;end % net_lt_YL 
        if WHFD_array(m)==2&CH_array(m)==3;LT = net_lt;end % net_lt_YRL 
        if WHFD_array(m)==1&CH_array(m)==4;LT = net_lt;end % net_lt_NR
        if WHFD_array(m)==1&CH_array(m)==3;LT = net_lt;end % net_lt_NR (= net_lt_NRL)
        if WHFD_array(m)==0|CH_array(m)==0;LT = net_lt.*NaN;end % unknown
        for rr = 1:nRegions - 1
            trendyOrdered_LT(rr,m,:) = squeeze(trendy_before_LT(rr,m,:)) + LT(rr);
        end
      %  trendyOrdered_LT(nRegions,m,:) = squeeze(trendy_before_LT(nRegions,m,:)) + sum(LT); % total
      trendyOrdered_LT(nRegions,m,:) = sum(trendyOrdered_LT(1:7,m,:),1) ; % total
    end

% Calculate statistics again, after applying lateral transport terms
% --- Loop over regions and models ---
for r = 1:nRegions
    ens_series = (squeeze(ens_mean(r,:)))'; % this is median now
    for m = 1:19%nModels
        mod_series = squeeze(trendyOrdered_LT(r,m,:)); % temp variable, now with LT
        %R_mat(r,m)    = corr(mod_series, ens_series); 
        %RMSE_mat(r,m) = sqrt(mean((mod_series - ens_series).^2));
        if m>=16&m<=19 % annual models
            MB_mat_LT(r,m)   = nanmean(mod_series) - nanmean(ens_series);% keep this as mean, averaging over months
        else
            MB_mat_LT(r,m)   = mean(mod_series - ens_series);% keep this as mean, averaging over months
        end
        mean_mat_LT(r,m)   = nanmean(mod_series); %% keep this as mean, averaging over months
    end
end

%MB_mat_LT(:,16+5)=mean(MB_mat_LT,2);
%mean_mat_LT=[mean_mat_LT,ens_mean_annual]; %% not adding TRENDY mean for now

%return


%% === Plot metrics as heatmap tables ===
metrics   = {mean_mat, R_mat, RMSE_mat, MB_mat, array_for_mean_plot, MB_mat_LT, mean_mat_LT};
titles    = {'6-year mean (Tg C yr^{-1})','Correlation coefficient (r)', 'RMSE (Tg C yr^{-1})', ...
    'Mean Difference before LT (Tg C yr^{-1})','6-year mean (Tg C yr^{-1})', 'Mean Difference after LT (Tg C yr^{-1})',...
    '6-year mean after LT (Tg C yr^{-1})'};
% Example colormaps (adjust if you prefer different)
colormaps = parula; % flipud(hot)
%cmap_t = [140,81,10; 191,129,45; 223,194,125; 246,232,195; 256,256,256; 199,234,229; 128,205,193; ...
% 53,151,143; 1,102,94]./256;
cmap_t = [191,129,45; 223,194,125; 246,232,195; 256,256,256; 199,234,229; 128,205,193; ...
    53,151,143]./256;
%cmap_one_sided_t = [256,256,256; 199,234,229; 128,205,193; 53,151,143]./256;
cmap_one_sided_t = [256,256,256; 199,234,229; 128,205,193]./256;

% We want to spread these "knots" into 9 output colors:
n = 20;
% Interpolate between the colors:
x = linspace(1,7,7);              % original indices
xi = linspace(1,7,n);             %
cmap = interp1(x, cmap_t, xi, 'linear');  % gives n×3 matrix
x = linspace(1,3,3);              % original indices
xi = linspace(1,3,n);             %
cmap_one_sided = interp1(x, cmap_one_sided_t, xi, 'linear');  % gives n×3 matrix
colormaps={flipud(cmap_one_sided), cmap, cmap_one_sided, flipud(cmap),flipud(cmap_one_sided),flipud(cmap),flipud(cmap_one_sided)};
n = 21;
% Interpolate between the colors:
x = linspace(1,7,7);              % original indices
xi = linspace(1,7,n);             %
cmap_21 = interp1(x, cmap_t, xi, 'linear');  % gives n×3 matrix

regionNames = {'Northwest', 'Southwest', 'N GreatPlains', 'S GreatPlains', ...
    'Midwest', 'Southeast', 'Northeast', 'Total'};

for figi = 1:7
    invModelNames={'AMES','BAKER','CAMS','CMS-FLUX','COLA','CSU','CT','JHU','LoFI','NIES','OU','TM5 4DVAR','UT','WOMBAT','OCO2 ENS MEDIAN'};
%if figi==1|figi==7;modelNamesOrdered(21) = {'OCO2 ENS MEAN'};end
%if figi==7;modelNamesOrdered(21) = {'OCO2 ENS MEAN'};end
if figi==4|figi==6;modelNamesOrdered(21) = {'TR ENS MEAN'};end
    if figi==2
        figure('Position',[200 200 1100 450]);
    else
        figure('Position',[200 200 1100 450]);
    end
    imagesc(metrics{figi});
    colormap(colormaps{figi});
    colorbar;
    caxis auto; % adjust if you want fixed scales for comparability
    if figi==1;clim([-80 0]);end
    if figi==2;clim([-1 1]);end
    if figi==3;clim([0 500]);end
    if figi==4;clim([-300 300]);end
    if figi==5;clim([-250 0]);end
    if figi==6;clim([-300 300]);end
    if figi==7;clim([-80 0]);end

   if figi==4|figi==6 
       nModels=19; % not doing ens mean
   elseif figi==5
       nModels=15;%?
   elseif figi==1|figi==7
       nModels=19;
   else 
       nModels=15; 
   end
 %  {mean_mat, R_mat, RMSE_mat, MB_mat, array_for_mean_plot, MB_mat_LT, mean_mat_LT};
%     1           2     3         4       5                     6      7
    if figi~=5
        set(gca, 'XTick', 1:nModels, 'XTickLabel', modelNamesOrdered, ...
        'YTick', 1:nRegions, 'YTickLabel', regionNames, ...
        'XTickLabelRotation', 45, 'FontSize', 14,'FontWeight', 'bold');
    else % figi==5
        set(gca, 'XTick', 1:nModels, 'XTickLabel', invModelNames, ...
        'YTick', 1:nRegions, 'YTickLabel', regionNames, ...
        'XTickLabelRotation', 45, 'FontSize', 14,'FontWeight', 'bold');
    end
    title(titles{figi}, 'FontSize', 14, 'FontWeight', 'bold');

   
    % Annotate each cell with numeric value
    for rr = 1:nRegions
        for cc = 1:nModels
           if figi==2; text(cc, rr, sprintf('%.2f', metrics{figi}(rr,cc)), ...
                'HorizontalAlignment', 'center', ...
                'FontSize', 14, 'FontWeight', 'bold', 'Color', 'k');
           else
               text(cc, rr, sprintf('%.0f', metrics{figi}(rr,cc)), ...
                'HorizontalAlignment', 'center', ...
                'FontSize', 14, 'FontWeight', 'bold', 'Color', 'k');
           end
        end
    end
    if figi==4|figi==6;
        text(21.5,8.5,'More drawdown', 'Rotation', 90,'FontSize',14,'FontWeight','bold','FontAngle', 'italic'); 
        text(21.5,3,'Less drawdown', 'Rotation', 90,'FontSize',14,'FontWeight','bold','FontAngle', 'italic');
    end
    if figi==2|figi==3
    xlim([0.5 15.5]); %
    end
if figi==2
% After plotting and setting axes
hold on
% Index where ED models start (last 3 models)
edStart = nModels - 3  +1;
% Draw vertical separator
xline(edStart - 0.5, 'k-', 'LineWidth', 2);
% Add labels above the plot
yl = ylim;
yText = yl(2) + 0.04 * range(yl);
text((edStart-1)/2 + 0.5, yText, 'Non-DVS models', ...
    'HorizontalAlignment','center', 'FontSize',12, 'FontWeight','bold');
text((edStart + nModels)/2, yText, 'DVS models', ...
    'HorizontalAlignment','center', 'FontSize',12, 'FontWeight','bold');
% Expand ylim slightly to make room
ylim([yl(1), yl(2) + 0.1 * range(yl)]);

end
if figi==4|figi==6
% After plotting and setting axes
hold on
% Index where ED models start 
edStart = 14-1;edEnd = 16-1;
% Draw vertical separator
xline(edStart - 0.5, 'k-', 'LineWidth', 2);
xline(edEnd + 0.5, 'k-', 'LineWidth', 2);
% Index where ED models start 
edAnnualStart = 19-1;edAnnualEnd = 20-1;
% Draw vertical separator
xline(edAnnualStart - 0.5, 'k-', 'LineWidth', 2);
%xline(edAnnualEnd + 0.5, 'k-', 'LineWidth', 2);
% Add labels above the plot
yl = ylim;
yText = yl(2) + 0.04 * range(yl);
text((edStart-1)/2 + 0.5, yText, 'Non-DVS models', ...
    'HorizontalAlignment','center', 'FontSize',12, 'FontWeight','bold');
text(14.0, yText, 'DVS models', ...
    'HorizontalAlignment','center', 'FontSize',12, 'FontWeight','bold');
text(16.5, yText, 'Non-DVS', ...
    'HorizontalAlignment','center', 'FontSize',12, 'FontWeight','bold');
text(18.5, yText, 'DVS models', ...
    'HorizontalAlignment','center', 'FontSize',12, 'FontWeight','bold');
% Expand ylim slightly to make room
ylim([yl(1), yl(2) + 0.1 * range(yl)]);

end

end
% figure(3); print -djpeg map_card_jpl
% figure(6); print -djpeg six_year_mean
% figure(7); print -djpeg trendy_corr_coeff
% figure(8); print -djpeg trendy_rmse
% figure(9); print -djpeg trendy_lt
% figure(9); print -djpeg trendy_mb
% figure(10); print -djpeg six_year_mean_inv
% figure(11); print -djpeg lt_rm_components

% new version of matlab - now you have to save the jpgs by hand or else the
% font size is crazy small


   lt_rm_components(8,:)=sum(lt_rm_components,1)
   lt_rm_c(8,:)=sum(lt_rm_c,1)
   lt_rm_components(:,length(lt_rm_components)+1)=sum(lt_rm_components,2);
   lt_rm_c(:,length(lt_rm_c)+1)=sum(lt_rm_c,2);

   lt_rm_components(find(abs(lt_rm_components)<0.5))=abs(lt_rm_components(find(abs(lt_rm_components)<0.5)));
   % don't put -0 on the plot
   lt_rm_c(find(abs(lt_rm_c)<0.5))=abs(lt_rm_c(find(abs(lt_rm_c)<0.5)));
   % don't put -0 on the plot

figure('Position',[200 200 1100 450]);
    imagesc(lt_rm_components);
    colormap(flipud(cmap_21)); % odd so that zero is white
    colorbar;
    caxis auto; % adjust if you want fixed scales for comparability
    clim([-20 20]);

    set(gca, 'XTick', 1:length(lt_rm_components), 'XTickLabel', lt_rm_components_name, ...
        'YTick', 1:nRegions, 'YTickLabel', regionNames, ...
        'XTickLabelRotation', 45, 'FontSize', 14,'FontWeight', 'bold');
    title('Lateral Transport Components (Tg C yr^{-1})', 'FontSize', 14, 'FontWeight', 'bold');
       
    text(15.7,8.5,'Drawdown', 'Rotation', 90,'FontSize',14,'FontWeight','bold','FontAngle', 'italic'); 
    text(15.7,3,'Respiration', 'Rotation', 90,'FontSize',14,'FontWeight','bold','FontAngle', 'italic');

    % Annotate each cell with numeric value
    for rr = 1:nRegions
        for cc = 1:length(lt_rm_components)
            text(cc, rr, sprintf('%.0f', lt_rm_components(rr,cc)), ...
                'HorizontalAlignment', 'center', ...
                'FontSize', 14, 'FontWeight', 'bold', 'Color', 'k');
        end
    end

figure('Position',[200 200 1100 450]);
    imagesc(lt_rm_c);
    colormap(flipud(cmap_21)); % odd so that zero is white
    colorbar;
    caxis auto; % adjust if you want fixed scales for comparability
    clim([-20 20]);

    set(gca, 'XTick', 1:length(lt_rm_c), 'XTickLabel', lt_rm_c_name, ...
        'YTick', 1:nRegions, 'YTickLabel', regionNames, ...
        'XTickLabelRotation', 45, 'FontSize', 14,'FontWeight', 'bold');
    title('Lateral Transport Components (Tg C yr^{-1})', 'FontSize', 14, 'FontWeight', 'bold');
       
    text(23.2,8.5,'Drawdown', 'Rotation', 90,'FontSize',14,'FontWeight','bold','FontAngle', 'italic'); 
    text(23.2,3,'Respiration', 'Rotation', 90,'FontSize',14,'FontWeight','bold','FontAngle', 'italic');

    % Annotate each cell with numeric value
    for rr = 1:nRegions
        for cc = 1:length(lt_rm_c)
            text(cc, rr, sprintf('%.0f', lt_rm_c(rr,cc)), ...
                'HorizontalAlignment', 'center', ...
                'FontSize', 14, 'FontWeight', 'bold', 'Color', 'k');
        end
    end


    %%
    


 regionNames = {'Northwest', 'Southwest', 'N GreatPlains', 'S GreatPlains', ...
     'Midwest', 'Southeast', 'Northeast', 'TOTAL'};
% 
% % Color map (normalized to 0–1)
% cmap_t = [191,129,45; 
%           223,194,125; 
%           246,232,195; 
%           256,256,256; 
%           199,234,229; 
%           128,205,193; 
%           53,151,143] ./ 256;

% Create figure
    fh = figure;
    fh.Position = [50, 50, 900, 600];
for p=6:6%3:3%6:6
    if p~=5
    subplot(2,3,p) %may want to change to 2,2,p
    else 
        subplot(2,2,4)
    end
    if p==1
y1 = nanmedian(MB_mat(:,find(WHFD_array>0&CH_array>0)),2); % median instead of mean
y2 = nanmedian(MB_mat_LT(:,find(WHFD_array>0&CH_array>0)),2); % median instead of mean
y1_std = nanstd(MB_mat(:,find(WHFD_array>0&CH_array>0)),0,2);
y2_std = nanstd(MB_mat_LT(:,find(WHFD_array>0&CH_array>0)),0,2);
title_text='ALL';
idx = find(WHFD_array>0&CH_array>0);
pvals_p1 = nan(size(y1))';
for i = 1:length(y1)
    x1 = MB_mat(i,idx);      % 
    x2 = MB_mat_LT(i,idx);        
    [~,pv] = ttest2(x1, x2);             % use ttest if paired
    pvals_p1(i) = pv;
end

end
if p==2
y1 = nanmedian(MB_mat(:,find(WHFD_array==1&(CH_array==1|CH_array==2))),2); % median instead of mean
y2 = nanmedian(MB_mat_LT(:,find(WHFD_array==1&(CH_array==1|CH_array==2))),2);% median instead of mean
y1_std = nanstd(MB_mat(:,find(WHFD_array==1&(CH_array==1|CH_array==2))),0,2);
y2_std = nanstd(MB_mat_LT(:,find(WHFD_array==1&(CH_array==1|CH_array==2))),0,2);
% above is to do all models with NN/NL
title_text='NN/NL models only';
idx = find(WHFD_array==1&(CH_array==1|CH_array==2));
pvals_p2 = nan(size(y1))';
for i = 1:length(y1)
    x1 = MB_mat(i,idx);      % 
    x2 = MB_mat_LT(i,idx);        
    [~,pv] = ttest2(x1, x2);             % use ttest if paired
    pvals_p2(i) = pv;
end

end
if p==3
y1 = nanmedian(MB_mat(:,find(ED_array==1)),2);%MB_mat for before, MB_mat_LT for after
% median instead of mean
y2 = nanmedian(MB_mat(:,find(ED_array==2)),2);% median instead of mean
y1_std = nanstd(MB_mat(:,find(ED_array==1)),0,2);
y2_std = nanstd(MB_mat(:,find(ED_array==2)),0,2);
title_text='Before LT';
idx1 = find(ED_array==1); idx2 = find(ED_array==2);
pvals_p3 = nan(size(y1))';
for i = 1:length(y1)
    x1 = MB_mat(i,idx1);      % 
    x2 = MB_mat(i,idx2);        
    [~,pv] = ttest2(x1, x2);             % use ttest if paired
    pvals_p3(i) = pv;
end

end
if p==4
y1 = nanmedian(MB_mat_LT(:,find(ED_array==1)),2);%MB_mat for before, MB_mat_LT for after
% median instead of mean
y2 = nanmedian(MB_mat_LT(:,find(ED_array==2)),2);% median instead of mean
y1_std = nanstd(MB_mat_LT(:,find(ED_array==1)),0,2);
y2_std = nanstd(MB_mat_LT(:,find(ED_array==2)),0,2);
title_text='After LT';
idx1 = find(ED_array==1); idx2 = find(ED_array==2);
pvals_p4 = nan(size(y1))';
for i = 1:length(y1)
    x1 = MB_mat_LT(i,idx1);      % 
    x2 = MB_mat_LT(i,idx2);        
    [~,pv] = ttest2(x1, x2);             % use ttest if paired
    pvals_p4(i) = pv;
end


end
if p==5
    test=mean_mat_LT;
y1 = nanmedian(test(:,find(NA_array==1)),2); % median instead of mean
y2 = nanmedian(test(:,find(NA_array==2)),2); % median instead of mean
y1_std = nanstd(test(:,find(NA_array==1)),0,2);
y2_std = nanstd(test(:,find(NA_array==2)),0,2);
title_text='After LT';
idx1 = find(NA_array==1); idx2 = find(NA_array==2);
pvals_p5 = nan(size(y1))';
for i = 1:length(y1)
    x1 = test(i,idx1);      % 
    x2 = test(i,idx2);        
    [~,pv] = ttest2(x1, x2);             % use ttest if paired
    pvals_p5(i) = pv;
end
end

if p==6
    test=MB_mat; % MB_mat for before LT, MB_mat_LT for after LT
y1 = nanmedian(test(:,find(FIRE_array==1)),2);% % median instead of mean
y2 = nanmedian(test(:,find(FIRE_array==2)),2); % median instead of mean
y1_std = nanstd(test(:,find(FIRE_array==1)),0,2);
y2_std = nanstd(test(:,find(FIRE_array==2)),0,2);
title_text=' FIRE';
idx1 = find(FIRE_array==1); idx2 = find(FIRE_array==2);
pvals_p6 = nan(size(y1))';
for i = 1:length(y1)
    x1 = test(i,idx1);      % 
    x2 = test(i,idx2);        
    [~,pv] = ttest2(x1, x2);             % use ttest if paired
    pvals_p6(i) = pv;
end
end
hold on;

% Bar chart (grouped)
b = bar([y1(:), y2(:)], 'grouped');
hold on
% Apply colors — use two from the colormap (e.g., first and last)
b(1).FaceColor = cmap_t(1,:); % First dataset color
b(2).FaceColor = cmap_t(end,:); % Second dataset color
% Number of groups
ngroups = size(y1,1);
nbars = 2;

% Calculate x positions for each bar
x = nan(ngroups, nbars);
for i = 1:nbars
    x(:,i) = b(i).XEndPoints;
end

% Add error bars
errorbar(x(:,1), y1, y1_std, 'k', 'linestyle', 'none');
errorbar(x(:,2), y2, y2_std, 'k', 'linestyle', 'none');

hold off

% Add labels and formatting
set(gca, 'XTickLabel', regionNames, 'XTick', 1:length(regionNames));
set(gca,'FontSize',14); set(gca,'FontWeight','bold')
xtickangle(30);
ylabel('Median Difference (Tg C yr^{-1})');
%title('Regional Comparison');
if p==1|p==2;legend({'Before LT','After LT'}, 'Location', 'northwest');end;
if p==3|p==4;legend({'Non-DVS','DVS'}, 'Location', 'northwest');end;
if p==6;legend({'No Fire','Fire'}, 'Location', 'northwest');end;
if p==5;legend({'Non-NA','NA'}, 'Location', 'northwest');end;
if p==5; 
    ylim([-400 100]);
else 
    ylim([-120 400]);
end
ax=axis; ymin=ax(3); ymax=ax(4);
yticks(linspace(ymin, ymax, 4))
if p==3; 
    ylim([-120 400]);
end
ax=axis; ymin=ax(3); ymax=ax(4);
yticks(linspace(ymin, ymax, 5))
%grid on;
% if p==1,text(7.8,-70,'a','FontSize',12);end
% if p==2,text(7.8,-70,'b','FontSize',12);end
% if p==3,text(7.8,-70,'c','FontSize',12);end
% if p==4,text(7.8,-70,'d','FontSize',12);end
% Improve layout
box on;
hold off;
% figure(11); print -djpeg comparison_bar

% to make these figures in particular look better
% exportgraphics(gcf,'no_dvs_dvs.jpg','Resolution',600)
% exportgraphics(gcf,'no_fire_fire.jpg','Resolution',600)

end
%%
% for reference
% ll={'SCOT CARD','CLASSIC','E3SM','IBIS','ISBA CTRIP','JSBACH','LPX BERN','OCN','ORCHIDEE','YIBs','JPL CARD','JPL CROP','CABLEPOP','EDv3','LPJwsl'}
% regionNames = {'Northwest', 'Southwest', 'N GreatPlains', 'S GreatPlains', 'Midwest', 'Southeast', 'Northeast'};         
%%

    fh = figure;
    fh.Position = [50, 50, 600, 400];
ff = [34.7 184.2 61.6 233.2 311.3 353.8 212.8 ]';
ff(8)=sum(ff(1:7));
ff_inv=ff;
ff=ff*0; % cluge to not include ff

y3 = nanmedian(mean_mat_LT(:,:),2)+ff; % all % median instead of mean
y3_std = nanstd(mean_mat_LT(:,:),0,2); % all % 
nanmedian(mean_mat(:,:),2)
nanstd(mean_mat(:,:),0,2)
[r3,q3]=iqr(mean_mat(:,:),2)


% from byrne et al., 2026
y2_pre = [-2.3, 190.6, 17.3, 205.8, 182.5, 199.4, 180.5]'; % inventory after LT
y2_pre(8)=sum(y2_pre(1:7));
y2_pre=y2_pre-ff_inv;
load gfed5_1.mat % regionalTotalsFire
y2=y2_pre; % +regionalTotalsFire; % actually inventory already includes fire, per Grant Domkeh

% y1 = nanmean(array_for_mean_plot(:,:),2)+ff; % all  OCO-2 MIP 
y1 = nanmedian(array_for_mean_plot(:,1:14),2)+ff; % all  OCO-2 MIP % median instead of mean
% don't include the 15th column b/c it's the median
y1_std = nanstd(array_for_mean_plot(:,1:14),0,2); % all
[r1,q1]=iqr(array_for_mean_plot(:,1:14),2)

% Bar chart (grouped)
%b = bar([y1(:), y2(:), y3(:), y4(:), y5(:)], 'grouped');
b = bar([y1(:), y2(:), y3(:)], 'grouped');
hold on
% Apply colors — use four from the colormap 
b(1).FaceColor = cmap_t(5,:); % First dataset color
b(2).FaceColor = shades_of_gray(2,:);%cmap_t(6,:); % Second dataset color
b(3).FaceColor = cmap_t(7,:); % Third dataset color
% b(4).FaceColor = [1,1,1]; 
% b(5).FaceColor = cmap_t(7,:);
% Number of groups
ngroups = size(y1,1);
nbars = 3;% 5;

% Calculate x positions for each bar
x = nan(ngroups, nbars);
for i = 1:nbars
    x(:,i) = b(i).XEndPoints;
end



% Add error bars
errorbar(x(:,1), y1, y1_std, 'k', 'linestyle', 'none');
errorbar(x(:,3), y3, y3_std, 'k', 'linestyle', 'none');
% errorbar(x(:,4), y4, y4_std, 'k', 'linestyle', 'none');
% errorbar(x(:,5), y5, y5_std, 'k', 'linestyle', 'none');

hold off

% Add labels and formatting
set(gca, 'XTickLabel', regionNames, 'XTick', 1:length(regionNames));
set(gca,'FontSize',12)
xtickangle(30);
ylabel('Biogenic CO_2 flux (Tg C yr^{-1})');
%ylabel('NBP (Tg C yr^{-1})');
%legend({'OCO-2 MIP','INVENTORY','TRENDY NN/NL','TRENDY NN/NL-BEFORE','TRENDY ALL'}, 'Location', 'northwest');
legend({'OCO-2 MIP','INVENTORY LT','TRENDY+ LT'}, 'Location', 'southwest');

%ylim([-120 590]); %title(title_text);
%grid on;
%if p==1,text(7.8,-70,'a','FontSize',12);end
% Improve layout
box on;
%hatchfill2(b(4), 'single','HatchAngle', 45,'HatchDensity', 60);
hold off;

% y1: OCO-2 MIP y2: INVENTORY y3: TRENDY NN/NL
% y4: TRENDY NN/NL BEFORE y5: TRENDY ALL
idx3 = find(WHFD_array>0 & CH_array>0);



pvals = nan(size(y1))';
for i = 1:length(y1)
    x1 = array_for_mean_plot(i,1:14);      % OCO-2 MIP ensemble (don't include 15th)
    if 1==0 % exclude couple inversions
        x1(11)=NaN;x1(12)=NaN;
        % x1new=x1(isfinite(x1));
    end
    x3 = mean_mat_LT(i,idx3);           % subset after LT
    [~,pv] = ttest2(x1, x3);             % use ttest if paired
    pvals(i) = pv;
end
significant = pvals < 0.05; % after LT   % for paper!

pvals_inv_trendy = nan(size(y1))';
for i = 1:length(y1)
    x3 = y2(i);      % inventory
    x2 = mean_mat_LT(i,idx3);           % trendy subset after LT
 
    [~,pv] = ttest2(x3, x2);             % inventory / trendy
   % [~,pv] = ttest2(x3, x1);             % inventory / inversions
    pvals_inv_trendy(i) = pv;
end
significant = pvals_inv_trendy < 0.05; % 

pvals_inv_inv = nan(size(y1))';
for i = 1:length(y1)
    x3 = y2(i);      % inventory
      x1 = array_for_mean_plot(i,1:14);      % OCO-2 MIP ensemble, don't include 15th
    [~,pv] = ttest2(x3, x1);             % inventory / inversions
    pvals_inv_inv(i) = pv;
end
significant = pvals_inv_inv < 0.05; % 


%%


    fh = figure;
    fh.Position = [50, 50, 900, 400];

median_oco=nanmedian(array_for_mean_plot,2);

y1 = nanmedian(MB_mat(:,find(WHFD_array==1&(CH_array==2|CH_array==3|CH_array==4))),2); %incorrect
y1 = nanmedian(mean_mat(:,find(WHFD_array==1&(CH_array==2|CH_array==3|CH_array==4))),2)-median_oco;
% median instead of mean
y1_std = nanstd(MB_mat(:,find(WHFD_array==1&(CH_array==2|CH_array==3|CH_array==4))),0,2);
y1_std = nanstd(mean_mat(:,find(WHFD_array==1&(CH_array==2|CH_array==3|CH_array==4)))-median_oco,0,2);

y2 = nanmedian(MB_mat_LT(:,find(WHFD_array==1&(CH_array==2|CH_array==3|CH_array==4))),2);
y2 = nanmedian(mean_mat_LT(:,find(WHFD_array==1&(CH_array==2|CH_array==3|CH_array==4))),2)-median_oco;
% median instead of mean
y2_std = nanstd(MB_mat_LT(:,find(WHFD_array==1&(CH_array==2|CH_array==3|CH_array==4))),0,2);
y2_std = nanstd(mean_mat_LT(:,find(WHFD_array==1&(CH_array==2|CH_array==3|CH_array==4)))-median_oco,0,2);

y3 = nanmedian(MB_mat(:,find(WHFD_array==2&(CH_array==2|CH_array==3|CH_array==4))),2);
y3 = nanmedian(mean_mat(:,find(WHFD_array==2&(CH_array==2|CH_array==3|CH_array==4))),2)-median_oco;
% median instead of mean
y3_std = nanstd(MB_mat(:,find(WHFD_array==2&(CH_array==2|CH_array==3|CH_array==4))),0,2);
y3_std = nanstd(mean_mat(:,find(WHFD_array==2&(CH_array==2|CH_array==3|CH_array==4)))-median_oco,0,2);

y4 = nanmedian(MB_mat_LT(:,find(WHFD_array==2&(CH_array==2|CH_array==3|CH_array==4))),2);
y4 = nanmedian(mean_mat_LT(:,find(WHFD_array==2&(CH_array==2|CH_array==3|CH_array==4))),2)-median_oco;
% median instead of mean
y4_std = nanstd(MB_mat_LT(:,find(WHFD_array==2&(CH_array==2|CH_array==3|CH_array==4))),0,2);
y4_std = nanstd(mean_mat_LT(:,find(WHFD_array==2&(CH_array==2|CH_array==3|CH_array==4)))-median_oco,0,2);

y5 = nanmedian(MB_mat(:,:),2); % all
y5 = nanmedian(mean_mat(:,:),2)-median_oco;
% median instead of mean
y5_std = nanstd(MB_mat(:,:),0,2); % all
y5_std = nanstd(mean_mat(:,:)-median_oco,0,2);

y6 = nanmedian(MB_mat_LT(:,:),2); % all
y6 = nanmedian(mean_mat_LT(:,:),2)-median_oco;
% median instead of mean
y6_std = nanstd(MB_mat_LT(:,:),0,2); % all
y6_std = nanstd(mean_mat_LT(:,:)-median_oco,0,2);

% Bar chart (grouped)
b = bar([y1(:), y2(:), y3(:), y4(:), y5(:), y6(:)], 'grouped');
hold on
% Apply colors — use four from the colormap 
b(1).FaceColor = [1,1,1]; 
b(2).FaceColor = cmap_t(1,:); % First dataset color 1
b(3).FaceColor = [1,1,1]; 
 b(4).FaceColor = cmap_t(3,:); % Second dataset color 3
 b(5).FaceColor = [1,1,1];
 b(6).FaceColor = shades_of_purple(3,:); %cmap_t(3,:);% Third dataset color 7
% Number of groups
ngroups = size(y1,1);
nbars = 6;% 5;

% Calculate x positions for each bar
x = nan(ngroups, nbars);
for i = 1:nbars
    x(:,i) = b(i).XEndPoints;
end

% Add error bars
gray=[0.7 0.7 0.7];
errorbar(x(:,1), y1, y1_std, 'k', 'color',gray,'linestyle', 'none');
errorbar(x(:,2), y2, y2_std, 'k', 'color',gray, 'linestyle', 'none');
errorbar(x(:,3), y3, y3_std, 'k', 'color',gray, 'linestyle', 'none');
 errorbar(x(:,4), y4, y4_std, 'k', 'color',gray, 'linestyle', 'none');
 errorbar(x(:,5), y5, y5_std, 'k', 'color',gray, 'linestyle', 'none');
 errorbar(x(:,6), y6, y6_std, 'k', 'color',gray, 'linestyle', 'none');

hold off

% Add labels and formatting
set(gca, 'XTickLabel', regionNames, 'XTick', 1:length(regionNames));
set(gca,'FontSize',12)
xtickangle(30);
ylabel('CO_2 flux difference (Tg C yr^{-1})');
%ylabel('NBP difference (Tg C yr^{-1})');
legend({'No wood harvest BEFORE','No wood harvest AFTER','Wood harvest BEFORE','Wood harvest AFTER','ALL BEFORE','ALL AFTER'}, 'Location', 'northwest');


%ylim([-120 590]); %title(title_text);
%grid on;
%if p==1,text(7.8,-70,'a','FontSize',12);end
% Improve layout
box on;
%hatchfill2(b(4), 'single','HatchAngle', 45,'HatchDensity', 60);
hold off;

% y1: OCO-2 MIP y2: INVENTORY y3: TRENDY NN/NL
% y4: TRENDY NN/NL BEFORE y5: TRENDY ALL
idx = find(WHFD_array>0 & CH_array>0 );

if 1==1
pvals = nan(size(y1))';
for i = 1:length(y1)
    x1 = mean_mat(i,idx);      % before
    x2 = mean_mat_LT(i,idx);   %  after LT
    [~,p] = ttest2(x1, x2);    % use ttest if paired, ttest2 if not
    pvals(i) = p;
end
significant = pvals < 0.05; % 

end


% %%
% 
%     fh = figure;
%     fh.Position = [50, 50, 600, 400];
% hold on;
% r_to_do=[1 6 7 8];
% for i=1:length(r_to_do)
% subplot(2,2,i)
% six_year_model_mean=mean(metrics{1}(r_to_do(i),:),2);
% 
% do_metric = 4; % mean bias before LT
% %do_metric = 6; % mean bias after LT
% 
% temp = metrics{do_metric}(r_to_do(i),:);
% x1=temp(find(WHFD_array==1));
% x2=temp(find(WHFD_array==2));
% x = [x1'; x2'];
% g1 = repmat({'No'},length(x1),1);
% g2 = repmat({'Yes'},length(x2),1);
% g = [g1; g2];
% cmap_new=[cmap_t(end,:)];
%      b = boxplot(x, g, 'Colors',cmap_new,'MedianStyle','target');
% title(strcat('Wood Harvest Modeled ? '));
% hold on;
% plot(1, temp(12),'^','Color','k', 'MarkerFaceColor',[0.5 0.5 0.5],'MarkerSize',10); hold on; 
% plot(2, temp(13),'^','Color','k','MarkerFaceColor',cmap_new,'MarkerSize',10);
% ylabel('Mean Bias (Tg C/yr)')
% ax=axis;
% if r_to_do(i)==8
%     axis([ax(1) ax(2) -100 800]); %-50 350 
%     text(1,-40,num2str(length(x1)));
%     text(2,-40,num2str(length(x2)));
%     text(1.9,740,regionNames{r_to_do(i)});
%     if do_metric==4
%         text(1.2,740,'Before LT','FontWeight','bold');
%     end
% 
% else 
%     axis([ax(1) ax(2) -100 300]); %-50 200
%     text(1,-70,num2str(length(x1)));
%     text(2,-70,num2str(length(x2)));
%     text(1.9,280,regionNames{r_to_do(i)});
%      if do_metric==4
%         text(1.2,280,'Before LT','FontWeight','bold');
%     end
% end
% 
% end
%    fh = figure;
%     fh.Position = [50, 50, 600, 400];
% hold on;
% r_to_do=[5 8];
% for i=1:length(r_to_do)
%     six_year_model_mean=mean(metrics{1}(r_to_do(i),:),2);
% temp = metrics{do_metric}(r_to_do(i),:);
%     subplot(2,2,i)
% % x1=temp(find(CH_array==1));
% % x2=temp(find(CH_array==2));
% % x3=temp(find(CH_array==3));
% % x4=temp(find(CH_array==4));
% x1=temp(find(CH_array==1|CH_array==2));
% x2=temp(find(CH_array==3));
% x3=temp(find(CH_array==4));
% %x = [x1'; x2'; x3'; x4'];
% x = [x1'; x2'; x3'];
% g1 = repmat({'No|YesL'},length(x1),1);
% g2 = repmat({'YesRL'},length(x2),1);
% g3 = repmat({'YesR'},length(x3),1);
% %g4 = repmat({'YesR'},length(x4),1);
% %g = [g1; g2; g3; g4];
% g = [g1; g2; g3];
% % Create the box plot and set the face colors
% % cmap_new=[cmap_t(1,:);cmap_t(2,:);cmap_t(6,:);cmap_t(end,:)]
%      b = boxplot(x, g, 'Colors',cmap_new,'MedianStyle','target');
% title(strcat('Crop Harvest Modeled ? '));
% hold on; 
% plot(1, temp(12),'^','Color','k', 'MarkerFaceColor',[0.5 0.5 0.5],'MarkerSize',10); hold on; 
% plot(2, temp(13),'^','Color','k','MarkerFaceColor',cmap_new,'MarkerSize',10);
% ax=axis;
% ylabel('Mean Bias (Tg C/yr)'); 
% if r_to_do(i)==8
%     axis([ax(1) ax(2) -100 800]); %-50 350 
%     text(1,-40,num2str(length(x1)));
%     text(2,-40,num2str(length(x2)));
%     text(3,-40,num2str(length(x3)));
%     text(2.8,740,regionNames{r_to_do(i)});
%      if do_metric==4
%         text(1.6,740,'Before LT','FontWeight','bold');
%     end
% else 
%     axis([ax(1) ax(2) -100 300]); %-50 200
%     text(1,-70,num2str(length(x1)));
%     text(2,-70,num2str(length(x2)));
%     text(3,-70,num2str(length(x3)));
%     text(2.8,280,regionNames{r_to_do(i)});
%      if do_metric==4
%         text(1.6,280,'Before LT','FontWeight','bold');
%     end
% end
% 
% %text(4,0,num2str(length(x4)));
% end
% 
%    fh = figure;
%     fh.Position = [50, 50, 600, 400];
% hold on;
% r_to_do=[5 6 7 8]; % not clear which regions make sense, maybe all
% for i=1:length(r_to_do)
%     six_year_model_mean=mean(metrics{1}(r_to_do(i),:),2);
% temp = metrics{do_metric}(r_to_do(i),:);
%     subplot(2,2,i)
% x1=temp(find(ED_array==1));
% x2=temp(find(ED_array==2));
% x = [x1'; x2'];
% g1 = repmat({'No'},length(x1),1);
% g2 = repmat({'Yes'},length(x2),1);
% g = [g1; g2];
% % Create the box plot and set the face colors
% % cmap_new=[cmap_t(1,:);cmap_t(2,:);cmap_t(6,:);cmap_t(end,:)]
%      b = boxplot(x, g, 'Colors',cmap_new,'MedianStyle','target');
% title(strcat('Ecosystem Demography Model ? '));
% ax=axis;
% hold on; 
% ylabel('Mean Bias (Tg C/yr)'); 
% if r_to_do(i)==8
%     axis([ax(1) ax(2) -100 800]); %-50 350 
%     text(1,-40,num2str(length(x1)));
%     text(2,-40,num2str(length(x2)));
%     text(1.9,740,regionNames{r_to_do(i)});
%      if do_metric==4
%         text(1.2,740,'Before LT','FontWeight','bold');
%     end
% else 
%     axis([ax(1) ax(2) -100 300]); %-50 200
%     text(1,-70,num2str(length(x1)));
%     text(2,-70,num2str(length(x2)));
%     text(1.9,280,regionNames{r_to_do(i)});
%      if do_metric==4
%         text(1.2,280,'Before LT','FontWeight','bold');
%     end
% end
% end




