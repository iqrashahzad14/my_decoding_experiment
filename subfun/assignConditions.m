% (C) Copyright 2020 CPP visual motion localizer developpers

function [conditionNamesVector, CONDITON1_INDEX, CONDITON2_INDEX] = assignConditions(cfg)

    [~, nbRepet] = getDesignInput(cfg);

    conditionNamesVector = repmat(cfg.design.names, nbRepet, 1);
    conditionNamesVector = conditionNamesVector(cfg.design.blockOrder);

    % Get the index of each condition
    nameCondition1 = 'horizontal';
    nameCondition2 = 'vertical';
    if isfield(cfg.design, 'localizer') && strcmpi(cfg.design.localizer, 'MT_MST')
        nameCondition1 = 'fixation_right';
        nameCondition2 = 'fixation_left';
    end

    CONDITON1_INDEX = find(strcmp(conditionNamesVector, nameCondition1));
    CONDITON2_INDEX = find(strcmp(conditionNamesVector, nameCondition2));
end