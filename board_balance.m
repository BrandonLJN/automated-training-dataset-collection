    function [status,ref_out,opwr_out,B] = board_balance(folderpath,board,opwr,ref_in)
B = {};
   ref_out = [];opwr_out=[];status = [];
for i = 1:length(board)
    try_num = 0;while_status = 1;status_tem = 0;
while try_num < 3 && while_status == 1
    %% ----------------------- read power -----------------
try
    try_num = try_num + 1;
    status_tem = 0;while_status = 0;   
    Info_be  = NESend(folderpath, board{i}.NE, [':per-get-curdata-byboard:15m,',board{i}.Gain_BID]);    
    if opwr(i) > -90
    Att_     = Info_be.outpow-opwr(i);  % calculate required Att for each board   
    else
    Att_ = ref_in(i);
    end
    B.I(i)   = Info_be.inpow;
    B.O(i)   = Info_be.outpow;
   %% ----------------------- set power -----------------
if Att_ < -0.05
    error([num2str(i),' opwr is out of range']) 
end
if abs(Att_ - ref_in(i)) > 0.1 % Skip if aimed Att is very close to present Att
    pause(0.1) 
    NESend(folderpath, board{i}.NE, [':cfg-set-attenuation:',board{i}.Att2_BID,',',board{i}.Att2_PID,',',num2str(10*Att_)]);       
    pt = max(abs(Att_ - ref_in(i)) *1.9,1.5);
    pause(pt);    
else
Att_ =  ref_in(i);  
end
    ref_out  = [ref_out;Att_];
    opwr_out = [opwr_out;Info_be.outpow-Att_];
      catch
    pause(3)
    while_status = 1;
    status_tem = 1;
end  

pause(0.3)
end

status = [status status_tem];
end
B.Att = ref_out.';
end

    
%     i=1
%     i=2
%     i=3
%     i=4
%     i=5
%     i=6