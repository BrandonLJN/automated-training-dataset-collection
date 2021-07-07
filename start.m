function start

    global logger_file;
    logger_file = sprintf('logs/%s.txt', datetime('now', 'Format','d-MMM-y_HHmmss'));
    
    % state variables
    states = Stack(3);
    states.Cv2Str = @decode_state;
    states.push(START);
   

    while true
        
        curr_state = states.pop();
        t0 = datetime('now');
        logger('progress', decode_state(curr_state));
       
        switch curr_state
            case START
                tsp = TSP1000('com11');
                
                case_name  = 'case_7ch_15';
                table_file = sprintf('data/tables/%s.csv', case_name);
                mon_file   = sprintf('data/monitors/%s.csv', case_name);
                table_tbl  = readtable(table_file);
                num_rows   = size(table_tbl,1);
                
                % define title names for tablization
                ch_title = arrayfun(@(x) ['ch',num2str(x)],   1:8,  'UniformOutput', false);
                pi_title = arrayfun(@(x) ['pin',num2str(x)],  1:14, 'UniformOutput', false);
                po_title = arrayfun(@(x) ['pout',num2str(x)], 1:14, 'UniformOutput', false);
                at_title = arrayfun(@(x) ['att',num2str(x)],  1:14, 'UniformOutput', false);
                
                if exist(mon_file, 'file')
                    logger('focus', '%s exists, now load it...', mon_file);
                    T_mon = readtable(mon_file);
                else
                    T_mon = table;
                end
                
                ch_map = [6 2 7 3 8 4 9 5];
                
                dso_sample_rate = 80e9;
                dso_samples_length = 1e6;

                idx_row  = 0;
                logger('focus', 'start at row#%d', idx_row);
                
                NEcheck       = 'Off';
                
                % reset counters
                reset_laser_counter = 0;
                reset_mat_instr_counter = 0;
                
                % helpful function
                arr2str = @(x) ['[', strjoin(strsplit(num2str(x)), ','), ']'];
                
                % change state
                states.push(NEXT_CONFIG_LINE);
                
            case NEXT_CONFIG_LINE
                % read next line
                idx_row = idx_row + 1;
                logger('info', 'line#%d: %s', idx_row, arr2str(table_tbl{idx_row,:}));

                % refresh reset counters
                reset_laser_counter = 0;
                reset_mat_instr_counter = 0;
                set_waveshape_counter = 0;
                
                % change state
                if mod(idx_row, 10) == 0
                    states.push(FIX_CHANNEL_POWER);
                else
                    states.push(SET_LASER_POWER);
                end
                
            case FIX_CHANNEL_POWER
                if reset_laser_counter > 0
                    [still_req] = LaserBankOffSet(tsp,ch_map,still_req);
                else
                    val_req = [];
                    try
                        [still_req] = try_times(8, 2.^(1:8), @LaserBankOffSet, tsp,ch_map,val_req);
                    catch ME
                        logger('error', ME.mesage);
                        states.push(FIX_CHANNEL_POWER).push(HALT);
                        continue;
                    end
                end
                
                failed_lasers = ch_map(find(abs(still_req)>0));
                
                % change state
                if max(abs(still_req)) > 0
                    states.push(FIX_CHANNEL_POWER).push(RESET_LASER);
                else
                    reset_laser_counter = 0;
                    states.push(SET_LASER_POWER);
                end
                W_check = try_times(3, [1,1,1], @loadcheck);
           
                if W_check 
                   logger('error','ADC Output is 0')
                   states.push(HALT); 
                end
            case SET_LASER_POWER
              
                if idx_row > 1
                    diff_ch_row = table_tbl{idx_row,ch_title} - table_tbl{idx_row-1,ch_title};
                else
                    diff_ch_row = table_tbl{idx_row,ch_title};
                    diff_ch_row(find(diff_ch_row==-99)) = 0;
                end
               
                if reset_laser_counter > 0
                [status] = LaserBankSet(tsp,diff_ch_row,ch_map,status);
                else
                [status] = LaserBankSet(tsp,diff_ch_row,ch_map,ones(size(diff_ch_row)));              
                end
                failed_lasers = ch_map(find(abs(diff_ch_row)>0));
                
                if max(abs(status)) > 0
                    
                    states.push(SET_LASER_POWER);
                    states.push(RESET_LASER);
                else
                    states.push(SET_NE);
                end                
                
            case SET_NE 
                opwr = [table_tbl{idx_row,'lp'}*ones(1,9) -99 -99 -99 5];    
                [status_read, status_Set, Out_error, B] = NE_Out(opwr,NEcheck);
                logger('info',['NEstatus: ' num2str([status_read status_Set])]);
                
                % check if all board are set as expected
                if max([status_read status_Set]) ~= 0
                    delete 'NE_ref.mat'
                    states.push(SET_NE);
                    states.push(HALT); 
                else
                    if strcmp(NEcheck,'On')
                     Out_error(abs(Out_error) < 0.05) = 0;
                     logger('info',['NEOutErr: ' arr2str(Out_error(:).')]);   
                    end
                    
                    try
                        % records monitored info    
                        T_mon(idx_row, [pi_title, po_title, at_title]) = num2cell([B.I, B.O, B.Att]);
                        writetable(T_mon, mon_file);
                        states.push(SET_RXCHANNEL);
                    catch ME
                        logger('error', err2str(ME));
                        states.push(SET_NE).push(HALT);
                    end
                end
                    
                % change state
                
            case SET_RXCHANNEL
                
                if idx_row > 1 && table_tbl{idx_row,'rx_ch'} ~= table_tbl{idx_row-1,'rx_ch'}
                    [status] = RecChSet(tsp,table_tbl{idx_row,'rx_ch'},10);
                    
                    % change state
                    if status == 1
                        if set_waveshape_counter > 5
                            logger('error', 'set waveshape failed many times, now halt');
                            states.push(SET_RXCHANNEL).push(HALT);    
                        else
                            set_waveshape_counter = set_waveshape_counter + 1;
                            pause(5);
                            states.push(SET_RXCHANNEL);
                            continue;
                        end
                    elseif status == 2
                        failed_lasers = ch_map(table_tbl{idx_row,'rx_ch'});
                        states.push(SET_RXCHANNEL).push(RESET_LASER);    
                    else
                        states.push(DSO_SAMPLING);
                        pause(5);
                    end
                else
                    logger('info', 'RX channel not changed');
                    states.push(DSO_SAMPLING);
                end
                
            case DSO_SAMPLING
                try
                    wav = try_times(3, [5,15,25], @superman, dso_sample_rate,dso_samples_length);
                    case_name = dir(table_file).name(1:end-4);
                    case_dir  = sprintf('data/wav/%s', case_name);
                    if ~exist(case_dir, 'dir'), mkdir(case_dir); end
                    save(sprintf('%s/%d.mat', case_dir, idx_row), 'wav');
                    states.push(DSP_DEMOD);
                catch ME
                    logger('warning',err2str(ME));
                    if reset_mat_instr_counter == 0
                        states.push(DSO_SAMPLING).push(RESET_MATLAB_INSTR);
                    else
                        states.push(DSO_SAMPLING).push(HALT);
                    end
                end
    
            case DSP_DEMOD
                % DSP is done in remote PC
                  
                % change state
                if idx_row == num_rows
                    states.push(FINISH);
                else
                    states.push(NEXT_CONFIG_LINE);
                end
                      
            case RESET_LASER
                try
                    % add your fix here
                    try_times(4, 2.^(2:4), @tsp.close_COM_port);
                    try_times(4, 2.^(2:4), @tsp.open_COM_port);
                    try_times(4, 2.^(2:4), @tsp.close_laser, failed_lasers);
                    try_times(4, 2.^(2:4), @tsp.open_laser, failed_lasers);
                    pause(3);
                catch ME
                    states.push(RESET_LASER);
                    logger('error', sprintf('%s', err2str(ME)));
                end
                
                reset_laser_counter = reset_laser_counter + 1;
                if reset_laser_counter > 4
                    states.push(HALT);   
                end
                
            case RESET_MAT_INSTR
                instrreset;
                pause(2);
                tsp = TSP1000('com11');
                
                reset_mat_instr_counter = reset_mat_instr_counter + 1;
    
            case HALT
                logger('warning', 'halt and enter debug mode');
                last_words = tail_log(logger_file, 30);
                send_email('BOOM!', [imghtmltag('HALT'), toHTML(last_words)]);
                keyboard;
                %To terminate debug mode and continue execution, use the dbcont command.
                %To terminate debug mode and exit the file without completing execution, 
                % use the dbquit command.
                
            case FINISH
                logger('ok', 'FINISH');
                send_email('DONE!', imghtmltag('FINISH'));
                break;
                
            otherwise
                error(['Invalid state code: ', char(curr_state)]);
        end
        
        t1 = datetime('now');
        logger('ok', 'done (%s)', t1-t0);
    end
end

% ------------------------------ states -----------------------------------
function s = START,             s = 0;  end
function s = NEXT_CONFIG_LINE,  s = 1;  end
function s = FIX_CHANNEL_POWER, s = 2;  end
function s = SET_LASER_POWER,   s = 3;  end
function s = SET_NE,            s = 4;  end
function s = SET_RXCHANNEL,     s = 5;  end
function s = DSO_SAMPLING,      s = 6;  end
function s = DSP_DEMOD,         s = 7;  end
function s = RESET_LASER,       s = 8;  end
function s = RESET_MAT_INSTR,   s = 9;  end
function s = FINISH,            s = 10; end
function s = IDLE,              s = 11; end
function s = HALT,              s = 12; end

function state = decode_state(s)
    switch(s)
        case START
            state = 'START';
        case NEXT_CONFIG_LINE
            state = 'NEXT_CONFIG_LINE';
        case FIX_CHANNEL_POWER
            state = 'FIX_CHANNEL_POWER';
        case SET_LASER_POWER
            state = 'SET_LASER_POWER';
        case SET_NE
            state = 'SET_NE';
        case SET_RXCHANNEL
            state = 'SET_RXCHANNEL';
        case DSO_SAMPLING
            state = 'DSO_SAMPLING';
        case RESET_LASER
            state = 'RESET_LASER';
        case RESET_MAT_INSTR
            state = 'RESET_MAT_INSTR';
        case FINISH
            state = 'FINISH';
        case HALT
            state = 'HALT';
        case IDLE
            state = 'IDLE';
        case DSP_DEMOD
            state = 'DSP_DEMOD';
        otherwise
            error(['Invalid state code: ', char(s)]);
    end
end