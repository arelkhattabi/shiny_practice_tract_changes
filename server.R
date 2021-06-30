library(shiny)
library(dplyr)
library(sf)
 

function(input, output, session) {
  # Introduce reactive expression for each calculated value
  selected <- reactive({
    mydb <- dbConnect(RSQLite::SQLite(), "my-db_indexes.sqlite")
    on.exit(dbDisconnect(mydb), add = TRUE)
    dbGetQuery(mydb, paste0(
      "SELECT * FROM data;"))   %>% 
      arrange(state, year) %>%
      filter(year==input$year) %>%
      filter(MSA==input$MSA) %>%
      mutate(percent_asian = asian/pop*100,
             county = str_replace(county," County",""))  %>% 
      left_join(st_as_sf(maps::map("county",fill=TRUE,plot=FALSE)) %>% 
                  mutate(countystate = str_to_title(str_split_fixed(ID,",",2)[,1]),
                         county = str_to_title(str_split_fixed(ID,",",2)[,2]),
                         state_abb = state.abb[match(countystate,state.name)]), 
                by=c("state"="state_abb","county"="county")) %>% 
      st_as_sf() %>% 
      fortify()
    
    # tracts  %>% 
    #   arrange(MSA, year) %>%
    #   filter(year==input$year) %>% 
    #   # filter(state==input$state) %>%
    #   filter(MSA==input$MSA) %>% 
    #   mutate(percent_asian = asian/pop*100)  %>% 
    #   fortify()
  })
  
  
  output$plot <- renderPlot({
    selected() %>%
      ggplot() +
      geom_sf(aes(fill=percent_asian), color = NA)  +
      scale_fill_gradient(low = "yellow",  high = "darkred")+
      theme_minimal() +
      guides(color = FALSE, size = FALSE) +
      labs(fill = "Percent") +
      theme(
        legend.position = "right",
        axis.title.y = element_blank(),
        axis.text.y = element_blank(),
        axis.title.x = element_blank(),
        axis.text.x = element_blank(),
        panel.grid.major = element_line(colour = "transparent"))
  })
  
  output$table <- renderTable({
    head(selected() %>% 
           as.data.frame() %>% 
           select(state, GEOID, percent_asian))
  })
  
  
}