    function res = offset_opwr(folderpath,board,Att,value)

    switch Att
        case 1
       be = NESend(folderpath,board.NE, [':cfg-get-attenuation:' board.Att1_BID,',',board.Att1_PID]);
       pause(0.5)
       NESend(folderpath,board.NE, [':cfg-set-attenuation:' board.Att1_BID,',',board.Att1_PID,',',num2str(10*(be-value))]);
       pause(0.5)
       af = NESend(folderpath,board.NE, [':cfg-get-attenuation:' board.Att1_BID,',',board.Att1_PID]);      
       case 2
       be = NESend(folderpath,board.NE, [':cfg-get-attenuation:' board.Att2_BID,',',board.Att2_PID]);
       pause(0.5)
       NESend(folderpath,board.NE, [':cfg-set-attenuation:' board.Att2_BID,',',board.Att2_PID,',',num2str(10*(be-value))]);
       pause(0.5)
       af = NESend(folderpath,board.NE, [':cfg-get-attenuation:' board.Att2_BID,',',board.Att2_PID]);          
    end
       
       
       if abs(af-be+value) <0.05
           res = 1;
       else
          res = 0; 
       end
    end