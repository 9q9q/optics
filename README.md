# Optics project fall 2021: Eye See Hue, Eye Choose Hue

## Prerequisites
* MATLAB, [Psychtoolbox](http://psychtoolbox.org/) (run experiment)
* [Palamedes](http://www.palamedestoolbox.org/) (analysis)

## Running the experiment
Run `optics_exp.m`. Things to note (also see code comments):
* You will need to make sure keyboard keys are mapped correctly based on your keyboard and OS
* When working on dev on Mac, need to uncomment some lines at beginning

## Results
* Our results are summarized [here](https://docs.google.com/presentation/d/1CcDr8tBtRUNnMr1f28GHtF8--fbV7bJcwBg5VgwAYjg/edit?usp=sharing) (permission required)
* `data_raw/` contains raw `.mat` output files from our experiments
* `data/` contains converted data (using `data2csv.m`) that you can run `analysis/PFOverlays.m` on

## Analysis
Make sure the Palamedes folder is added to your MATLAB path.
* For plots: `analysis/PFOverlays.m`
* Data in `data/`

## Misc
* `tools/data2csv.m`: convert experiment output (`.mat`) to CSV
* `monitor_color_data.mat` contains monitor color information recorded from PR 650 SpectraScan Colorimeter
* `exp_colors.mat` contains stimulus colors
* `tools/vis_colors.m` provides basic visualization for our colors in CIELAB

