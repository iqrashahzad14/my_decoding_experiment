% (C) Copyright 2020 CPP visual motion localizer developpers

function varargout = preTrialSetup(varargin)
    % varargout = postInitializatinSetup(varargin)

    % generic function to prepare some structure before each trial

    [cfg, iBlock, iEvent] = deal(varargin{:});

    % set direction, speed of that event and if it is a target
    thisEvent.modality_type = cfg.design.modalityOrder{iBlock};
    thisEvent.trial_type = cfg.design.blockNames{iBlock};
    thisEvent.direction = cfg.design.directions(iBlock, iEvent);
    thisEvent.speedPix = cfg.design.speeds(iBlock, iEvent);
    thisEvent.target = cfg.design.fixationTargets(iBlock, iEvent);
    %from auditory (IQRA)
    thisEvent.fixationTarget = cfg.design.fixationTargets(iBlock, iEvent);
%     thisEvent.soundTarget = cfg.design.soundTargets(iBlock, iEvent);
%     thisEvent.isStim = logFile.isStim;

    % If this frame shows a target we change the color of the cross
    thisFixation.fixation = cfg.fixation;
    thisFixation.screen = cfg.screen;

    % ThisEvent.dotCenterXPosPix determines by how much the dot matrix has to be
    % shifted relative to the center of the screen.
    % By default it is centered on screen but for the MT/MST localizer we
    % shift so the center of the radial motion is matched to that of the
    % aperture on the side of the screen.
    %
    % Meanwhile the cross is shifted on the opposite side
    %

    thisEvent.dotCenterXPosPix = 0;

    switch thisEvent.trial_type
        case 'fixation_right'
            cfg.aperture.xPosPix = -abs(cfg.aperture.xPosPix);

            thisEvent.dotCenterXPosPix = cfg.aperture.xPosPix;

            thisFixation.fixation.xDisplacement = cfg.design.xDisplacementFixation;
            thisFixation = initFixation(thisFixation);

        case 'fixation_left'
            cfg.aperture.xPosPix = +abs(cfg.aperture.xPosPix);

            thisEvent.dotCenterXPosPix = cfg.aperture.xPosPix;

            thisFixation.fixation.xDisplacement = -cfg.design.xDisplacementFixation;
            thisFixation = initFixation(thisFixation);

    end

    varargout = {thisEvent, thisFixation, cfg};

end
