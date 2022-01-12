function [subject_params, percent_responses_right] = computeResponse(subjects, huedist_table, huedist, condition_of_interest, color_of_interest, conditions, newtable_Subject, newtable_Condition, newtable_Index, newtable_Subject_response, newtable_Color)

    subject_params = nan(subjects, 4);
    percent_responses_right = nan(subjects, length(huedist_table));

    for p = 2 : (subjects+1)
        for i = 1 : length(huedist_table)
            trials_of_interest = huedist_table(i)==huedist & newtable_Condition==conditions(condition_of_interest) & newtable_Subject == p & newtable_Color == color_of_interest;
            NumPos(i) = sum(newtable_Subject_response(trials_of_interest)==newtable_Index(trials_of_interest));
            OutOfNum(i) = length(newtable_Subject_response(trials_of_interest));
            percent_responses_right(p-1, i) = sum(newtable_Subject_response(trials_of_interest)==newtable_Index(trials_of_interest)) / length(newtable_Subject_response(trials_of_interest));
        end
        PF = @PAL_Logistic;
        StimLevels = huedist_table';
        searchGrid = [0.053 1 0.33 0.03]; %Randomly chose this may need to edit
        paramsFree = [1 1 0 0]; %Randomly chose this may need to edit

        paramsValues = PAL_PFML_Fit(StimLevels, NumPos, OutOfNum, searchGrid, paramsFree, PF);
        for k = 1 : size(paramsValues,2)
            subject_params(p-1, k) = paramsValues(k);
        end
    end
end
