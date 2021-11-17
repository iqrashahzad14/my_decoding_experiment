% (C) Copyright 2020 CPP visual motion localizer developpers

function [CONDITION1_DIRECTIONS, CONDITION2_DIRECTIONS] = getDirectionBaseVectors(cfg)

    % CONSTANTS

    % Set directions for static and motion condition
    CONDITION1_DIRECTIONS = cfg.design.motionDirectionsHorizontal;
    CONDITION2_DIRECTIONS = cfg.design.motionDirectionsVertical;
    

    % for for the MT / MST localizer
    if isfield(cfg.design, 'localizer') && strcmpi(cfg.design.localizer, 'MT_MST')
        CONDITION1_DIRECTIONS = cfg.design.motionDirections;
        CONDITION2_DIRECTIONS = cfg.design.motionDirections;
    end

end
