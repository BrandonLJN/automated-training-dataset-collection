% clear
% clc
close all

ch_num = 7;
win1   = 25;
options = weboptions('Timeout', 30);

osa_addr = 'http://192.168.66.121:5000/samples';
%% ---------------- get ref1 ------------
W1_ = webread(osa_addr, 'frame_size', 3000, options);
W1 = W1_.samples;
% plot(W1)
W1(1:80) = 0;
cs = 25;
cut = floor((1000+2*cs)/8);
for i=1:length(W1)-(1000-cut*(8-ch_num))
     m(i)=sum(W1(i:i+(1000-cut*(8-ch_num))));
end
[b,c]=max(m);

% Wc1 = W(c-cs:c+1000+cs);
Wc1 = [zeros(cs,1);W1(c:c+1000);zeros(cs,1)];
Wc1 = fix_adc_jitter(Wc1);

%% ----------------------------------------
I_ref1=zeros(ch_num,1);
figure;hold on
for i= 1:ch_num    
    [b2,c2] = max(Wc1(1+(i-1)*cut:i*cut));
    c2 = c2 + (i-1)*cut;
    Wc1s = Wc1(c2-round(cut/2)+win1:c2+round(cut/2)-win1);
    Wc1s(Wc1s<0.06) = 0;
    plot(Wc1s)
    I_ref1(i)=sum(Wc1s);
end
% IRR = [IRR 10*log10(I_ref1)]

figure;hold on
plot(Wc1);hold on
%% ---------------- get ref2 ------------
W2_ = webread(osa_addr, 'frame_size', 3000, options);
W2 = W2_.samples;
W2(1:80) = 0;
cs = 25;
cut = floor((1000+2*cs)/8);
for i=1:length(W2)-(1000-cut*(8-ch_num))
     m(i)=sum(W2(i:i+(1000-cut*(8-ch_num))));
end
[b,c]=max(m);

% Wc2 = W(c-cs:c+1000+cs);
Wc2 = [zeros(cs,1);W2(c:c+1000);zeros(cs,1)];
Wc2 = fix_adc_jitter(Wc2);

%% -----------------------------------------
I_ref2=zeros(ch_num,1);
for i= 1:ch_num    
    [b2,c2] = max(Wc2(1+(i-1)*cut:i*cut));
    c2 = c2 + (i-1)*cut;
    Wc2s = Wc2(c2-round(cut/2)+win1:c2+round(cut/2)-win1);
    Wc2s(Wc2s<0.06) = 0;
    I_ref2(i)=sum(Wc2s);
end

plot(Wc2);hold on

RR = 10^(2/10);
P0 = (RR*I_ref2(end) - I_ref1(end))/(1-RR)

I_ref1_mod = I_ref1+P0;
I_ref2_mod = I_ref2+P0;
10*log10(I_ref1_mod)
10*log10(I_ref2_mod)

save('ref_OSAMon.mat','I_ref1_mod','I_ref2_mod','P0')
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
%% ----------------------------- monitoring ------------------------------
osa_addr = 'http://192.168.66.121:5000/samples';
ch_num = 7;
win1 = 25;
options = weboptions('Timeout', 30);
load('ref_OSAMon.mat')
% I_ref1_mod = ones(size(I_ref1_mod))*mean(I_ref1_mod);
% I_ref2_mod = ones(size(I_ref2_mod))*mean(I_ref2_mod);
I_ref2_mod = 10.^((10*log10(I_ref1_mod)-2)/10);
10*log10(I_ref1_mod)
10*log10(I_ref2_mod)
ch_map = [6;2;7;3;8;4;9;5];
for kt = 1:1:1e9
ID_mean_record = zeros(size(ch_map(1:ch_num)));
% try_num_record2 = [];
for k0 = 1:2


IR= [];IR_mod = [];
ID = [];ID1 = [];ID2 = [];
% figure;hold on
for ii = 1:5
try_num = 0;error_status = 1;    
 while try_num < 10 &&  error_status == 1
    error_status = 0;
    try_num = try_num + 1;
  try
      
W_ = webread(osa_addr, 'frame_size', 3000, options);
pause(8)
W = W_.samples;
W_check = 0;
if max(W) < 0.2
    W_check = 1;      
end
save('W_check.mat','W_check');
W(1:80) = 0;
cs = 25;
cut = floor((1000+2*cs)/8);
for i=1:length(W)-(1000-cut*(8-ch_num))
     m(i)=sum(W(i:i+(1000-cut*(8-ch_num))));
end

[b,c]=max(m);
Wc = [zeros(cs,1);W(c:c+1000);zeros(cs,1)];
Wc = fix_adc_jitter(Wc);

% plot(Wc);hold on

%% -----------------------------------------
I=zeros(ch_num,1);
for i= 1:ch_num    
    [b2,c2] = max(Wc(1+(i-1)*cut:i*cut));
    c2 = c2 + (i-1)*cut;
    Wcs = Wc(c2-round(cut/2)+win1:c2+round(cut/2)-win1);
    Wcs(Wcs<0.06) = 0;
    I(i)=sum(Wcs);
%     I(i)=Wc(c2);
%     plot([c2,c2],[0,max(Wc)]);hold on
% plot(Wcs);hold on
end

IR     = [IR I];
I_mod = I + P0;
IR_mod = [IR_mod I_mod];
%% --------------- Dec -------------------------------------------------
ID_1_dB    = 10*(log10(I_mod)-log10(I_ref1_mod));
ID_2_dB    = 10*(log10(I_mod)-log10(I_ref2_mod));
ID_all_dB  = [ID_1_dB ID_2_dB];
ID_abs_1   = abs(I_mod-I_ref1_mod);
ID_abs_2   = abs(I_mod-I_ref2_mod);
ID_abs_all = [ID_abs_1 ID_abs_2];
[~,l_dec]  = min(ID_abs_all,[],2);% status decision

ID_dec = [];
for k  = 1:ch_num
   ID_dec(k,1) = ID_all_dB(k,l_dec(k)) ;
end
ID     = [ID ID_dec];
  catch ME
error_status = 1; 
if try_num > 4     
W_check = 1;      
save('W_check.mat','W_check');
throw(ME);
end
  end    
 end
end
% try_num_record2 = [try_num_record2;try_num_record];
%% ------------- get power error -----------------------------------------------
ID_abs = abs(ID);
ID_mean = [];
for j = 1:ch_num
ID_sub = ID(j,:);  
%% ----------- filter out 2 max and 2 min -------------------------------
for j2 = 1:2
[~,lc] = max(ID_sub); 
ID_sub(lc) = [];
[~,lc] = min(ID_sub); 
ID_sub(lc) = [];
end
% ---------------- mean the power error ---------------------------------------
ID_mean = [ID_mean;mean(ID_sub)];
end

ID_mean2 = ID_mean;
ID_mean2(abs(ID_mean2)<0.05) = -inf;
ID_mean_record = [ID_mean_record ID_mean2];
% ch_req     = find(abs(ID_mean_record(:,k0+1))>0.15);
% ch_req_pre = find(abs(ID_mean_record(:,k0))>0.15);
% ch_rep_confirm = intersect(ch_req,ch_req_pre);

% if isempty(ch_rep_confirm) == 0
%     for chh = 1:length(ch_rep_confirm)
% tsp.offset_laser_power(ch_map(ch_rep_confirm(chh)), -ID_mean2(ch_rep_confirm(chh)));
%     end
% end

% save('ID_mean_record.mat','ID_mean_record')
% save('try_num_record2.mat','try_num_record2')
k0
end
comp = zeros(8,1);
ID_mean_req = mean(ID_mean_record,2);
ID_mean_req(ID_mean_req<-100) = 0;  
ID_mean_req = [ID_mean_req;comp(1:8-ch_num)];
save('ChPowerDrift.mat','ID_mean_req')
end

