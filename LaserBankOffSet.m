function [still_req] = LaserBankOffSet(tsp,ch_map,val_req)
% chd_rep: channel required offset
% status: offset result, 0 is success and 1 is fail.

persistent last_modtime;

if isempty(val_req) &&  exist('ChPowerDrift.mat', 'file')
    cpd_file = dir('ChPowerDrift.mat');

    if isempty(last_modtime) || datetime(cpd_file.date) ~= last_modtime
        last_modtime = datetime(cpd_file.date);
    else
        error('ChPowerDrift.mat not updated');
    end

    load('ChPowerDrift.mat');
    val_req = ID_mean_req;    
end

ch_rep = find(val_req~=0);
for chh = 1:length(ch_rep)

    try  
     res  = tsp.offset_laser_power(ch_map(ch_rep(chh)),-val_req(ch_rep(chh)) );
     status_ch = 0;
     if res ~= 0
     status_ch = 1;
     end
    catch ME
        status_ch = 1;
    end
if status_ch == 0
val_req(ch_rep(chh)) = 0;    
end 
end
 still_req =  val_req; 
end



