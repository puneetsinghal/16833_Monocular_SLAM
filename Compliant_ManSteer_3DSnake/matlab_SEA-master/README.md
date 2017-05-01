# matlab_SEA

This is a repository for reusable matlab code for the HEBI series elastic actuator modules.
If you do not want to use git and simply want to use this code as quickly as possible, click "Download ZIP". By doing this you will be able to edit the code locally, but will not be able to upload any changes.

If you have git installed then do not download the zip, instead run 

`git clone https://github.com/biorobotics/matlab_SEA.git`

# About this repository

This repository provides matlab utilities and demos for HEBI modules. It relies on the [HEBI SDK](https://hebirobotics.atlassian.net/wiki/display/documentation/SDK+Builds), install it before trying to use this code.
 
Currently this repository contains:

* Plotting Tools

# How to use the code in this repository

1. Obtain the HEBI SDK and adding the hebi folder to your matlab path.

2. Add to path (in matlab) the utilities you want to use, for example plottingTools

  `addpath('plottingTools')`

3. Use matlab's "help" function. 

  `help plottingTools`

  `help HebiPlotter`

4. Test out the examples

  `cd plottingTools/examples`

  `plotHebiTest`


# Adding to this repository

You've created a great feature and want to share it! You need to:

1. Create a new git branch
2. Push your new branch to this github repository. DO NOT PUSH DIRECTLY TO MASTER.
3. Get at least one code review.
4. Merge your changes into the master branch