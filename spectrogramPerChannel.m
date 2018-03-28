function [f,t, pMiMeanOverTrials] = spectrogramPerChannel(SR, epochBaseline,epochMi)

    s = size(epochBaseline.DATA);
    numTrials = s(1);
    numCh = s(2);
    dur = s(3);
    freqRange = [5:30]; % determine freq range ([1:512])?
    
    figure();
    for idxCh = 1:numCh
        for idxTrial = 1:numTrials
            baselineEpoch(:) = epochBaseline.DATA(idxTrial,idxCh,:);
            miEpoch(:) = epochMi.DATA(idxTrial,idxCh,:);
            [~,~,~,pBaseline] = spectrogram(baselineEpoch,SR,SR-32,freqRange,SR,'power'); % determine freq range ([1:512])
            [~,f,t,pMi] = spectrogram(miEpoch,SR,SR-32,freqRange,SR,'power'); % determine freq range ([1:512])
            
            pMi = pMi./mean(pBaseline,2); % substract mean of baseline from pMi
            
           % pBaselinePerChannel(:,:,idxTrial,idxCh) = pBaseline;
            pMiPerChannel (:,:,idxTrial) = pMi;
        end
        pMiMeanOverTrials(:,:,idxCh) = 10*log10(mean(pMiPerChannel,3));
        x = [t(1) t(end)];
        y = [f(end) f(1)];
        subplot(4,4,idxCh)
        
        imagesc(x,y,pMiMeanOverTrials(:,:,idxCh)) % wrong labelling at y-axis!
        colorbar
     end
end

