classdef TSP1000 < handle
% TSP1000 Matlab driver
% Coded by Remi
% Examples:
%   tsp = TSP1000('com1');

    properties
       COM_port
       verbose
    end

    methods
        function obj = TSP1000(COM_port, varargin)
            p = inputParser;
            p.addParameter('BaudRate', 9600);
            p.addParameter('DataBits', 8);
            p.addParameter('StopBits', 1);
            p.addParameter('Parity', 'none');
            p.addParameter('FlowControl', 'none');
            p.addParameter('Verbose', true);
            p.parse(varargin{:});
     
            obj.COM_port = serial(...
                COM_port, ...
                'BaudRate',    p.Results.BaudRate, ...
                'DataBits',    p.Results.DataBits, ...
                'StopBits',    p.Results.StopBits, ...
                'Parity',      p.Results.Parity, ...
                'FlowControl', p.Results.FlowControl ...
            );
            
            obj.verbose  = p.Results.Verbose;
        end

        function delete(obj)
            if ~isequal(obj.COM_port.status, 'closed')
                obj.close_COM_port;
            end
        end

        function open_COM_port(obj)
            obj.COM_port_opt('open');
        end

        function close_COM_port(obj)
            obj.COM_port_opt('close');
        end

        function status = open_laser(obj, ch)
            for i = 1:numel(ch)
                res = obj.opt_decorator(@open_laser_impl, ch(i));

                switch res
                case 0
                    obj.dbg_log('ch#%d -> ON: Failed', ch(i));
                    status(i) = 1;
                case 1
                    obj.dbg_log('ch#%d -> ON: Done', ch(i));
                    status(i) = 0;
                case 2
                    obj.dbg_log('ch#%d is already ON', ch(i));
                    status(i) = 0;
                otherwise
                    error('unrecoganized response');
                end
                             
                pause(.5);
            end
        end

        function status = close_laser(obj, ch)
            for i = 1:numel(ch)
                res = obj.opt_decorator(@close_laser_impl, ch(i));

                switch res
                case 0
                    obj.dbg_log('ch#%d -> OFF: Done', ch(i));
                    status(i) = 0;
                case 1
                    obj.dbg_log('ch#%d -> OFF: Failed', ch(i));
                    status(i) = 1;
                case 2
                    obj.dbg_log('ch#%d is already OFF', ch(i));
                    status(i) = 0;
                otherwise
                    error('unrecoganized response');
                end
                  
                pause(.5);
            end
        end

        function status = set_laser_power(obj, ch, pow)
            for i = 1:numel(ch)
                res = obj.opt_decorator(@set_laser_power_impl, ch(i), pow);

                switch res
                case 0
                    obj.dbg_log('pow@ch#%d -> %.2f dBm: Failed (Register mismatched)', ch(i), pow);
                    status(i) = 1;
                case 1
                    obj.dbg_log('pow@ch#%d -> %.2f dBm: Done', ch(i), pow);
                    status(i) = 0;
                case 2
                    obj.dbg_log('pow@ch#%d -> %.2f dBm: Done (out of range)', ch(i), pow);
                    status(i) = 2;
                otherwise
                    error('unrecoganized response');
                end
                
                pause(.5);
            end
        end
        
        function status = set_laser_wavelength(obj, ch, wavlen)
        % res=0 -> done, res=1 -> reg mismatched is mentioned in the associated manual,
        % which seems not correct in reality
            for i = 1:numel(ch)
                res = obj.opt_decorator(@set_laser_wavelength_impl, ch(i), wavlen);

                switch res
                case 1
                    obj.dbg_log('wavlen@ch#%d -> %.3f nm: Done', ch(i), wavlen);
                    status(i) = 0;
                case 0
                    obj.dbg_log('wavlen@ch#%d -> %.3f nm: Failed (Register mismatched)', ch(i), wavlen);
                    status(i) = 1;
                case 2
                    obj.dbg_log('wavlen@ch#%d -> %.3f nm: Done (out of range)', ch(i), wavlen);
                    status(i) = 2;
                case 3
                    obj.dbg_log('wavlen@ch#%d -> %.3f nm: cannot set wavelength when channel is ON', ch(i), wavlen);
                    status(i) = 3;
                otherwise
                    error('unrecoganized response');
                end
                
                pause(.5);
            end
        end        
        
        function laser = get_laser_status(obj)
            laser = obj.opt_decorator(@get_laser_status_impl);
            
            pause(.5);
        end
        
        function status = offset_laser_power(obj, ch, offset_pow)
            laser = obj.get_laser_status();
            
            for i = 1:numel(ch)
                status(i) = obj.set_laser_power(ch(i), laser(ch(i)).power + offset_pow);
            end
        end
    end

    methods ( Access = protected )
        function varargout = opt_decorator(obj, fn, varargin)
            obj.open_COM_port;
            
            try
                time1 = datetime;
                [varargout{1:nargout}] = fn(obj, varargin{:});
                time2 = datetime;
                obj.dbg_log('operation finished in %s', time2-time1);
            catch ME
                rethrow(ME);
            end
        end

        function COM_port_opt(obj, opt)
            switch opt
                case 'open'
                    opt = @fopen;
                case 'close'
                    opt = @fclose;
                otherwise
                    error('invalid port operation')
            end

            stat1 = obj.COM_port.status;
            try
                opt(obj.COM_port);
            catch ME
                if contains(ME.message, 'OBJ has already been opened')
                    ...
                else
                    rethrow(ME);
                end
            end
            stat2 = obj.COM_port.status;

            obj.dbg_log('port status: %s - %s', stat1, stat2);
        end

        function dbg_log(obj, varargin)
            if obj.verbose
                if exist('logger', 'file')
                    varargin{1} = ['TSP1000: ', varargin{1}];
                    logger('info', varargin{:});
                else
                    fprintf('[TSP1000]: ');
                    fprintf(varargin{:});
                    fprintf('\n');
                end
            end
        end

        %function log(obj, varargin)
        %    fprintf('[TSP1000]: ');
        %    fprintf(varargin{:});
        %    fprintf('\n');
        %end

        function parity_field = get_parity_field(obj, ctrl_field, datlen_field, data_field)
            sum_hex = obj.hex_sum(ctrl_field, datlen_field, data_field);
            sum_dec = hex2dec(sum_hex);
            sum_dec = 255 - mod(sum_dec, 256);
            parity_field = dec2hex(sum_dec, 2);
        end

        function sum_hex = hex_sum(obj, varargin)
            operands_hex = [];
            for i = 1:nargin-1
                operands_hex = [operands_hex; varargin{i}];
            end

            operands_dec = hex2dec(operands_hex);
            sum_dec = sum(operands_dec);
            sum_hex = dec2hex(sum_dec);
        end

        function res = open_laser_impl(obj, ch)
            start_field = '68';
            ctrl_field = '01';
            datlen_field = ['00'; '09'];
            data_field = [dec2hex(ch, 2); repmat('00', 8, 1)];
            parity_field = obj.get_parity_field(ctrl_field, datlen_field, data_field);
            end_field = '16';

            cmd_tx_hex = [start_field; ctrl_field; datlen_field; data_field; parity_field; end_field];
            cmd_tx_dec = hex2dec(cmd_tx_hex);

            fwrite(obj.COM_port, cmd_tx_dec, 'uint8');

            cmd_rx_dec = fread(obj.COM_port, [16, 1]);
            
            cmd_rx_hex = dec2hex(cmd_rx_dec);
            
            res = cmd_rx_dec(6);
        end

        function res = close_laser_impl(obj, ch)
            start_field = '68';
            ctrl_field = '02';
            datlen_field = ['00'; '09'];
            data_field = [dec2hex(ch, 2); repmat('00', 8, 1)];
            parity_field = obj.get_parity_field(ctrl_field, datlen_field, data_field);
            end_field = '16';

            cmd_tx_hex = [start_field; ctrl_field; datlen_field; data_field; parity_field; end_field];
            cmd_tx_dec = hex2dec(cmd_tx_hex);

            fwrite(obj.COM_port, cmd_tx_dec, 'uint8');

            cmd_rx_dec = fread(obj.COM_port, [16, 1]);
            
            cmd_rx_hex = dec2hex(cmd_rx_dec);

            res = cmd_rx_dec(6);
        end

        function res = set_laser_power_impl(obj, ch, pow_double)
            pow_hex = reshape(num2hex(pow_double), 2, [])';

            start_field = '68';
            ctrl_field = '05';
            datlen_field = ['00'; '09'];
            data_field = [dec2hex(ch, 2); pow_hex];
            parity_field = obj.get_parity_field(ctrl_field, datlen_field, data_field);
            end_field = '16';

            cmd_tx_hex = [start_field; ctrl_field; datlen_field; data_field; parity_field; end_field];
            cmd_tx_dec = hex2dec(cmd_tx_hex);

            fwrite(obj.COM_port, cmd_tx_dec, 'uint8');

            cmd_rx_dec = fread(obj.COM_port, [16, 1]);
            cmd_rx_hex = dec2hex(cmd_rx_dec);
            
            res = cmd_rx_dec(6);
        end
        
        function laser = get_laser_status_impl(obj)
            cmd_tx_hex = ['68'; '09'; '00'; '09'; '00'; '00'; '00'; '00'; '00'; '00'; '00'; '00'; '00'; 'ED'; '16'];
            cmd_tx_dec = hex2dec(cmd_tx_hex);
            
            fwrite(obj.COM_port, cmd_tx_dec, 'uint8');
            
            cmd_rx_dec = fread(obj.COM_port, [136, 1]);
            cmd_rx_hex = dec2hex(cmd_rx_dec);
            
            data_field = cmd_rx_hex(5:134, :);
            
            flatten = @(x) reshape(x', 1, []);
            
            for i = 1:10
                laser(i).status = hex2dec(data_field(1+(i-1)*5, :));
                laser(i).power = hex2dec(flatten(data_field(2+(i-1)*5:3+(i-1)*5, :)))/100;
                laser(i).temperature = hex2dec(flatten(data_field(4+(i-1)*5:5+(i-1)*5, :)))/100;
            end
        end
        
        function res = set_laser_wavelength_impl(obj, ch, wavlen_double)
            wavlen_hex = reshape(num2hex(wavlen_double), 2, [])';

            start_field = '68';
            ctrl_field = '06';
            datlen_field = ['00'; '09'];
            data_field = [dec2hex(ch, 2); wavlen_hex];
            parity_field = obj.get_parity_field(ctrl_field, datlen_field, data_field);
            end_field = '16';

            cmd_tx_hex = [start_field; ctrl_field; datlen_field; data_field; parity_field; end_field];
            cmd_tx_dec = hex2dec(cmd_tx_hex);

            fwrite(obj.COM_port, cmd_tx_dec, 'uint8');

            cmd_rx_dec = fread(obj.COM_port, [16, 1]);
            cmd_rx_hex = dec2hex(cmd_rx_dec);
            
            res = cmd_rx_dec(6);            
        end
    end
end

