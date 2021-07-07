function [status_read,status_Set,Err,B] = NE_Out(opwr,feedback)
% opwr should be 1*13 size
% feedback should be 'On' or 'Off'. If 'On', Err = real EDFA output -
% desired output (dB). If 'Off', Err is empty.
B = {};
folderpath = 'Z:/'; 
topo = [...
        9103, 1, 9103, 1, 9109, 1;        
        9108, 1, 9108, 1, 9109, 1;
        9107, 1, 9107, 1, 9109, 2;
        9115, 2, 9115, 2, 9109, 3;
        9301, 1, 9308, 1, 9305, 2;
        9303, 1, 9303, 1, 9305, 3;
        9306, 1, 9306, 1, 9305, 4;
        9315, 2, 9315, 2, 9317, 1;
        9313, 2, 9313, 2, 9317, 2;
        9310, 2, 9310, 2, 9317, 3;
        9113, 1, 9113, 1, 9111, 1;
        9106, 2, 9106, 2, 9111, 2;
        9102, 2, 9102, 2, 9111, 3;
  9104, 1, 9104, 1, 9104, 4;
];% 1 = '12OBU', 2 = '12OAU'       9104, 1, 9104, 1, 9104, 4;
    
topo_str = sprintfc('%g',topo);  
EDFA_num = size(topo_str,1); 
board = {};
  for i = 1:EDFA_num
    board{i,1}.NE  = str2num(topo_str{i,1}(1:2));
    board{i,1}.Att1_BID = num2str(str2num(topo_str{i,1}(3:4)));
    board{i,1}.Gain_BID = num2str(str2num(topo_str{i,3}(3:4)));
    board{i,1}.Att2_BID = num2str(str2num(topo_str{i,5}(3:4)));
    
    if strcmp(topo_str{i,2},'1')
    board{i,1}.Att1_type  = '12OBU';    
    board{i,1}.Att1_PID = '4,1';
    elseif strcmp(topo_str{i,2},'2')
    board{i,1}.Att1_type = '12OAU';   
    board{i,1}.Att1_PID = '7,1';
    end
    if strcmp(topo_str{i,4},'1')
    board{i,1}.Gain_type  = '12OBU';    
    board{i,1}.Gain_PID = '4,1';
    elseif strcmp(topo_str{i,4},'2')
    board{i,1}.Gain_type = '12OAU';   
    board{i,1}.Gain_PID = '7,1';
    end
    board{i,1}.Att2_type = '12VA4'; 
    board{i,1}.Att2_PID = [num2str(topo_str{i,6}),',1'];
  end

  %% ---------------- get ref --------------
if exist('NE_ref.mat','file') == 2
load('NE_ref.mat');status_read = 0;
else
[status_read,~,NE_ref] = board_opwer(folderpath,board);
end
%% --------------- get info for first LP EDFA ---------------
if status_read == 0
[status_Set,NE_ref,opwr_es,B] = board_balance(folderpath,board,[-99 opwr],NE_ref);
 save('NE_ref.mat','NE_ref')
Err = []; 
if strcmp(feedback,'On')
    pause(2.5)
    try
[~,Opwr_now,Att_now] = board_opwer(folderpath,board);
Err = Opwr_now - [-99;opwr.'];
    catch ME
    end
end
else
   status_Set = ones(size(opwr)) ;
end

if max([status_read status_Set]) ~=0
   delete('NE_ref.mat','NE_ref')
end
end
