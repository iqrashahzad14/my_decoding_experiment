% (C) Copyright 2020 CPP visual motion localizer developpers

%direction matrix has motion directions in sequential order
%one block: 0 180 0 180 0 180...
%another block: 90 270 90 270
%targets introduced at the positins of fixation targets (repeation of
%either of the direction chosed with equal probability

function cfg = setDirections(cfg)

    [CONDITION1_DIRECTIONS, CONDITION2_DIRECTIONS] = getDirectionBaseVectors(cfg);

    [NB_BLOCKS, NB_REPETITIONS, NB_EVENTS_PER_BLOCK] = getDesignInput(cfg);

    [~, CONDITON1_INDEX, CONDITON2_INDEX] = assignConditions(cfg);

    if mod(NB_EVENTS_PER_BLOCK, length(CONDITION1_DIRECTIONS)) ~= 0
        error('Number of events/block not a multiple of number of motion/static direction');
    end

    % initialize
    directions = zeros(NB_BLOCKS, NB_EVENTS_PER_BLOCK);

    % Create a vector for the static condition
    NB_REPEATS_BASE_VECTOR = NB_EVENTS_PER_BLOCK / length(CONDITION2_DIRECTIONS);

%     static_directions = repmat( ...
%                                CONDITION2_DIRECTIONS, ...
%                                1, NB_REPEATS_BASE_VECTOR);

    for iMotionBlock = 1:NB_REPETITIONS

        if isfield(cfg.design, 'localizer') && strcmpi(cfg.design.localizer, 'MT_MST')

            % Set motion direction for MT/MST localizer

            directions(CONDITON1_INDEX(iMotionBlock), :) = ...
                repeatShuffleConditions(CONDITION1_DIRECTIONS, NB_REPEATS_BASE_VECTOR);

            directions(CONDITON2_INDEX(iMotionBlock), :) = ...
                repeatShuffleConditions(CONDITION2_DIRECTIONS, NB_REPEATS_BASE_VECTOR);
            
        else

            % Set motion direction and static order

%             directions(CONDITON2_INDEX(iMotionBlock), :) = ...
%                 repeatShuffleConditions(CONDITION1_DIRECTIONS, NB_REPEATS_BASE_VECTOR);
% 
%             directions(CONDITON1_INDEX(iMotionBlock), :) = static_directions;
%not using random presentation, but the sequential presenation of events 
            directions(CONDITON1_INDEX(iMotionBlock), :) = repmat(CONDITION1_DIRECTIONS, 1, NB_REPEATS_BASE_VECTOR);
            directions(CONDITON2_INDEX(iMotionBlock), :) = repmat(CONDITION2_DIRECTIONS, 1, NB_REPEATS_BASE_VECTOR);
            
        end

    end

%     cfg.design.directions = directions;
      
    for row= 1:2*NB_REPETITIONS
        for col=1:NB_EVENTS_PER_BLOCK
            if cfg.design.fixationTargets(row, col) && cfg.design.fixationTargets(row, col+1)==1
%                randpos=randi([0,1]);%to create repeated stimulus at the position of fixation targets
%                directions(row,col+randpos)=directions(row,col+1-randpos);%Selection of repeated stimulus is random with equal probability, chosen btwn two motion directions)
               directions(row,col+1)=directions(row,col); %put A=directions, to change only the second stimulus (i.e repeat the first stimulus)
            end

        end
    end
    cfg.design.directions = directions;
    cfg.design.directions = directions(cfg.design.blockOrder, :);
end
