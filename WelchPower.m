function[pxx,f] = WelchPower(SR, Epoch, ch)

    S = size(Epoch.DATA);
    NumTrials = S(1);
    Dur = S(3);
    Data = zeros(NumTrials,Dur);
    Data(:,:) = Epoch.DATA(:,ch,:);
    [pxx,f] = pwelch(Data', 0.5*SR,[],[],SR);
    
end

