library(tidyverse)
library(cansim)
library(lubridate)

can_inf <- get_cansim_vector("v108785713", start_time = "2017-01-03", end_time="2021-11-11")%>% 
  select(c("REF_DATE", "val_norm"))  
dat <- read_csv('us_inf_monthly.csv')

can_inf$REF_DATE <- ymd(can_inf$REF_DATE)
us_can <- can_inf %>% inner_join(dat, by = c('REF_DATE' = 'DATE'))

ggplot(data = us_can) +
  geom_line(aes(x = REF_DATE, y = val_norm), color = "red") +
  geom_line(aes(x = REF_DATE, T10YIEM), color = "green")
