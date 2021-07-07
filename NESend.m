function res = NESend(navsrcch_dir, NE, cmd)
% res = NESend(NE, cmd)
% example:
%   res = NESend('Y:/', 91, ':cfg-set-gain:4,1,1,200')

    cmd_head = validate_cmd(cmd);

    NE = num2str(NE);

    if ~ismember(NE, {'91', '93'})
        error('NE must be a member of [91, 93]');
    end

    write_to  = fullfile(navsrcch_dir, NE, 'to_nav.txt');
    read_from = fullfile(navsrcch_dir, NE, 'from_nav.txt');
    stat_file = fullfile(navsrcch_dir, NE, 'stat.txt');

    while ~exist(stat_file, 'file')
        pause(1);
    end

    stat1 = read_stat(stat_file);
    write_data(write_to, cmd);
    update_stat(stat_file, mod(stat1+1,2));

    while read_stat(stat_file) ~= stat1
        pause(.1);
    end

    res = read_res(read_from);

    % check if login
    if ~isempty(res) && strcmp(res{1}, 'Notlogin')
        err_msg = sprintf('NE%s: Not login', NE);
        error(err_msg);
    end

    if ~isempty(res) && contains(res{1}, 'invalid command')
        err_msg = sprintf('NE%s: %s', res{1});
        error(err_msg);
    end
    
    % parse results
    switch cmd_head
        case ':per-get-curdata-byboard:'
            res_type = 'long';
        case {':cfg-get-attenuation:', ':cfg-get-gain:', ':cfg-get-stdgain:'}
            res_type = 'short';
        otherwise
            res_type = 'NA';
    end

    res = parse_res(res_type, res);
end

function cmd_head = validate_cmd(cmd)
    % arguments validation
    valid_cmd = {
        ':per-get-curdata-byboard:', ...
        ':cfg-get-attenuation:', ...
        ':cfg-get-gain:', ...
        ':cfg-get-stdgain:', ...
        ':cfg-set-attenuation:', ...
        ':cfg-set-gain:' ...
    };

    cmd_head = regexp(cmd, ':.*:', 'match');
    
    if isempty(cmd_head) || numel(cmd_head) > 1
        error('invalid command format');
    else
        cmd_head = cmd_head{1};
    end

    if ~ismember(cmd_head, valid_cmd)
        error('cmd not supported');
    end 
end

function update_stat(stat_file, stat)
    fid = fopen(stat_file, 'w');
    fprintf(fid, '%d', stat);
    fclose(fid);
end

function stat = read_stat(stat_file)
    fid = fopen(stat_file, 'r');
    stat = str2num(fgetl(fid));
    if stat ~= 0 && stat ~= 1
        error('invalid status code');
    end
    fclose(fid);
end

function write_data(file, data)
    fileID = fopen(file, 'w');
    fprintf(fileID, '%s', data);
    fclose(fileID);
end

function lines = read_res(file)
    fid = fopen(file, 'r');
    lines = {};
    while ~feof(fid)
        line = fgetl(fid);
        if ~isempty(line)
            lines{end+1} = line;
        end
    end
    fclose(fid);
end

function [data, data_table] = parse_res(type, data_str)
    ignored_term = {'PORT', 'PATH', 'Period', 'StartTime', 'ObjType', 'ParaLen', 'Para'};
    delimiter    = '\s+(?!(?:(?:([01]?\d|2[0-3]):)?([0-5]?\d):)?([0-5]?\d))';
    
    switch type
        case 'short'
            title_str = strtrim(data_str{2});
            value_str = strtrim(data_str{3});
            
            titles = strsplit(title_str);
            values = str2double(strsplit(value_str));
            
            values(4) = values(4) / 10;
            
            data_table = array2table(values, 'VariableNames', titles);
            data       = values(4);
        case 'long'
            title_str = strtrim(data_str{2});
            value_str  = cellfun(@strtrim, data_str(3:end-1), 'UniformOutput', false);
            
            titles = strsplit(title_str);
            for i = 1:numel(value_str)
                values(i, :) = strsplit(value_str{i}, delimiter, 'DelimiterType', 'RegularExpression');
                values{i, 4} = num2str(str2double(values{i, 4}) / 10);
            end
            
            data_table = array2table(values, 'VariableNames', titles);
            
            F = data_table(data_table{:, 'Eid'} == string('sumoopcur'), :);
            data.outpow  = str2double(F{end, 'Value'});
            F = data_table(data_table{:, 'Eid'} == string('sumiopcur'), :);
            data.inpow   = str2double(F{1, 'Value'});
            F = data_table(data_table{:, 'Eid'} == string('edtmpcur'), :);
            data.envtemp = str2double(F{end, 'Value'});
            F = data_table(data_table{:, 'Eid'} == string('xcstmpcur'), :);
            data.bdtemp  = str2double(F{end, 'Value'});
        otherwise
            data_table = table;
            data       = [];
            return;
    end
    
    data_table = removevars(data_table, ignored_term);
end

function T_new = removevars(T_old, removed_vars)
    % no need for Maltab >= 2018a
    
    T_new = table;
    all_vars  = T_old.Properties.VariableNames;
    
    for i = 1:numel(all_vars)
        if ~ismember(all_vars{i}, removed_vars)
            T_new = [T_new, T_old(:, all_vars{i})];
        end
    end
end

