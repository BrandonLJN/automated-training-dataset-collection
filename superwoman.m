function superwoman(scpvisa)
% save superman

if nargin == 0
    scope_visa_addr= 'tcpip0::192.168.66.197::instr';
    scpvisa = visa('agilent', scope_visa_addr);
    fopen(scpvisa);
end

try
    fprintf(scpvisa, ':SYSTem:PRESet DEFault');
    pause(1);
    fprintf(scpvisa, ':CHANnel1:DISPlay ON');
    fprintf(scpvisa, ':CHANnel2:DISPlay ON');
    fprintf(scpvisa, ':CHANnel3:DISPlay ON');
    fprintf(scpvisa, ':CHANnel4:DISPlay ON');
    pause(.5);
    fprintf(scpvisa, ':CHANnel1:SCALe 20e-3');
    fprintf(scpvisa, ':CHANnel2:SCALe 20e-3');
    fprintf(scpvisa, ':CHANnel3:SCALe 20e-3');
    fprintf(scpvisa, ':CHANnel4:SCALe 20e-3');
catch ME
    if nargin == 0, fclose(scpvisa); end
    rethrow(ME);
end

if nargin == 0
    fclose(scpvisa);
end

pause(10);

