function wav = superman(Sample_Rate, Sample_Length)

scope_visa_addr= 'tcpip0::192.168.66.197::instr';
scpvisa = visa('agilent', scope_visa_addr);
scpvisa.InputBufferSize = Sample_Length*2 +1;

magical_time = 0.5;
magical_time2 = 0.1;

fopen(scpvisa);
try
%     fprintf(scpvisa,'*rst');
    fprintf(scpvisa,'*cls');
    %--------NON-DEFAULT----------
    fprintf(scpvisa,':acquire:points:analog %e',Sample_Length); % set the recording length or called memeory depth
    fprintf(scpvisa,':acquire:srate:analog %e',Sample_Rate);
    fprintf(scpvisa,':single');
    %--------NON-DEFAULT----------
    
    %--------Channel 1------------------------------
    fprintf(scpvisa,':WAVeform:FORMat WORD');
    fprintf(scpvisa,':WAVeform:BYTeorder LSBFirst');
    fprintf(scpvisa, ':WAVeform:SOURce CHANnel1');
    fprintf(scpvisa,':WAVeform:STReaming 1');
    pause(magical_time);
    fprintf(scpvisa,':WAVeform:YINCrement?');
    yinc = fscanf(scpvisa,'%f');
    fprintf(scpvisa,':WAVeform:YORigin?');
    yorig = fscanf(scpvisa,'%f');
    fprintf(scpvisa,':WAVeform:XINCrement?');
    xinc = fscanf(scpvisa,'%f');
    fprintf(scpvisa,':WAVeform:XORigin?');
    xorig = fscanf(scpvisa,'%f');
    pause(magical_time2);
    
    fprintf(scpvisa,':WAVeform:DATA?');
    cdata = fscanf(scpvisa,'%c',1);
    while (cdata ~='#')
        cdata = fscanf(scpvisa,'%c',1);
    end
    cdata = fscanf(scpvisa,'%c',1);
    while (cdata ~='0')
        cdata = fscanf(scpvisa,'%c',1);
    end
    
    % ydata = fread(scpvisa,1000,'int16');
    [data,count] = fread(scpvisa, Sample_Length*2+1);
    
    volt_d = zeros(floor(count/2), 1);
    
    for i=1:1:floor(count/2)
        %time_d(i) = i *xinc +xorig;
        tmp = data(2*i)*256 + data(2*i-1);
        if tmp>32767
            tmp = tmp-2^16;
        end
        volt_d(i) = tmp*yinc + yorig;
    end
    wav(:,1) = volt_d;
    
    %--------Channel 2------------------------------
    fprintf(scpvisa,':WAVeform:FORMat WORD');
    fprintf(scpvisa,':WAVeform:BYTeorder LSBFirst');
    fprintf(scpvisa, ':WAVeform:SOURce CHANnel2');
    fprintf(scpvisa,':WAVeform:STReaming 1');
    pause(magical_time);
    fprintf(scpvisa,':WAVeform:YINCrement?');
    yinc = fscanf(scpvisa,'%f');
    fprintf(scpvisa,':WAVeform:YORigin?');
    yorig = fscanf(scpvisa,'%f');
    fprintf(scpvisa,':WAVeform:XINCrement?');
    xinc = fscanf(scpvisa,'%f');
    fprintf(scpvisa,':WAVeform:XORigin?');
    xorig = fscanf(scpvisa,'%f');
    pause(magical_time2);
    
    fprintf(scpvisa,':WAVeform:DATA?');
    cdata = fscanf(scpvisa,'%c',1);
    while (cdata ~='#')
        cdata = fscanf(scpvisa,'%c',1);
    end
    cdata = fscanf(scpvisa,'%c',1);
    while (cdata ~='0')
        cdata = fscanf(scpvisa,'%c',1);
    end
    
    % ydata = fread(scpvisa,1000,'int16');
    [data,count] = fread(scpvisa, Sample_Length*2+1);
    
    volt_d = zeros(floor(count/2), 1);
    
    for i=1:1:floor(count/2)
        %time_d(i) = i *xinc +xorig;
        tmp = data(2*i)*256 + data(2*i-1);
        if tmp>32767
            tmp = tmp-2^16;
        end
        volt_d(i) = tmp*yinc + yorig;
    end
    wav(:,2) = volt_d;
    
    %--------Channel 3------------------------------
    fprintf(scpvisa,':WAVeform:FORMat WORD');
    fprintf(scpvisa,':WAVeform:BYTeorder LSBFirst');
    fprintf(scpvisa, ':WAVeform:SOURce CHANnel3');
    fprintf(scpvisa,':WAVeform:STReaming 1');
    pause(magical_time);
    fprintf(scpvisa,':WAVeform:YINCrement?');
    yinc = fscanf(scpvisa,'%f');
    fprintf(scpvisa,':WAVeform:YORigin?');
    yorig = fscanf(scpvisa,'%f');
    fprintf(scpvisa,':WAVeform:XINCrement?');
    xinc = fscanf(scpvisa,'%f');
    fprintf(scpvisa,':WAVeform:XORigin?');
    xorig = fscanf(scpvisa,'%f');
    pause(magical_time2);
    
    fprintf(scpvisa,':WAVeform:DATA?');
    cdata = fscanf(scpvisa,'%c',1);
    while (cdata ~='#')
        cdata = fscanf(scpvisa,'%c',1);
    end
    cdata = fscanf(scpvisa,'%c',1);
    while (cdata ~='0')
        cdata = fscanf(scpvisa,'%c',1);
    end
    
    % ydata = fread(scpvisa,1000,'int16');
    [data,count] = fread(scpvisa, Sample_Length*2+1);
    
    volt_d = zeros(floor(count/2), 1);
    
    for i=1:1:floor(count/2)
        %time_d(i) = i *xinc +xorig;
        tmp = data(2*i)*256 + data(2*i-1);
        if tmp>32767
            tmp = tmp-2^16;
        end
        volt_d(i) = tmp*yinc + yorig;
    end
    wav(:,3) = volt_d;
    
    %--------Channel 4------------------------------
    fprintf(scpvisa,':WAVeform:FORMat WORD');
    fprintf(scpvisa,':WAVeform:BYTeorder LSBFirst');
    fprintf(scpvisa, ':WAVeform:SOURce CHANnel4');
    fprintf(scpvisa,':WAVeform:STReaming 1');
    pause(magical_time);
    fprintf(scpvisa,':WAVeform:YINCrement?');
    yinc = fscanf(scpvisa,'%f');
    fprintf(scpvisa,':WAVeform:YORigin?');
    yorig = fscanf(scpvisa,'%f');
    fprintf(scpvisa,':WAVeform:XINCrement?');
    xinc = fscanf(scpvisa,'%f');
    fprintf(scpvisa,':WAVeform:XORigin?');
    xorig = fscanf(scpvisa,'%f');
    pause(magical_time2);
    
    fprintf(scpvisa,':WAVeform:DATA?');
    cdata = fscanf(scpvisa,'%c',1);
    while (cdata ~='#')
        cdata = fscanf(scpvisa,'%c',1);
    end
    cdata = fscanf(scpvisa,'%c',1);
    while (cdata ~='0')
        cdata = fscanf(scpvisa,'%c',1);
    end
    
    % ydata = fread(scpvisa,1000,'int16');
    [data,count] = fread(scpvisa, Sample_Length*2+1);
    
    volt_d = zeros(floor(count/2), 1);
    
    for i=1:1:floor(count/2)
        %time_d(i) = i *xinc +xorig;
        tmp = data(2*i)*256 + data(2*i-1);
        if tmp>32767
            tmp = tmp-2^16;
        end
        volt_d(i) = tmp*yinc + yorig;
    end
    wav(:,4) = volt_d;
catch ME
    fclose(scpvisa);
    rethrow(ME);
end
% fprintf(scpvisa,':run');

fclose(scpvisa);
delete(scpvisa);
clear scpvisa;
% instrreset;

for i = 1:size(wav, 2)
    if all(abs(wav(:,i)) < 1e-12)
        error(sprintf('SUPERMAN: column %d is all zeros', i));
    end
end