% read_nlt_annual.m

 function [thr,tlr,tcr_re,tcr_bio,tfo_re,tfo_bio, hr,lr,cr_re,cr_bio,fo_re,fo_bio,rem,lem, tct,tlf,twt,thwp,trem,tlem,tab,taex ] = read_nlt_annual
% thr is RP_{\text{human,i}}^{Hcrop} in the paper  SUBTRACT VARIABLES THAT START WITH t
% hr is RP_{\text{human,i}}^{direct} in the paper  ADD VARIABLES THAT DON'T START WITH t
% ALL ARE MAGNITUDES


% Initialize combined structure
rC = struct();

% List of .mat files
fileList = {
    'ag_grass_soil_stockchange.mat',
    'forest_harvest.mat',
    'forest_stockchange.mat',
    'CONUS_data.mat',
    'livestock_respiration.mat',
    'state_level_data.mat',
    'crop_harvest.mat',
    'human_resp_yinon_bar_on.mat'
    
}; %

for i = 1:length(fileList)
    % Load each file into a temporary variable
    data = load(fileList{i});
    
    % Check if 'regionalComponents' exists in the file
    if isfield(data, 'regionalComponents')
        fields = fieldnames(data.regionalComponents);
        
        % Copy each field into the combined structure
        for j = 1:length(fields)
            f = fields{j};
            rC.(f) = data.regionalComponents.(f);
        end
    else
        warning('File %s does not contain "regionalComponents"', fileList{i});
    end
end

for i = 1:length(fields)
    fname = fields{i};
    disp(fname)
    disp(rC.(fname))
    disp(sum(rC.(fname), 1));
end

if 1==0 % list of the components
    rC.forest_residual 
    rC.forest_biofuel 
    rC.PIC_SWDS_stockchange 
    rC.wood_trade 
    rC.crop_landfill_stockchange  
    rC.crop_trade 
    rC.crop_residual 
    rC.crop_biofuel 
    rC.livestock_respiration 
    rC.river_emissions 
    rC.lake_emissions
    rC.lake_river_burial 
    rC.coastal_carbon_export 
    rC.incineration
    rC.human_respiration % average of 2015-2019
    rC.ff_and_ippu % not in TRENDY and removed from OCO2-MIP already
    rC.ag_grass_soil_stockchange % modeled by TRENDY
    rC.forest_stockchange % modeled by TRENDY
    rC.forest_harvest %  modeled by TRENDY, but part of the respiration in the "wrong" place
    rC.crop_harvest %  modeled by TRENDY, but part of the respiration in the "wrong" place
end

year_s = 2015:2020; % 2015:2018; % specific 
year_f = 2015:2020; % years in the files

% distributed uniformally over CONUS (i.e., by regional area) in the rC
% files (parentheses are what is actually used:
% rC.forest_residual (uniform), rC.PIC_SWDS_stockchange (forest harvest), rC.wood_trade (forest harvest),
% rC.crop_residual (human respiration), rC.crop_landfill_stockchange (crop harvest), 
% rC.crop_trade (crop harvest), rC.river_emissions (uniform)
% rC.lake_emissions (uniform), rC.lake_river_burial (uniform),
% rC.coastal_carbon_export (uniform)

lr = mean(rC.livestock_respiration(:,min(year_s)-min(year_f)+1:max(year_s)-min(year_f)+1),2)
hr = mean(rC.human_respiration(:,min(year_s)-min(year_f)+1:max(year_s)-min(year_f)+1),2)
cr_re = mean(rC.crop_residual(:,min(year_s)-min(year_f)+1:max(year_s)-min(year_f)+1),2)
cr_bio = mean(rC.crop_biofuel(:,min(year_s)-min(year_f)+1:max(year_s)-min(year_f)+1),2) ...
    +mean(rC.incineration(:,min(year_s)-min(year_f)+1:max(year_s)-min(year_f)+1),2)
% crop biofuel + incineration 
fo_re = mean(rC.forest_residual(:,min(year_s)-min(year_f)+1:max(year_s)-min(year_f)+1),2)
fo_bio = mean(rC.forest_biofuel(:,min(year_s)-min(year_f)+1:max(year_s)-min(year_f)+1),2)
ct = mean(rC.crop_trade(:,min(year_s)-min(year_f)+1:max(year_s)-min(year_f)+1),2)
wt = mean(rC.wood_trade(:,min(year_s)-min(year_f)+1:max(year_s)-min(year_f)+1),2)
hwp = mean(rC.PIC_SWDS_stockchange(:,min(year_s)-min(year_f)+1:max(year_s)-min(year_f)+1),2)
lf = mean(rC.crop_landfill_stockchange(:,min(year_s)-min(year_f)+1:max(year_s)-min(year_f)+1),2)     
rem = mean(rC.river_emissions(:,min(year_s)-min(year_f)+1:max(year_s)-min(year_f)+1),2)
lem = mean(rC.lake_emissions(:,min(year_s)-min(year_f)+1:max(year_s)-min(year_f)+1),2)
ab = mean(rC.lake_river_burial (:,min(year_s)-min(year_f)+1:max(year_s)-min(year_f)+1),2)
aex = mean(rC.coastal_carbon_export(:,min(year_s)-min(year_f)+1:max(year_s)-min(year_f)+1),2)

total_lr = sum(lr,1) % CONUS total 
total_hr = sum(hr,1) % CONUS total 
total_cr_re = sum(cr_re,1) % CONUS total 
total_cr_bio = sum(cr_bio,1) % CONUS total 
total_fo_re = sum(fo_re,1) % CONUS total 
total_fo_bio = sum(fo_bio,1) % CONUS total 
total_ct = sum(ct,1) % CONUS total 
total_wt = sum(wt,1) % CONUS total 
total_hwp = sum(hwp,1) % CONUS total 
total_lf = sum(lf,1) % CONUS total 
total_rem = sum(rem,1) % CONUS total
total_lem = sum(lem,1) % CONUS total
total_ab = sum(ab,1) % CONUS total 
total_aex = sum(aex,1) % CONUS total 

% Respiration that happens in place in the TRENDY models actually happens
% elsewhere.  So I should subtract the total from the regions the crops are
% grown in and add it in the regions with respiration.

crop_harvest_period = mean(rC.crop_harvest(:,min(year_s)-min(year_f)+1:max(year_s)-min(year_f)+1),2);
% % Even though 2019-2020 need to be updated.

ch_percent = crop_harvest_period/sum(crop_harvest_period)*100;

forest_harvest_period = mean(rC.forest_harvest(:,min(year_s)-min(year_f)+1:max(year_s)-min(year_f)+1),2);
fo_percent = forest_harvest_period/sum(forest_harvest_period)*100;

%crop_forest = crop_harvest_period  + forest_harvest_period ;
%where_stuff_is_growing_percent = crop_forest /sum(crop_forest)*100;
% got GPP instead

hr_percent = hr/total_hr*100; % human respiration

%load regional_area.mat % area_percent
load frArea.mat fractionalArea
area_percent = fractionalArea*100; % don't use this anymore

load frWaterArea.mat water_percent 
load GPP_distribution.mat GPP_percentage 
GPP_percent = GPP_percentage;

% so to use TRENDY models to approximate what the atmosphere should see,
% TRENDY MODEL - tlr + lr

% ct has a regional distribution in rC.crop_trade: distributed by area, but
% this is not used.
% 10/16/2025 nlm

%hr (direct) ,lr (direct) ,cr_re,cr_bio (direct),fo_re,fo_bio (direct)
%cr_re: crop residual (taking from crop harvest and adding based on human respiration)
%fo_re: forest residual (taking from forest harvest and adding based on
%human respiration


nRegions = 7;
for r = 1:nRegions

    % the LT terms we add mostly have direct spatial distribution

    tlr(r,1) = total_lr * ch_percent(r)/100; %  LT terms, respiration removed from TRENDY
    thr(r,1) = total_hr * ch_percent(r)/100; %
    tcr_re(r,1) = total_cr_re * ch_percent(r)/100;
    tcr_bio(r,1) = total_cr_bio * ch_percent(r)/100;
    tfo_re(r,1) = total_fo_re * fo_percent(r)/100;
    tfo_bio(r,1) = total_fo_bio * fo_percent(r)/100;

    cr_re(r,1) = total_cr_re * hr_percent(r)/100;% crop residual (human distribution)
    fo_re(r,1) = total_fo_re * hr_percent(r)/100;% forest residual (human distribution)
    rem(r,1) = total_rem * water_percent(r)/100; % gets emitted (water distribution)
    lem(r,1) = total_lem * water_percent(r)/100; % gets emitted (water distribution)

    tct(r,1) =  total_ct * ch_percent(r)/100; % RM terms
    tlf(r,1) =  total_lf * ch_percent(r)/100; %
    twt(r,1) =  total_wt * fo_percent(r)/100; %
    thwp(r,1) = total_hwp * fo_percent(r)/100; %

    trem(r,1) = total_rem * GPP_percent(r)/100; % LT terms
    tlem(r,1) = total_lem * GPP_percent(r)/100; %

    tab(r,1) =  total_ab * GPP_percent(r)/100; % RM terms
    taex(r,1) = total_aex * GPP_percent(r)/100; %

end

thr=abs(thr);
tlr=abs(tlr);
tcr_re=abs(tcr_re);
tcr_bio=abs(tcr_bio);
tfo_re=abs(tfo_re);
tfo_bio=abs(tfo_bio);
hr=abs(hr);
lr=abs(lr);
cr_re=abs(cr_re);
cr_bio=abs(cr_bio);
fo_re=abs(fo_re);
fo_bio=abs(fo_bio);
tct=abs(tct);
tlf=abs(tlf);
twt=abs(twt);
thwp=abs(thwp);
trem=abs(trem);
tlem=abs(tlem);
tab=abs(tab);
taex=abs(taex);


 end % function

