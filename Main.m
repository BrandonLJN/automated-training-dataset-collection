clear
clc
close all

addpath(genpath('C:\Users\EF503A\Desktop\XT'))
folderpath = 'Z:/'; 
topo = [...
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

LP = 5;
opwr = [9 9 9 9 9 9 9 9 9 9 9 9 5];   
  
   opwr_monitor=[];

tic
[~,ref] = board_opwer(folderpath,board);
toc
tic
for i = 1
    [ref,opwr_es] = board_balance(folderpath,board,opwr,ref);
end
toc


[Opwr_now,Att_now] = board_opwer(folderpath,board);
err = Opwr_now -opwr.'
% pause(2)
% [opwr_es,~] = board_opwer(folderpath,board)

% 
% opwr_monitor = [opwr_monitor;opwr_es-1];
% wav = superman(80e9, 800e3);
% for re = 1:3
% save(['C:\Users\EF503A\Desktop\XT\data2\','LP_',num2str(11+p-1),'_S1_',num2str(k+1),'_',num2str(re),'.mat'],'wav','opwr_es')
% end
% 
% 
%  opwr_monitor=[];
% for p = [0:-1:-10]
% for k =0:9
% opwr = [circshift([11,8,14,11,11,11,11,11,11,11,11,11],k)+p,3.5];
% 
% tic
% [~,ref] = board_opwer(folderpath,board);
% for i = 1:2
%     [ref,opwr_es] = board_balance(folderpath,board,opwr,ref);
% end
% toc
% % pause(2)
% % [opwr_es,~] = board_opwer(folderpath,board)
% 
% 
% opwr_monitor = [opwr_monitor;opwr_es-1];
% wav = superman(80e9, 800e3);
% for re = 1:3
% save(['C:\Users\EF503A\Desktop\XT\data2\','LP_',num2str(11+p-1),'_S2_',num2str(k+1),'_',num2str(re),'.mat'],'wav','opwr_es')
% end
% end
% end
% 
%    opwr_monitor=[];
% for p = [0:-1:-10]
% for k =0:9
% opwr = [circshift([11,11,11,11,11,11,11,11,11,11,11,11],k)+p,3.5];
% 
% tic
% [~,ref] = board_opwer(folderpath,board);
% for i = 1:2
%     [ref,opwr_es] = board_balance(folderpath,board,opwr,ref);
% end
% toc
% % pause(2)
% % [opwr_es,~] = board_opwer(folderpath,board)
% 
% 
% opwr_monitor = [opwr_monitor;opwr_es-1];
% wav = superman(80e9, 800e3);
% for re = 1:3
% save(['C:\Users\EF503A\Desktop\XT\data2\','LP_',num2str(11+p-1),'_S0_',num2str(k+1),'_',num2str(re),'.mat'],'wav','opwr_es')
% end
% end
% end
% 
% 
%  