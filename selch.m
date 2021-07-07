function selch(ch)
% select channel in Waveshaper

self_dir = fileparts(mfilename('fullpath'));

wsp_file = sprintf('ch%d.wsp', ch);
fprintf('select channel #%d\n', ch);
cmd = sprintf('python selch.py wsp/%s', wsp_file);
    
prepwd = pwd;

cd(self_dir);

try_times = 2;
try_num   = 1;

while 1
    try
        [status,result] = system(cmd);
        
        if contains(result, 'failed') || status == 1
            error(result);
        end
            
    catch ME  
        if try_num < try_times
            try_num = try_num + 1;
            pause(5);
            continue;
        end
        
        cd('..');
        rethrow(ME);
    end
    
    break;
end

cd(prepwd);
