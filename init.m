function init

addpath(genpath('utils'))
addpath(genpath('components/waveshaper'))
addpath(genpath('components/DSO'))
addpath(genpath('components/LaserArray'))
addpath(genpath('components/OSAMon'))
addpath(genpath('components/NEMon'))
addpath(genpath('components/DSP/rx_test'))
addpath(genpath('components/AWG'))
run('components/DSP/boring/init')

conf_email;

delete 'NE_ref.mat';

cprint(['{RED}          ,-._____,-.                \n', ...
        '         (_c       c_)               \n', ...
        '          /  {BLACK}e-i-e{RED}  \\                \n', ...
        '         (  (._|_,)  )               \n', ...
        '          >._`---''_,<                \n', ...
        '        ,''/  `---''  \\`.              \n', ...
        '      ,'' /           \\ `.            \n', ...
        '     (  ({CYAN} xiong xiong{RED} )  )           \n', ...
        '      `-''\\           /`-''          \n', ...
        '         |`-._____.-''|               \n', ...
        '         |     Y     |               \n', ...
        '         /     |     \\               \n', ...
        '        (      |      )    \n', ...
        '         `-----^-----''               \n']);