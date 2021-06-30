library(shiny)
library(dplyr)
library(sf)

 
 
#  pool <-  dbPool(
#   drv = RMySQL::MySQL(),
#   dbname = "my-db_indexes.sqlite"
#   # host = "shiny-demo.csa7qlmguqrf.us-east-1.rds.amazonaws.com",
#   # username = "guest",
#   # password = "guest"
# )

fluidPage(
  h1("Example app"),
  sidebarLayout(
    sidebarPanel(
      # selectInput("demo", "Variable", names(tracts)),
      # selectInput("state", "State", choices=unique(tract.all.years.df$state)),
      selectInput("MSA", "MSA", choices=unique(dbGetQuery(mydb, 'select MSA from data'))),
      sliderInput("year", "Year", 1970, 2010, value= unique(dbGetQuery(mydb, 'select year from data')),
                  step=10, sep="",
                  animate=animationOptions(interval = 5000, loop = T))
    ),
    mainPanel(
      plotOutput("plot"),
      tableOutput("table")
    )
  )
)
