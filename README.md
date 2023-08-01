# Programs that are in this folder

TO BE UPDATED

`H_bridge_variable_frequency`: generate a square waveform with variable frequency in through the H-bridge. The frequency varies from 10kHz to 100kHz with a step of 1Khz.

`HybridControl_phi_2022`: old control that replicate an amplitude modulation behavior. The core of the controller is indeed in the 'blocks' folder.

`LLC_hybrid_2023_july`: hopefully, wanna be the control that will be implement  frequency+amplitude modulation with the close loop on the output current.

`SensingTest_ADC`: programs that generate a square waveform in the H-bridge, which is then used to test the ADC measurements on the daughter board by replicating the signal in the DAC.

~

## Quick git guide

Install git from [here](https://git-scm.com/downloads). Make sure to install also the *GCM - git credential manager* so that it manage the login for the push

- `git init` create the git files in the repository folder
- `git add .` add all files of the current directory into the **staging**
- `git add <path>` add files in the path or specific files
- `git commit -m "comment"` create a version ready to be pushed with the comment given
- `git push -u origin <branch_name>` load into GitHub the current branch
`git branch -d <branch_name>` delete a branch

Add online repository

- `git remote add origin <url_from_github>` create a local link *origin* to the online repository *from_the_url*
- `git remote -v` show the current *origin*

Get changes from the repository

1. `git pull origin <branch_name>`

Manage repository

- `git status` show the actual status and active branch
- `git branch` show the active branches
- `git checkout -b <branch_name>` create a new branch and move to it
- `git checkout <branch_name>` change the current branch
- `touch .gitignore` create *.gitignore* NOTE that `touch.exe` must be in windows PATH (search *Edit environment variable for your account* or *path* and then modify by adding the new path to the existing one). `touch` is located in git installation folder `..\Git\usr\bin\`
- `git rm -r --cached ./` delate all the files in the staging, useful when *.gitignore* is updated so that the new loaded branch won't consider the ignored files

touch in the PATH
touch for gitignore

## create a new repository - example

Locally:

1. `git init` create local "storage"
2. `touch .gitignore` create *.gitignore* file if needed
3. `git add .` add all files to the staging
4. `git commit -m "comment"` create a commit with a comment

To upload on a cloud (e.g. GitHub)

1. `git remote add origin <url_from_github>` create the *origin* path that is used to load to the online repository
2. `git push -u origin branch_name`
3. then branches can be merged directly on GitHub
