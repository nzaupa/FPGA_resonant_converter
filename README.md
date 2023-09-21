# Programs that are in this folder

TO BE UPDATED

`H_bridge_variable_frequency`: generate a square waveform with variable frequency in through the H-bridge. The frequency varies from 10kHz to 100kHz with a step of 1Khz.

`HybridControl_phi_2022`: old control that replicate an amplitude modulation behavior. The core of the controller is indeed in the 'blocks' folder.

`LLC_hybrid_2023_july`: hopefully, wanna be the control that will be implement  frequency+amplitude modulation with the close loop on the output current.

`SensingTest_ADC`: programs that generate a square waveform in the H-bridge, which is then used to test the ADC measurements on the daughter board by replicating the signal in the DAC.

### Blocks in Verilog for helpful functions

> I have discovered that we can create more module on the same `*.v` file, the name of the file has no importance. Therefore, I have grouped the functions. Also, with a `for` it is possible to instantiate `N` modules. The basic module has the suffix `_core` and code in backward compatible (at least for now).

 - `dead_time.v` main file with the following modules
   - `dead_time_core`: introduce a delay on the rising edge of a signal1
   - `dead_time`: instantiate `N` modules of `dead_time_core` in order to operate on a multi-wire signal
 - `debounce.v` main file with the following modules
   - `debounce_core`: let a signal change only after it is stable for `DEBOUNCE_TIME` clock cycles
   - `debounce`: instantiate `N` modules of `debounce_core` in order to operate on a multi-wire signal
 - `display_7seg.v` main file managing the 7-segment display
   - `hex2seg`: creates the link between 0-F and the segments (DP excluded)  
   - `dec2hex`: prepare 2-digit decimal number into "hex-equivalent" so that with `hex2seg` they can be shown
   - `dec2seg`: the same as up, here still for compatibility purpose. It will be removed
   - `num2seg`: might become `dec2seg`
 - `trigonometry.v`
   - `trigonometry_deg` compute sine and cosine of an angle in degrees
   - `trigonometry_rad` compute sine and cosine of an angle in radiants
 - different files for the hybrid control
   - `hybrid_control_theta.v`  -  working
   - `hybrid_control_phi.v`    -  working
   - `hybrid_control_theta_phi.v` - not working
- `regularization.v` main file with the following modules
   - `regularization_core`: debounce a signal and prevent it to change for a fixed time
   - `regularization`: parametric multi-wire extension
 - `manual_value_control.v`
   - `theta_control`: used to control theta within a fixed range
   - `phi_control`: use to control there within a fixed range
   - `angle_control_theta_phi`: currently it should not be used anywhere

TO BE DONE
 - parametric LPF


---
---

## Quick Git guide

Install git from [here](https://git-scm.com/downloads). Make sure to install also the *GCM - git credential manager* so that it manage the login for the push

next you can find the commands but first a short overview of basic workflow ready-to-go

### example

Start locally and upload online:

1. `git init` create local "storage"
2. `touch .gitignore` create *.gitignore* file if needed
3. `git add .` add all files to the staging
4. `git commit -m "comment"` create a commit with a comment tha will be shown in Github
5. `git remote add origin <url_from_github>` create the *origin* path
6. `git push -u origin branch_name` upload modification to the selected branch
7. branches can be merged directly on GitHub

Start from an exiting repository

1. install git
2. `git clone <repository_url>` to copy locally the project
3. `git checkout -b <new_branch_name>` create a new branch
4. do your work
5. `git add .` I don't know if it is necessary, probably only if you add new files
6. `git commit -m "my_comment"` commit the work
7. origin is already there from the `clone` command
8. `git push -u origin <branch_name>` now your branch is online and could be merged then

### Commands

Local

- `git init` create the git files in the repository folder
- `git add .` add all files of the current directory into the **staging**
- `git add <path>` add files in the path or specific files
- `git commit -m "comment"` create a version ready to be pushed with the comment given
- `git branch -d <branch_name>` delete a branch
- `git status` show the actual status and active branch
- `git branch` show the active branches
- `git checkout -b <branch_name>` create a new branch and move to it
- `git checkout <branch_name>` change the current branch
- `touch .gitignore` create *.gitignore* NOTE that `touch.exe` must be in windows PATH (search *Edit environment variable for your account* or *path* and then modify by adding the new path to the existing one). `touch` is located in git installation folder `..\Git\usr\bin\`
- `git rm -r --cached ./` delate all the files in the staging, useful when *.gitignore* is updated so that the new loaded branch won't consider the ignored files

Interaction with online repository

- `git remote add origin <url_from_github>` create a local link *origin* to the online repository *from_the_url*
- `git remote -v` show the current *origin*
- `git push -u origin <branch_name>` load into GitHub the current branch
- `git pull origin <branch_name>`
