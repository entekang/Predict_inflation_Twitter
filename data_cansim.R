library(cansim)
library(tidyverse)
library(lubridate)
library(janitor)
library(readxl)

gdp <- get_cansim_vector_for_latest_periods("v65201210", periods = 336) %>% 
  select(c("REF_DATE", "val_norm"))
cpi <- get_cansim_vector_for_latest_periods("v41690973", periods = 321) %>% 
  select(c("REF_DATE", "val_norm"))

##target rate, bank rate, short and long term bond rates are in DAILY. Need conversion to monthly ## 

target_rate <- get_cansim_vector("v39079", start_time = "1995-01-01", end_time="2020-10-20")%>% 
  select(c("REF_DATE", "val_norm")) 

bank_rate <- get_cansim_vector("v39078", start_time = "1995-01-01", end_time="2020-10-20")%>% 
  select(c("REF_DATE", "val_norm"))

short_bond_rate <- get_cansim_vector("v39059", start_time = "1995-01-01", end_time="2020-10-20")%>% 
  select(c("REF_DATE", "val_norm"))

long_bond_rate <- get_cansim_vector("v39062", start_time = "1995-01-01", end_time="2020-10-20")%>% 
  select(c("REF_DATE", "val_norm"))


######## DAILY DATA #######

# daily exchange rate 
exchange_rate_us <- get_cansim_vector("v111666248", start_time = "2017-01-03", end_time="2021-11-11")%>% 
  select(c("REF_DATE", "val_norm"))%>% 
  rename(us_exch_range = val_norm)

exchange_rate_china <- get_cansim_vector("v111666226", start_time = "2017-01-03", end_time="2021-11-11")%>% 
  select(c("REF_DATE", "val_norm"))%>% 
  rename(china_exch_range = val_norm)

# stock data (top market capitalizations)
stocks <- read_csv('ClosingPrice.csv')
colnames(stocks)[1] <- 'REF_DATE'

# Bitcoin (Ethereum)
crypto <- read_csv('ClosingPrice2.csv')
colnames(crypto)[1] <- 'REF_DATE'
crypto_clean <- crypto %>% select(-c("SOL1.USD.Close"))

# BoC target rate
target_rate <- get_cansim_vector("v39079", start_time = "2017-01-03", end_time="2021-11-11")%>% 
  select(c("REF_DATE", "val_norm"))%>% 
  rename(target_rate = val_norm)

short_bond_rate <- get_cansim_vector("v39059", start_time = "2017-01-03", end_time="2021-11-11")%>% 
  select(c("REF_DATE", "val_norm"))%>% 
  rename(short_bond_rate = val_norm)

long_bond_rate <- get_cansim_vector("v39062", start_time = "2017-01-03", end_time="2021-11-11")%>% 
  select(c("REF_DATE", "val_norm"))%>% 
  rename(long_bond_rate = val_norm)


# 30 yr us mortgage rate
mort_30_us <- read_csv('30_mortgage_us.csv')
colnames(mort_30_us) <- c("REF_DATE", "mort_30_yr")
mort_30_us <- mort_30_us[mort_30_us$mort_30_yr != '.',]
mort_30_us$mort_30_yr <- as.numeric(mort_30_us$mort_30_yr)

# Joining dfs
exchange_rate_china$REF_DATE <- ymd(exchange_rate_china$REF_DATE)
exchange_rate_us$REF_DATE <- ymd(exchange_rate_us$REF_DATE)
target_rate$REF_DATE <- ymd(target_rate$REF_DATE)
long_bond_rate$REF_DATE <- ymd(long_bond_rate$REF_DATE)
short_bond_rate$REF_DATE <- ymd(short_bond_rate$REF_DATE)


df_final_full <- inner_join(target_rate, short_bond_rate, by = "REF_DATE") %>% 
  inner_join(long_bond_rate, by = "REF_DATE") %>% 
  inner_join(exchange_rate_china, by = "REF_DATE") %>% 
  inner_join(exchange_rate_us, by = "REF_DATE") %>% 
  inner_join(crypto_clean, by = "REF_DATE") %>% 
  inner_join(stocks) %>% 
  inner_join(mort_30_us)

df_final_leftjoined <- inner_join(target_rate, short_bond_rate, by = "REF_DATE") %>% 
  inner_join(long_bond_rate, by = "REF_DATE") %>% 
  inner_join(exchange_rate_china, by = "REF_DATE") %>% 
  inner_join(exchange_rate_us, by = "REF_DATE") %>% 
  inner_join(crypto_clean, by = "REF_DATE") %>% 
  left_join(stocks) %>% 
  left_join(mort_30_us)

write_csv(df_final_full, "data_innerjoined.csv")
write_csv(df_final_leftjoined, "data_leftjoined.csv")

# google search counts 
searches <- read_excel('google_inf_count_daily.xlsx')
colnames(searches)[1] <- "REF_DATE"

# freight index
freight <- read_excel('scfi.xlsx')
colnames(freight)[1] <- "REF_DATE"

# combine everything together (all predictors)
final_data <- read_csv('data_leftjoined.csv')

dset <- final_data %>% 
  inner_join(searches) %>% 
  inner_join(freight)

# load the target variable (us inflation expectations)
inf <- read_csv('act_exp_inf.csv') %>%
  select(c("DATE", "act_inf")) %>% 
  rename('REF_DATE' = 'DATE')

data_combined <- dset %>% 
  inner_join(inf)

write_csv(data_combined, 'finalized_data.csv')

# read in cleaned data (final version)
nomissing_data <- read_csv('data_finalized_nomissing.csv')

# add in metals, commodities
gold <- read_csv('gold.csv')
gold$Date <- mdy(gold$Date)

cocoa <- read_excel('cocoa.xlsx')
cocoa$date <- ymd(cocoa$date)

coffee <- read_csv('coffee.csv')
coffee$Date <- mdy(coffee$Date)

copper <- read_csv('copper.csv')
copper$Date <- mdy(copper$Date)

crude_oil <- read_csv('crude_oil.csv')
crude_oil$Date <- mdy(crude_oil$Date)

natural_gas <- read_csv('natural_gas.csv')
natural_gas$Date <- mdy(natural_gas$Date)

palladium <- read_csv('palladium.csv')
palladium$Date <- mdy(palladium$Date)

silver <- read_csv('silver.csv')
silver$Date <- mdy(silver$Date)

soybean_meal <- read_csv('soybean_meal.csv')
soybean_meal$Date <- mdy(soybean_meal$Date)

nomissing_data <- nomissing_data %>% inner_join(gold) %>% 
  inner_join(cocoa, by = c("Date" = "date")) %>% 
  inner_join(coffee) %>% inner_join(copper) %>% 
  inner_join(crude_oil) %>% inner_join(natural_gas) %>% 
  inner_join(palladium) %>% inner_join(silver) %>% 
  inner_join(soybean_meal)

write_csv(nomissing_data, 'data_finalized_nomissing_v2.csv')


# changing expected to actual inflation 

df <- read_csv('data_finalized_nomissing_v2.csv')
inf <- read_csv('act_exp_inf.csv') %>%
  select(c("DATE", "act_inf")) %>% 
  rename('REF_DATE' = 'DATE')
df_final <- df %>% inner_join(inf, by = c('Date' = 'REF_DATE'))

write_csv(df_final, 'data_final_v.csv')

# adding in macro variables in daily format 
macro <- read_excel('daily_macro.xlsx') %>% 
  select(-c("...1"))
macro$Date <- ymd(macro$Date)

data_final_v <- read_csv('data_final_v.csv')

data_final_v <- data_final_v %>% inner_join(macro) %>% select(-c('X1'))

write_csv(data_final_v, 'data_final_v2.csv')

# TURNING ML MODEL TO BE MORE 'CROSSSECTIONAL'. NOT FOCUSING ON DATES