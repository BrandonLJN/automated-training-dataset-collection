function [status] = LaserBankSet(tsp,ch_Offset,ch_map,val_rep)
ch_req = intersect(find(ch_Offset~=0),find(val_rep == 1));

status = 0;
for chh = 1:length(ch_req)
       try  
   res = tsp.offset_laser_power(ch_map(ch_req(chh)),ch_Offset(ch_req(chh)));
   status = 0;
   if res ~= 0
     status = 1;  
   end
      catch ME
     status = 1;       
       end     
end

if length(ch_req) > 0
    pause(8)
end
end


