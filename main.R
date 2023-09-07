renv::restore()
source("_targets.R")

# If you have local cached objects (from running tar_make() previously)
# uncomment the following line to delete the cache and calculate
# everything from scratch.
#
tar_destroy()

# set the number of workers to a number not larger than the
# number of threads your computer can comfortably run in parallel
tar_make_future(workers = 6)
