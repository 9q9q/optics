files = {'sub2sess1data.csv' 'sub2sess2data.csv' 'sub2sess3data.csv' 'sub_3_sess_1_data.csv' 'sub_3_sess_2_data.csv' 'sub_3_sess_3_data.csv' 'sub_4_sess_1_data.csv' 'sub_4_sess_2_data.csv' 'sub_4_sess_3_data.csv' 'sub_5_sess_1_data.csv' 'sub_5_sess_2_data.csv' 'sub_5_sess_3_data.csv' 'sub_6_sess_1_data.csv' 'sub_6_sess_2_data.csv' 'sub_6_sess_3_data'}; %add all csv's for each session here, no commas

newtable = table();
%concatenating all the .csv data files into one table
for k = 1:length(files)
    data = readtable(files{k});
    
    newtable = [newtable; data];
end

% Assigning variables
subject_table   = unique(newtable.Subject)';
subjects        = size(subject_table,2); %aka 5
huedist         = round(newtable.HueDistance,3);
huedist_table   = unique(huedist); %aka the five hue distances
conditions      = unique(newtable.Condition)'; %static '1' or moving '2'
positions       = 3; %Left, Middle, or Right
color           = size(unique(newtable.Color)',2); %Color (Red "1" or Green "2")

percent_responses_right = nan(1, length(huedist_table));

%adjust these to change Color and Condition 
condition_of_interest = 1; %static '1' or moving '2'
color_of_interest = 1; %Color (Red "1" or Green "2") 

for i = 1 : length(huedist_table)
    trials_of_interest = huedist_table(i)==huedist & newtable.Condition==conditions(condition_of_interest) & newtable.Color == color_of_interest;
    NumPos(i) = sum(newtable.Subject_response(trials_of_interest)==newtable.Index(trials_of_interest));
    OutOfNum(i) = length(newtable.Subject_response(trials_of_interest));
    percent_responses_right(i) = sum(newtable.Subject_response(trials_of_interest)==newtable.Index(trials_of_interest)) / length(newtable.Subject_response(trials_of_interest));
end

PF = @PAL_Logistic;
StimLevels = huedist_table'; %'StimLevels': vector containing stimulus levels used.
searchGrid = [0.053 1 0.33 0.03]; %Randomly chose this may need to edit
paramsFree = [1 1 0 0]; %Randomly chose this may need to edit

paramsValues = PAL_PFML_Fit(StimLevels, NumPos, OutOfNum, searchGrid, paramsFree, PF);


%%
%plotting the data
figure
plot(huedist_table, percent_responses_right, 'o') 
xeval = linspace(0,0.065,1000);
yeval = PF(paramsValues,xeval);
hold on
plot(xeval,yeval, '-')

%Calculated threshold first...
%(yeval(1000)-yeval(1))/2 + yeval(1) This is our Threshold!!
yvalthresh = 0.665;
thresh = PF(paramsValues, yvalthresh,'inv');
text(thresh,  yvalthresh, sprintf('T = %0.3f' , thresh))
line([thresh thresh], [0.3  yvalthresh],'LineStyle','-')
line([0 thresh], [ yvalthresh  yvalthresh],'LineStyle','-')

%labelling axis
ylabel('Percent Response Correct','FontSize',20);
if color_of_interest == 1 && condition_of_interest == 1
    title('Red Static Condition','FontSize',20);
elseif color_of_interest == 1 && condition_of_interest == 2
    title('Red Moving Condition','FontSize',20);
elseif color_of_interest == 2 && condition_of_interest == 1
    title('Green Static Condition','FontSize',20);
else 
    title('Green Moving Condition','FontSize',20);
end
xlabel('Hue Distance','FontSize',20);

%%
%calculating static condition
condition_of_interest = 1; 

[subject_params, percent_responses_right] = computeResponse(subjects, huedist_table, huedist, condition_of_interest, color_of_interest, conditions, newtable.Subject(:), newtable.Condition(:), newtable.Index(:), newtable.Subject_response(:), newtable.Color(:));

percent_responses_right_static = percent_responses_right;
subject_params_static = subject_params;

%%
%calculating values for static condition
subject_table_fixed = [1; 2; 3; 4; 5];
condition_table_static = ones(5,1);
condition_table_moving = 2*condition_table_static;
yeval_static_subjects = nan(subjects,1000);
thresh_static_subjects = nan(1,subjects);

for p = 2 : (subjects+1)  
    xeval = linspace(0,0.065,1000);
    yeval_static_subjects(p-1,:) = PF(subject_params_static(p-1,:),xeval);

    %Calculated threshold first...
    %(yeval(1000)-yeval(1))/2 + yeval(1) This is our Threshold!!
    yvalthresh = 0.665;
    thresh_static = PF(subject_params_static(p-1,:), yvalthresh,'inv');
    thresh_static_subjects(1,p-1) = thresh_static;    
end

subject_and_threshold_static = table(subject_table_fixed, condition_table_static, thresh_static_subjects', 'VariableNames', {'Subject', 'Static', 'Threshold'});
data_static = grpstats(subject_and_threshold_static, {'Static'}, {'mean','sem'}, 'DataVars',{'Threshold'});

%%
%For moving since conditions is 2
condition_of_interest = 2; 

[subject_params, percent_responses_right] = computeResponse(subjects, huedist_table, huedist, condition_of_interest, color_of_interest, conditions, newtable.Subject(:), newtable.Condition(:), newtable.Index(:), newtable.Subject_response(:), newtable.Color(:));

percent_responses_right_moving = percent_responses_right;
subject_params_moving = subject_params;

%%
%plotting each subject overlaying the static and moving
figure
subjects_thresholds_moving = nan(subjects,1);

for p = 2 : (subjects+1)
    subplot(1, subjects,p-1,'nextplot','add')
    
    %if red
    if color_of_interest == 1
        plot(huedist_table, percent_responses_right_moving(p-1,:), 'ro', 'LineWidth',2)
        plot(huedist_table, percent_responses_right_static(p-1,:), 'ro')
    else %if green
        plot(huedist_table, percent_responses_right_moving(p-1,:), 'go','LineWidth',2)
        plot(huedist_table, percent_responses_right_static(p-1,:), 'o', 'color',[0 0.5 0])
         ylim([0 0.9])
    end

    xeval = linspace(0,0.065,1000);
    yeval = PF(subject_params_moving(p-1,:),xeval);
    hold on
    
    %if red
    if color_of_interest == 1
        plot(xeval,yeval, 'r-', 'LineWidth',2)
        plot(xeval,yeval_static_subjects(p-1,:), 'r-')
    else %if green
        plot(xeval,yeval,  'g-', 'LineWidth',2)
        plot(xeval,yeval_static_subjects(p-1,:), 'color',[0 0.5 0])
    end
    
    title(['Subject ', num2str(p-1)]);
    
    if p == 2
        ylabel('Percent Responses Correct','FontSize',20);
    end
    if p == 4
        xlabel('Hue Distance','FontSize',20);
    end
    
    %Calculated threshold first...
    %(yeval(1000)-yeval(1))/2 + yeval(1) This is our Threshold!!
    yvalthresh = 0.665;
    thresh = PF(subject_params_moving(p-1,:), yvalthresh,'inv');
    subjects_thresholds_moving(p-1, 1) = thresh;
    text(thresh,  yvalthresh, sprintf('T_m = %0.3f' , thresh));
    text(thresh_static_subjects(p-1),  0.5, sprintf('T_s = %0.3f' , thresh_static_subjects(p-1)));
    if p == subjects + 1
        legend({'Moving','Static'},'Position',[0.9 0.2 0.01 0.05], 'LineWidth',[1.5])
    end
    
    if color_of_interest == 1 
        sgtitle('Red Moving and Static Conditions','FontSize',15);
    else
        sgtitle('Green Moving and Static Conditions','FontSize',15);
    end 
end

subject_and_threshold_moving = table(subject_table_fixed, condition_table_moving, subjects_thresholds_moving, 'VariableNames', {'Subject', 'Moving', 'Threshold'});
data_moving = grpstats(subject_and_threshold_moving, {'Moving'}, {'mean','sem'}, 'DataVars',{'Threshold'});
%%
figure
errorbar(2, data_moving.mean_Threshold,data_moving.sem_Threshold, 'o');
hold on
errorbar(1, data_static.mean_Threshold,data_static.sem_Threshold, 'o');
set(gca,'xlim',[0 3]);
xticks([1 2])
set(gca,'XTickLabel',{'Static';'Moving'});
if color_of_interest == 1
    title('Average Thresholds in Static and Moving Conditions: Red Color');
else
    title('Average Thresholds in Static and Moving Conditions: Green Color');
end
ylabel('Average Thresholds');





