% (C) Copyright 2018 Mohamed Rezk
% (C) Copyright 2020 CPP visual motion localizer developpers

%% Main Decoding Experiment
%3 minutes 49.8644 seconds; 3 minutes 43.8125 seconds

getOnlyPress = 1;

more off;

% Clear all the previous stuff
clc;
if ~ismac
    close all;
    clear Screen;
end

% make sure we got access to all the required functions and inputs
initEnv();

% set and load all the parameters to run the experiment
cfg = setParameters;
cfg = userInputs(cfg);
cfg = createFilename(cfg);

%%  Experiment

% Safety loop: close the screen if code crashes
try
    
    [cfg] = loadAudioFiles(cfg);

    %% Init the experiment
    [cfg] = initPTB(cfg);

    cfg = postInitializationSetup(cfg);

    [el] = eyeTracker('Calibration', cfg);

    %     if isfield(cfg.design, 'localizer') && strcmpi(cfg.design.localizer, 'MT_MST')
    %         [cfg] = expDesignMtMst(cfg);
    %     else
    [cfg] = expDesign(cfg);
    %     end

    % Prepare for the output logfiles with all
    logFile.extraColumns = cfg.extraColumns;
    logFile = saveEventsFile('init', cfg, logFile);
    logFile = saveEventsFile('open', cfg, logFile);

    % prepare textures
    cfg = apertureTexture('init', cfg);
    cfg = dotTexture('init', cfg);

    disp(cfg);

    % Show experiment instruction
    standByScreen(cfg);

    % prepare the KbQueue to collect responses
    getResponse('init', cfg.keyboard.responseBox, cfg);

    % Wait for Trigger from Scanner
    waitForTrigger(cfg);

    %% Experiment Start

    eyeTracker('StartRecording', cfg);

    cfg = getExperimentStart(cfg);

    getResponse('start', cfg.keyboard.responseBox);

    waitFor(cfg, cfg.timing.onsetDelay);

    %% For Each Block

    for iBlock = 1:cfg.design.nbBlocks
          
        fprintf('\n - Running Block %.0f \n', iBlock);

        eyeTracker('Message', cfg, ['start_block-', num2str(iBlock)]);
        dots=[];
        previousEvent.target = 0;
        % For each event in the block
        for iEvent = 1:cfg.design.nbEventsPerBlock

            % Check for experiment abortion from operator
            checkAbort(cfg, cfg.keyboard.keyboard);

            [thisEvent, thisFixation, cfg] = preTrialSetup(cfg, iBlock, iEvent);

            % we wait for a trigger every 2 events
            if cfg.pacedByTriggers.do && mod(iEvent, 2) == 1
                waitForTrigger( ...
                               cfg, ...
                               cfg.keyboard.responseBox, ...
                               cfg.pacedByTriggers.quietMode, ...
                               cfg.pacedByTriggers.nbTriggers);
            end

            eyeTracker('Message', cfg, ...
                       ['start_trial-', num2str(iEvent), '_', thisEvent.trial_type]);

            % we want to initialize the dots position when targets type is fixation cross
            % or if this the first event of a target pair
            if strcmp(cfg.target.type, 'static_repeat') && ...
                    thisEvent.target == previousEvent.target
            else
                dots = [];
            end
                
            % play the dots and collect onset and duraton of the event
            if cfg.design.blockOrder(iBlock)<=cfg.design.nbRepetitions  %visual blocks 
                [onset, duration, dots] = doDotMo(cfg, thisEvent, thisFixation, dots);
            elseif cfg.design.blockOrder(iBlock)>cfg.design.nbRepetitions %tactile blocks
                [onset, duration] = doAuditoryMotion(cfg, thisEvent);
            end

            thisEvent = preSaveSetup( ...
                                     thisEvent, ...
                                     thisFixation, ...
                                     iBlock, iEvent, ...
                                     duration, onset, ...
                                     cfg, ...
                                     logFile);
            saveEventsFile('save', cfg, thisEvent);

            % collect the responses and appends to the event structure for
            % saving in the tsv file
            responseEvents = getResponse('check', cfg.keyboard.responseBox, cfg, ...
                                         getOnlyPress);

            triggerString = ['trigger_' cfg.design.blockNames{iBlock}];
            saveResponsesAndTriggers(responseEvents, cfg, logFile, triggerString);

            eyeTracker('Message', cfg, ...
                       ['end_trial-', num2str(iEvent), '_', thisEvent.trial_type]);
                   
                   previousEvent = thisEvent;
                   
            if cfg.design.blockOrder(iBlock)<=cfg.design.nbRepetitions  %visual blocks       
                if iEvent ~= cfg.design.nbEventsPerBlock && mod(iEvent,2) == 0
                    waitFor(cfg, cfg.timing.ISI.vis);   %%%% wait for ISI if event is even, that is after every second event
                elseif iEvent ~= cfg.design.nbEventsPerBlock &&  mod(iEvent,2) == 1
                    waitFor(cfg, 0)     %%%% dont wait for ISI if event is odd, so setting the ISI =0
                elseif iEvent == cfg.design.nbEventsPerBlock
                    waitFor(cfg, 0)     %%%% No ISI after the last stimulus in one block
                end
            elseif cfg.design.blockOrder(iBlock)>cfg.design.nbRepetitions %tactile blocks
                if iEvent ~= cfg.design.nbEventsPerBlock && mod(iEvent,2) == 0
                    waitFor(cfg, cfg.timing.ISI.tac);   %%%% wait for ISI if event is even, that is after every second event
                elseif iEvent ~= cfg.design.nbEventsPerBlock && mod(iEvent,2) == 1
                    waitFor(cfg, 0)     %%%% dont wait for ISI if event is odd, so setting the ISI =0
                elseif iEvent == cfg.design.nbEventsPerBlock
                    waitFor(cfg, cfg.timing.ISI.tac)     %%%% No ISI after the last stimulus in one tactile block; here 2 because it is auditory

                end
                
            end

        end

        % "prepare" cross for the baseline block
        % if MT / MST this allows us to set the cross at the position of the next block
        if iBlock < cfg.design.nbBlocks
            nextBlock = iBlock + 1;
        else
            nextBlock = cfg.design.nbBlocks;
        end
        [~, thisFixation] = preTrialSetup(cfg, nextBlock, 1);
        drawFixation(thisFixation);
        Screen('Flip', cfg.screen.win);

        eyeTracker('Message', cfg, ['end_block-', num2str(iBlock)]);

        waitFor(cfg, cfg.timing.IBI(iBlock));

        % trigger monitoring
        triggerEvents = getResponse('check', cfg.keyboard.responseBox, cfg, ...
                                    getOnlyPress);

        triggerString = 'trigger_baseline';
        saveResponsesAndTriggers(triggerEvents, cfg, logFile, triggerString);

    end

    % End of the run for the BOLD to go down
    waitFor(cfg, cfg.timing.endDelay);

    cfg = getExperimentEnd(cfg);

    eyeTracker('StopRecordings', cfg);

    % Close the logfiles
    saveEventsFile('close', cfg, logFile);

    getResponse('stop', cfg.keyboard.responseBox);
    getResponse('release', cfg.keyboard.responseBox);

    eyeTracker('Shutdown', cfg);
    
    % remove the sound data from the cfg before saving it.
    cfg = rmfield(cfg, 'soundData');

    createJson(cfg, cfg);

    farewellScreen(cfg);

    cleanUp();

catch

    cleanUp();
    psychrethrow(psychlasterror);

end
