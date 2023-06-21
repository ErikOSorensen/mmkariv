library(targets)
library(tarchetypes)
library(future)
library(visNetwork)
library(future.callr)
future::plan(callr)
source("R/functions.R")

tar_option_set(
  packages = c(
    "dplyr",
    "tidyr",
    "here",
    "ggplot2",
    "forcats",
    "haven"
  )
)

list(
  tar_target(background_file, "data/background.dta", format="file"),
  tar_target(RP_file, "data/calculated_RP_measures.dta", format="file"),
  tar_target(decisions_file, "data/decisions.dta", format="file"),
  tar_target(tanzaniasurvey_file, "data/tanzaniasurvey.dta", format="file"),
  tar_target(background, read_dta(background_file)),
  tar_target(RP, read_dta(RP_file)),
  tar_target(decisions, read_dta(decisions_file)),
  tar_target(tanzaniasurvey, read_dta(tanzaniasurvey_file)),
  tar_target(df, clean_rectangular(background, RP, decisions)),
  tar_target(fig_dta, figuredata(df)),
  tar_target(cdf_dta, cdf_data(df)),
  tar_target(survival_gg, survivalgraph(cdf_dta)),
  tar_render(all_output, "estimates.Rmd")
)