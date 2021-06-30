# rm(list=ls(all=TRUE))
 
# library(tidycensus)
# library(gganimate)
 
 


 substrLeft <- function(x, n){
   substr(x, 1, nchar(x)-n)
 }
 
 
 
tract.files <- list.files(path="/Volumes/Samsung_T5/research/training/LTDB_Std_All_fullcount/",pattern="LTDB_Std*", full.names = T)
tract.all.years <- lapply(tract.files, function(x)
  read_csv(x) %>% 
    mutate(file = x) %>% 
    rename_at(.vars = vars(ends_with("0")),
              .funs = funs(substrLeft(.,2))) %>% 
    rename_at(vars(matches("^TRTID$")), function(x) "tractid") %>% 
    rename_with(tolower)
 )  
tract.all.years.df <- do.call(plyr::rbind.fill, lapply(tract.all.years, as.data.frame)) %>% 
  arrange(tractid)  %>% 
  # filter(str_detect(file,"2010")) %>% 
  mutate(
         # tractid = paste0("0",tractid),
         year = str_replace(basename(file), "LTDB_Std_",""),
         year = as.integer(as.character(str_replace(year, "_fullcount.csv",""))),
         state = iconv(state, "latin1", "UTF-8",sub=''),
         county = iconv(county, "latin1", "UTF-8",sub=''),
         ) %>% 
  arrange(tractid, year) %>% 
  mutate(count = nchar(tractid),
         tractid = ifelse(count==10, paste0("0",tractid),tractid)) %>% 
  select(tractid, state, county, pop, asian, year)


# tracts <- st_read("nhgis0039_shapefile_tl2010_us_tract_2010/US_tract_2010.shp")  
msa <-  st_read("/Volumes/Samsung_T5/research/training/LTDB_Std_All_fullcount/msa_geography/US_cbsa_2016.shp")  %>%
  rename(MSA=NAME, GEOIDMSA=GEOID)

dropbox <- "/Users/arelkhattabi/Dropbox/research_projects/water research data/AR CA Drought files/data files/CA tracts/"
tracts <- st_read(paste0(dropbox,"US_tract_2015.shp")) %>% 
  mutate(STATEFP=as.numeric(as.character(STATEFP)),
         COUNTYFP=as.numeric(as.character(COUNTYFP))) %>% 
  # filter(STATEFP==6) %>% 
  st_join(left=F,msa) %>%
  merge(tract.all.years.df, by.x="GEOID", by.y="tractid")  %>% 
  # st_simplify() %>% 
  select(-c(ends_with(".y"), ends_with(".x"), MEMI, LSAD, GEOIDMSA, CBSAFP, CSAFP, FUNCSTAT, NAME))   
  # st_write("tracts.shp", delete_layer=T) 

tracts_ca <- tracts %>% 
  filter(state=="CA") %>%  
  as.data.frame() %>% 
  select(-geometry) %>% 
  dbWriteTable(mydb, "tracts_ca", . , row.names = FALSE, overwrite =T)

tracts %>% 
  as.data.frame() %>% 
  select(-geometry) %>% 
  dbWriteTable(mydb, "testdata", . , row.names = FALSE, overwrite =T)

# dbWriteTable(mydb, "msa", msa , row.names = FALSE, overwrite =T)

 
# metdiv, placefp
  # st_write(tracts, "tracts.shp", delete_layer=T)
  # test <- st_read("tracts.shp")
 
 class(tracts)
# ggplot() + 
#   geom_sf(data = test) + 
#   ggtitle("Map of Tracts within MSAs") + 
#   coord_sf()
  
# tracts <- st_read(paste0(dropbox,"US_tract_2015.shp")) %>% 
#   mutate(STATEFP=as.numeric(as.character(STATEFP))) %>%
#   filter(STATEFP==6) %>%
#   filter(COUNTYFP=="001") %>%
#   fortify() %>% 
#   left_join(tract.all.years.df, by=c("GEOID"="tractid"))   %>% 
#   mutate(percent_asian = asian/pop*100) %>% 
#   ggplot() +
#   geom_sf(aes(fill=percent_asian))  +
#   scale_fill_gradient(low = "yellow",  high = "darkred")+ 
#   theme_minimal() +
#   guides(color = FALSE, size = FALSE) +
#   labs(fill = "Percent") +
#   theme(
#     legend.position = "right",
#     axis.title.y = element_blank(),
#     axis.text.y = element_blank(),
#     axis.title.x = element_blank(),
#     axis.text.x = element_blank(),
#     panel.grid.major = element_line(colour = "transparent"))  +
#   transition_states(file) +
#   labs(title = "Year: {closest_state}") 

