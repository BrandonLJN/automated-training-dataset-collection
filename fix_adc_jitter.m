function W = fix_adc_jitter(W)
    V = clip_channels(W);
    
%     figure; plot(V)
      
    X = get_channel_width(V);
    
    for i = 1:NUM_CHANNELS
       s = W(X(i,1)-BETA:X(i,2)+BETA);
       width = X(i,2)-X(i,1)+1;
       h = floor((X(i,1) + X(i,2))/2);
       
       offset = h - STD_START - (i-1)*STD_CHANNEL_SPACING;
       
       s = resample(s, STD_WIDTH+2*BETA, width+2*BETA);
       
       len_diff = length(s) - width-2*BETA;
       l = floor(len_diff/2);
       r = len_diff - l;
       
       W(X(i,1)-BETA-l-offset:X(i,2)+BETA+r-offset) = s;
       %W(X(i,2)+BETA+r-offset+1:end) = circshift(W(X(i,2)+BETA+r-offset+1:end), -offset)
    end
end

function val = NUM_CHANNELS, val = 7;          end
function val = STD_START, val = 70;            end
function val = STD_CHANNEL_SPACING, val = 125; end
function val = BETA, val = 22;                 end
function val = STD_WIDTH, val = 73;            end
function val = CLIP_THRESHOLD, val = 0.2;      end 

function W = clip_channels(W)
    I    = find(W >= CLIP_THRESHOLD);
    W(I) = CLIP_THRESHOLD;
    L = length(I);
    for i = 1:L-1
        if I(i+1) - I(i) > 1 && I(i+1) - I(i) < 6
            W(I(i):I(i+1)) = CLIP_THRESHOLD;
        end
    end
end

function X = get_channel_width(W)
    L = length(W);
    X = zeros(NUM_CHANNELS, 2);
    i_ch = 1;

    for i = 1:L-1
        if W(i) < CLIP_THRESHOLD && W(i+1) == CLIP_THRESHOLD
            X(i_ch, 1) = i+1;
        elseif W(i) == CLIP_THRESHOLD && W(i+1) < CLIP_THRESHOLD
            X(i_ch, 2) = i+1;
            i_ch = i_ch + 1;
        end
    end
end
    