%  /`-.__                                 /\
%  `. .  ~~--..__                   __..-' ,'
%    `.`-.._     ~~---...___...---~~  _,~,/
%      `-._ ~--..__             __..-~ _-~
%          ~~-..__ ~~--.....--~~   _.-~
%                 ~~--...___...--~~

%serialportlist("available")

% tsp = TSP1000('com1');

wav = get_wav;
feed = genFeed(wav);

feed.TX = feed.TX(1:end);
feed.TY = feed.TY(1:end);

[SNR_, BER_] = baseline(feed)


