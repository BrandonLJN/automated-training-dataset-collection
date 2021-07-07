function [status] = RecChSet(tsp,ch,LO_ch)
wavelength = [1549.32 1549.723 1550.121 1550.521 1550.921 1551.320 1551.720 1552.123];

status = 0;

try
    selch(ch);          
catch ME
    status = 1;
    return;
end

try
    % ------------------ set LO ------------------------
    tsp.close_laser(LO_ch);
    tsp.set_laser_wavelength(LO_ch, wavelength(ch));
    tsp.open_laser(LO_ch);
catch ME
	status = 2;
end
