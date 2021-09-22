Retinotopy Analysis
===

This toolbox allows you to analyze data from a standard phase-encoded fMRI paradigm. Functions are mainly based on a tutorial written by Sam Schwarzkopf. The tutorial can be found [here](https://figshare.com/articles/journal_contribution/Retinotopy_tutorial/1206288).

## Installation
To use the functions of this toolbox, include the following code into your `startup.m` file:

```matlab
%------------- Retinotopy ----------------------------%
path_spm12 = <PATH-TO-SPM12-ROOT>;
path_retinotopy = <PATH-TO-RETINOTOPY-ROOT>;

% add spm12 and reinotopy functions
addpath(genpath(path_spm12));
addpath(fullfile(path_retinotopy, 'retinotopy'));

clear path_spm12 path_retinotopy;
%-----------------------------------------------------%
```

You have to specify the paths to the root directory of this toolbox and to the directory of your [SPM12](https://www.fil.ion.ucl.ac.uk/spm/software/spm12/) installation.

External functions are copyrighted by their respective authors and might not be covered under the same GPL license as the rest of this toolbox.

## Usage
Two example scripts can be found in the `scripts` folder.
