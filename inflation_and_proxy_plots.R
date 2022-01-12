library(cansim)
library(tidyverse)
library(lubridate)
library(janitor)

# compare inflation in Canada vs USA

cpi_can <- get_cansim_vector("v112593703", start_time = "1957-01-01", end_time="2021-10-01") %>%
  select(c("REF_DATE", "VALUE")) %>% 
  rename(cpi_can = VALUE)
cpi_can$REF_DATE <- ymd(cpi_can$REF_DATE)

cpi_us <- read_csv('us_cpi.csv') %>% 
  rename(cpi_us = CPILFESL, REF_DATE = DATE)

cpi_trend <- inner_join(cpi_can, cpi_us)

write_csv(cpi_trend, "cpi_trend.csv")


# compare expected inflation vs actual inflation 

exp_inf <- read_csv("us_infl_exp.csv")
act_inf <- read_csv("us_infl_actual.csv")

exp_inf <- exp_inf[exp_inf$T5YIFR != ".",]
act_inf <- act_inf[act_inf$T5YIE != ".",]
exp_inf$T5YIFR <- as.numeric(exp_inf$T5YIFR)
act_inf$T5YIE <- as.numeric(act_inf$T5YIE)

colnames(exp_inf)[2] <- "exp_inf"
colnames(act_inf)[2] <- "act_inf"

act_exp_inf <- inner_join(act_inf, exp_inf)

write_csv(act_exp_inf, "act_exp_inf.csv")
