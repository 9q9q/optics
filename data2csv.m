% convert our data struct to csv required for plotting
% Subject,Session,Condition,Color,HueDistance,Index,Subject_response

% example command:
% data2csv(["sub_1_sess_1_data.mat" "sub_1_sess_2_data.mat" "sub_1_sess_3_data.mat"])
function data2csv(filenames)
    colors_filename = "exp_colors.mat";
    cal_filename = "16_levels_1115.mat"; % for RGB to XYZ conversion
    load(colors_filename) % loads variable named "exp_colors"
    load(cal_filename) % loads struct named "cal"

    for resp_filename = filenames      
        load(resp_filename) % loads struct named "data"
        
        num_rows = length(data.motion);
        
        % get the easy columns
        resp_filename = convertStringsToChars(resp_filename);
        sub = str2double(resp_filename(5));
        sess = str2double(resp_filename(12));
        sub_col = repmat(sub, num_rows, 1);
        sess_col = repmat(sess, num_rows, 1);
        cond_col = data.motion;
        idx_col = data.odd_one_out;
        resp_col = data.responses;
        
        % hue dist column
        % convert to rgb to xyz
        base_XYZ = data.base_colors * cal.RGB_to_XYZ;
        test_XYZ = data.test_colors * cal.RGB_to_XYZ;
        % xyz to xyY
        C = makecform('xyz2xyl');
        base_xyY = applycform(base_XYZ,C);
        test_xyY = applycform(test_XYZ,C);
        % euclidean distance (2-norm of each row)
        hue_dist_col = vecnorm([base_xyY - test_xyY], 2, 2);
        
        % color column
        % set color by checking whether base color at each row is present in green base colors
        color_col = ones(num_rows, 1); % init all to red
        for i = 1:length(color_col)
            if ismember(data.base_colors(i, :), exp_colors.base_green)
                color_col(i) = 2; % green
            end
        end
        
        % put in CSV format and save to same name as original data response file
        % but with .csv suffix instead of .mat
        csv = [sub_col sess_col cond_col color_col hue_dist_col idx_col resp_col];
        T = array2table(csv);
        T.Properties.VariableNames(1:size(csv, 2)) = {'Subject', 'Session', 'Condition', 'Color', 'HueDistance', 'Index', 'Subject_response'};
        writetable(T, strcat(strrep(resp_filename,'.mat',''), ".csv"))
    end

end
