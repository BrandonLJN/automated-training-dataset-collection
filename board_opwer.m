    function [status,opwr,Att] = board_opwer(folderpath,board)
    opwr = [];Att=[];status = 0;
    for i = 1:length(board)
        try_num = 0;while_status = 1;
   while try_num <4 && while_status == 1
   try
    try_num = try_num + 1;
    status_tem = 0;while_status = 0;
    Infor    = NESend(folderpath, board{i}.NE, [':per-get-curdata-byboard:15m,',board{i}.Gain_BID]);
    pause(0.8)
    Att_     =  NESend(folderpath, board{i}.NE, [':cfg-get-attenuation:',board{i}.Att2_BID,',',board{i}.Att2_PID]);   
    pause(0.8) 
    opwr     = [opwr;Infor.outpow - Att_];
    Att      = [Att;Att_];
   catch
    while_status = 1;
    status = 1;    
    end

    end
    end