function [filtered_s] = TempFilter(s,f_min, f_max, order,SR,NumChannels)
%Temporal filtering on Raw data
%   Does it for each channel
    n = order/2;
    [B, A] = butter(n, [f_min, f_max]/SR/2);
    filtered = zeros(size(s));
    for ch = 1:NumChannels
        filtered(:,ch) = filter(B,A,s(:,ch));
    end
    filtered_s = filtered';
end

