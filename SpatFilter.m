function [data] = SpatFilter(data, type, lap, NumChannels)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
    if type == 'CAR'
            mean_data = mean(data(1:NumChannels,:),1);
            for ch = 1:1:NumChannels
                data(ch,:) = data(ch,:)-mean_data;
            end
            disp('CAR filtering')
    elseif type == 'LAP'
        data = lap*data(1:NumChannels,:); 
        disp('Laplacian filtering')
    else
        disp('Error, type not undertsood');
    end
        


end

