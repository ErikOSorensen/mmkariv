library(tidyverse)
process_background <- function(background) {
  background |> 
    dplyr::mutate(two_parents_HS = sjlabelled::zap_labels(mother2school) *
                    sjlabelled::zap_labels(father2school),
                  one_parent_college = pmax(motheruni,fatheruni),
                  country = sjlabelled::as_label(country),
                  iq = iq/26.0,
                  female = as.numeric(sex==2),
                  Tanzania = as.numeric( country=="Tanzania"))
}

process_decisions <- function(decisions) {
  decisions |> 
    # Drop the pilot data (ID<100)
    dplyr::filter(ID>100) |>
    dplyr::mutate(share_cheapest = if_else(YM>XM, Y/(X+Y), X/(X+Y))) |>
    dplyr::group_by(ID, Treatment) |>
    dplyr::summarize(mean_cheapest_asset = mean(share_cheapest)) |>
    mutate(High = as.numeric(Treatment==2))
}

clean_rectangular <- function(background, RP, decisions) {
  b_df <- process_background(background)
  d_df <- process_decisions(decisions)
  RP |> left_join(b_df) |> left_join(d_df) |>
    mutate( country_high = factor(ifelse(Tanzania!=1, "United States", 
                                 ifelse(Treatment==2, "Tanzania - high", "Tanzania - low")))) |>
    filter(!is.na(iq))
}

se <- function(x) {
  sd(x, na.rm=TRUE)/sqrt(length(x[!is.na(x)]))
}

figuredata <- function(df) {
  df |> 
    dplyr::select(country, CCEI_PQR, FOSD_PQR, EU_PQR, iq) |>
    gather(key="outcome", value="value", CCEI_PQR:iq, factor_key=TRUE) |>
    mutate(outcome_nm = fct_recode(outcome,
                                   "e*" = "CCEI_PQR",
                                   "e**" = "FOSD_PQR",
                                   "e***" = "EU_PQR"))  %>%
    group_by(outcome_nm) |>
    mutate(zvalue = scale(value),
           sd = sd(value)) |>
    group_by(country, outcome_nm) |>
    summarize(overall_sd = min(sd),
              mean = mean(value),
              zmean = mean(zvalue),
              se_mean = se(value),
              se_zmean = se(zvalue))
}

cdf_data <- function(df) {
  df |>   
    dplyr::select(country, CCEI_PQR, FOSD_PQR, EU_PQR, iq) %>%
    gather(key="outcome", value="value", CCEI_PQR:iq, factor_key=TRUE) %>%
    filter(!is.na(country)) %>%
    mutate(yfct=fct_recode(outcome,
                           "e*" = "CCEI_PQR",
                           "e**" = "FOSD_PQR",
                           "e***" = "EU_PQR"))
  
}


survivalgraph <- function(cdf_data) {
  s_df <- cdf_data |> group_by(country,yfct) |>
    mutate(S  = 1 - cume_dist(value),
           prop = cut(value, c(0,seq(0.6,1,0.1)))) %>%
    group_by(country, yfct, prop) %>%
    summarize(meanS = mean(S),
              maxS = max(S))
  s_df |> filter(prop != "(0,0.6]") |>
    filter(yfct !="IQ") |>
    mutate(interval_lower = fct_recode(prop,
                                       "0.6" = "(0.6,0.7]",
                                       "0.7" = "(0.7,0.8]",
                                       "0.8" = "(0.8,0.9]",
                                       "0.9" = "(0.9,1]"),
           yfct = fct_recode(yfct,
                             "A.           e*" = "e*",
                             "B.           e**"= "e**",
                             "C.           e***"="e***",
                             "D.           IQ"="iq")) %>%
    ggplot(aes(y=maxS, x=interval_lower, group=country, fill=country)) +
    geom_bar(stat='identity', position = position_dodge2()) +
    theme_minimal() +
    facet_wrap(. ~ yfct) + 
    theme( strip.text=element_text(hjust=0) ) +
    labs(x = "Critical value",
         y = "Fraction of subjects") 
}

calculate_rp_statistics <- function(d) {
  p <- t(cbind(1/d$XM,1/d$YM))
  x <- t(cbind(d$X, d$Y))
  pi <- matrix(c(1/2,1/2),2,1)
  egarp <- ccei_garp(p,x)
  fgarp <- ccei_fgarp(p,x,pi)
  eu <- ccei_eu(p, x, pi)
  tibble(ID = as.integer(d$ID[1]),
         CCEI_PQR = egarp,
         FOSD_PQR = fgarp,
         EU_PQR = eu)
}

