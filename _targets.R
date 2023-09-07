library(targets)
library(tarchetypes)
library(future)
library(visNetwork)
library(future.callr)
future::plan(callr)
source("R/functions.R")
source("R/PollisonEtAl.R")
tar_option_set(
  packages = c(
    "dataverse",
    "dplyr",
    "tidyr",
    "here",
    "ggplot2",
    "forcats",
    "haven", 
    "gtools",                # Per instruction by Pollison, Quah, and Renou.
    "lpSolve",               # Per instruction by Pollison, Quah, and Renou.
    "lpSolveAPI"             # Per instruction by Pollison, Quah, and Renou.
  )
)

DATA_SERVER = "dataverse.harvard.edu"

list(
  tar_target(background, get_dataframe_by_name(
    filename="background.tab",
    dataset="10.7910/DVN/CCODET",
    server = DATA_SERVER,
    original = TRUE,
    .f = haven::read_dta)
  ),
  tar_target(tanzaniasurvey, get_dataframe_by_name(
    filename="tanzaniasurvey.tab",
    dataset="10.7910/DVN/CCODET", 
    server = DATA_SERVER,
    original = TRUE,
    .f = haven::read_dta)
  ),
  tar_target(decisions, get_dataframe_by_name(
    filename="decisions.tab",
    dataset="10.7910/DVN/CCODET", 
    server = DATA_SERVER,
    original = TRUE,
    .f = haven::read_dta)
  ),
  tar_target(studysubjects_categorized, get_dataframe_by_name(
    filename = "studysubjects_categorized.tab",
    dataset="10.7910/DVN/CCODET", 
    server = DATA_SERVER,
    original = TRUE,
    .f = readr::read_csv)
  ),
  tar_target(df, clean_rectangular(background, RP, decisions)),
  tar_target(fig_dta, figuredata(df)),
  tar_target(cdf_dta, cdf_data(df)),
  tar_target(survival_gg, survivalgraph(cdf_dta)),
  tar_render(all_output, "estimates.Rmd"),
  tar_target(individuals,
             decisions |> 
               group_by(ID) |>
               tar_group(),
             iteration = "group"),
  tar_target(RP, 
             calculate_rp_statistics(individuals),
             pattern = map(individuals)),
  tar_target(pubpreffig_dta, publicprefdata(df))
)