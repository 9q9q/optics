% visualize our experiment colors in 2d CIE space

load 16_levels_1115
load exp_colors

radius=0.07509703826058986;
arb_L = 0.3; %select an arbitrary L

% load in rgb and whitepoint
w = cal.white_xyl;
MAX_L = w(3);
w(3) = 1;

r = cal.all_xyl(:, :, 1);
r = r(16, :); % last row 
r(3) = r(3)/MAX_L; % scale L 

g = cal.all_xyl(:, :, 2);
g = g(16, :); % last row 
g(3) = g(3)/MAX_L; % scale L 

b = cal.all_xyl(:, :, 3);
b = b(16, :); % last row 
b(3) = b(3)/MAX_L; % scale L 

plotChromaticity("ColorSpace","xy", "BrightnessThreshold", 0);
hold on;

% plot all points
scatter(r(1), r(2), 50, "k")
scatter(g(1), g(2), 50, "k")
scatter(b(1), b(2), 50, "k")
scatter(w(1), w(2), 50, "white")
scatter(w(1), w(2), 50, "black")

% base colors
base_green = exp_colors.base_green * cal.RGB_to_XYZ;
base_red = exp_colors.base_red * cal.RGB_to_XYZ;
C = makecform('xyz2xyl');
green_xyY = applycform(base_green,C);
red_xyY = applycform(base_red,C);
scatter(green_xyY(1), green_xyY(2), 40, [0 0.5 0], "filled") %xyY
scatter(red_xyY(1), red_xyY(2), 40, "red", "filled") %xyY

% test colors
test_green = exp_colors.test_green * cal.RGB_to_XYZ;
test_red = exp_colors.test_red * cal.RGB_to_XYZ;
C = makecform('xyz2xyl');
test_green = applycform(test_green,C);
test_red = applycform(test_red,C);

scatter(test_green(:, 1), test_green(:, 2), 40, [0 0.5 0], "+", "LineWidth",1.5)
scatter(test_red(:, 1), test_red(:, 2), 40, "red", "+", "LineWidth", 1.5)

% line between g and b
plot([b(1) g(1)], [b(2) g(2)], "k")
plot([b(1) r(1)], [b(2) r(2)], "k")
plot([r(1) g(1)], [r(2) g(2)], "k")
% circle
th = 0:pi/50:2*pi;
xunit = radius * cos(th) + w(1);
yunit = radius * sin(th) + w(2);
plot(xunit, yunit, Color="black", LineWidth=1, LineStyle="--");


