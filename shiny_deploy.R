rm(list=ls(all=TRUE))

 library(shiny)

library(rsconnect)
library(DBI)
library(RSQLite)
 
library(tidyverse)
library(sf)
library(pool)

# Github-db information
# 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
con <- dbConnect(RMySQL::MySQL(),
                 dbname = "testdata",
                 host = ,
                 port = ,
                 user = "arelkhattabi",
                 password = "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")

#R shiny account information
rsconnect::setAccountInfo(name='arelkhattabi',
                          token='4AA1206AECB4245FF4FDB02AE5DE0E52',
                          secret='bm/UJV1fykQLHVmglcgCem5sWl4DEZNzbG9tDQyn')




#prepare data and send to database 
mydb <- dbConnect(RSQLite::SQLite(), "my-db_indexes.sqlite") #initialize database
source("tract_changes.R")
dbListObjects(mydb)

dbSendQuery(mydb ,"CREATE INDEX index_1 ON testdata(state, MSA)") #index by state, msa


 
# runApp("tract_changes.R")
runApp()



# 
# setwd("/Volumes/Samsung_T5/research/training/shiny/tract_changes_app")
# tracts <- st_read("tracts.shp")
# runApp()
# 
# 
# 
# library(rsconnect)
# rsconnect::setAccountInfo(name='arelkhattabi',
#                           token='4AA1206AECB4245FF4FDB02AE5DE0E52',
#                           secret='bm/UJV1fykQLHVmglcgCem5sWl4DEZNzbG9tDQyn')
# 
# options(rsconnect.max.bundle.size=1393376578)
# rsconnect::configureApp("tract_changes_app", size="large")
# rsconnect::deployApp()
# 
# rsconnect::showLogs() 
# rsconnect::terminateApp("tract_changes_app")
