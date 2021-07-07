function wav = get_wav

samples_length    = 300e3;
scope_sample_rate = 80e9;

trails_num = 2;
trail_idx  = 1;
is_saved   = false;
while 1
    sth_wrong = false;
    
    wav = superman(scope_sample_rate,samples_length);
    
    for i = 1:size(wav, 2)
        if all(abs(wav(:,i)) < 1e-12)
            sth_wrong = true;
            warning(sprintf('SUPERMAN: column %d is all zeros', i));
        end
    end
    
    if sth_wrong
        if is_saved
        	error('superman + superwoman failed');
        else
           if trail_idx <= trails_num
                warning('try again');
                trail_idx = trail_idx + 1;
                continue;
           else
                fprintf('another trial failed, here comes superwoman\n')
                superwoman(scpvisa);
                pause(3);
                is_saved = true;
                continue;
           end
        end
    else
        if is_saved
            fprintf('supermain + superwoman is working\n');
        else
            fprintf('supermain is working\n');
        end
        
        break;
    end
end
