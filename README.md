# The Development Gap in Economic Rationality of Future Elites
Authors:

- Alexander W. Cappelen
- Shachar Kariv
- Erik Ø. Sørensen (contactperson for code and data, erik.sorensen@nhh.no)
- Bertil Tungodden

**Abstract**: We test the touchstones of economic rationality---utility
maximization, stochastic dominance, and expected-utility maximization---of elite
students in the U.S. and in Africa. The choices of most students in both samples
are generally rationalizable, but the U.S. students' scores are substantially
higher. Nevertheless, the development gap in economic rationality between these
future elites is much smaller than the difference in performance on a canonical
cognitive ability test, often used as a proxy for economic decision-making
ability in studies of economic development and growth. We argue for the
importance of including consistency with economic rationality in studies of
decision-making ability.


## Overview

The master file this replication package will:

1. Install the required versions of the necessary `R` packages from CRAN.
2. Downloads the necessary datafiles from Harvard Dataverse: https://doi.org/10.7910/DVN/CCODET .
3. Create all the displays in the paper as separate files (documented below).
4. Create markdown documents for numbers referenced in the paper but not explicitly part of produced tables.




## Data availability statement

The experimental data used to support the findings of this study were collected
by the authors. All data, with documentation, have been deposited in the public
domain at Harvard Dataverse:


The experimental and survey data used to support the findings of this study have
been deposited in the Harvard Dataverse repository (https://doi.org/10.7910/DVN/CCODET).
The data were collected by the authors, and are available under a Creative
Commons Non-commercial license.

We certify that the author(s) of the manuscript have legitimate access to and permission to use the data used in this manuscript, and the data are licensed under a Creative Commons/CC0 license. See [LICENSE_CC0.txt](LICENSE_CC0.txt) for details.

The data file is downloaded when the `targets` plan is first run.


## Computational requirements

### Software requirements

The analysis code was developed on an Ubuntu 22.04.2 machine with R 4.3.0. The 
script that runs all the code (`main.R`) will install the packages needed, of the correct version,
into a local library using the `renv` library (which must be installed ahead of time). The list
of packages (and all necessary recursive dependencies) is found in the `renv` configuration file
`renv.lock` which should not need to be touched.

### Memory and runtime requirements

Calculating the revealed preference statistics (in particular the CCEI for
Expected Utility) is slow. the current setup parallelizes and runs separate
branches for each participant. Running 12 processes in parallel on a 2017
workstation (Xeon E-2136 & 3.3GHz, 40GB memory), each branch takes on average a
bit more than 20 minutes, so there are about 30 individuals processed per hour,
or about 12 hours in total for this task with memory usage at about 25 GB.
The parallel computations are controlled by the `future` library, and in 
`main.R` there is a line to control how many worker processes to start:

> tar_make_future(workers = 12)

Set the number of workers to a number that is compatible with the number of cores 
you can set aside (multiply by two if your processor allows hyperthreading).

Given the revealed preference statistics, the time needed to reproduce
the analyses is trivial (less than a minute).


## Description of programs/code

The graphical displays are produced in the `graphs/` directory (as pdf-files). The tables are
produced in the `tables/` directory (as tex-files). 

The file `R/PollisonEtAl.R` contains functions extracted from the replication package
of Pollison et al (2020a,2020b). This code
was published CC-BY 4.0. The code
in `R/functions.R` contains an interface
function `calculate_rp_statistics(d)` that
calculates the revealed preference statistics
we use on the subset of data `d`.

The dependencies of the analysis is controlled by the `targets` library. The list in 
`_targets.R` defines a directed acyclic graph of dependencies, and the `tar_make` command
figures out which results are cached and which needs to be recalculated. 

Running all the analysis should be possible from the command line with:

> Rscript main.R

This will generate `estimates.html` at the root, and the displays in `graphs/` (figures as pdfs)
and `tables/` (tables as tex-files). 

The `targets` system is smart about
caching intermediate results, so while running `main.R` takes a considerable amount of 
time for the first run, minor adjustments to the output routines in the vignettes are 
do not require the heavy computations to be re-run, and running `main.R` for the second
time is almost free of costs with respect to changes in the display layer. 


### License for Code

The code in `targets.R`, `R/functions.R` and `estimates.Rmd` is licensed under a BSD-3-Clause license. See [LICENSE_BSD-3-Clause.txt](LICENSE_BSD-3-Clause.txt) for details.

The code in `R/PollisonEtAl.R` is a collection of code from Pollison et al (2020b), 
covered by the [Creative Commons BY 4.0 license](https://creativecommons.org/licenses/by/4.0/). Apart from 
collecting several functions into one file, no change was made to this code.


## References

- Polisson, Matthew, John K.-H. Quah, and Ludovic Renou (2020a). "Revealed Preferences over Risk and Uncertainty." American Economic Review 110(6): 1782-1820. https://doi.org/10.1257/aer.20180210.
- Polisson, Matthew, John K.-H. Quah, and Ludovic Renou  (2020b). Data and Code for: Revealed Preferences over Risk and Uncertainty. Nashville, TN: American Economic Association [publisher], Ann Arbor, MI: Inter-university Consortium for Political and Social Research [distributor], 2020-05-27. https://doi.org/10.3886/E112146V1
