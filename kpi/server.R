# header ------------------------------------------------------------------

## app.R ##

# load libraries ----------------------------------------------------------

library(shiny)
library(shinydashboard)
library(tidyverse)
library(ggalt)
library(DBI)
library(RMySQL)
library(lubridate)

# load data ---------------------------------------------------------------

## for local development#
# kpi_db <- read_csv(file = here::here("kpi/data/bmc_kpi_score_database.csv")) %>% unique()

# for online deployment

kpi_db <- read_csv(file = "data/bmc_kpi_score_database.csv") %>% unique()

### filter out the firmware version

db_2 <- kpi_db %>% 
    select(-firmware_version) %>% 
    unique()

### get firmware version by day and GI

db_firmware <- kpi_db %>% 
    select(date, GI_name, firmware_version) 

### get dates with eight KPI scores

date_eight_scores <- db_2 %>% 
    group_by(date, GI_name) %>% count() %>% filter (n == 8) %>%
    .$date

##data_eight_scores_gi3 <- db_2 %>% 
#  filter(GI_name == "GI#3") %>% 
# group_by(date, GI_name) %>% count() %>% filter (n == 8) %>% 
#  .$date

### filter database to get data only for days with eight scores

db_complete <- db_2 %>% 
    filter(date %in% date_eight_scores)  ### only filtering by date is not enough
##filter(GI_name == "GI#1") # %>% 
##filter(date %in% data_eight_scores_gi3 | GI_name == "GI#1")

## calculate total daily score by GI and date

total_kpi_scores <- db_complete %>% 
    group_by(date, idIBC, GI_name) %>% 
    summarise(
        count = n(),
        total_kpi_score = sum(kpi_score)
    )


# server ------------------------------------------------------------------

shinyServer(function(input, output) {
    
    output$bar <- renderPlot({
        
        kpi_db %>% 
            
            ## input date from ui
            
            filter(date == input$date) %>% 
            
            ## input GI unit from ui
            
            filter(GI_name == input$gi) %>% 
            
            ## general code
            
            mutate(kpi_score == as.factor(kpi_score)) %>% 
            
            ## make plot
            
            ggplot(aes(x = KPI_name, y = kpi_score)) +
            #geom_point() +
            geom_lollipop(point.colour = "steelblue", point.size = 2) +
            coord_flip() +
            scale_y_continuous(breaks = seq(0, 10, 1), limits = c(0, 10)) +
            
            ## input date and GI into title
            
            labs(x = NULL, y = NULL,
                 title = paste("KPI scores for ", input$gi, " and ", input$date, ".", sep = ""),
                 subtitle = "Scores are shown on the x-axis and KPIs on the y-axis.",
                 caption="Data from https://kelvinapp.io/") +
            theme_minimal(base_family="Arial Narrow", base_size = 16) +
            theme(panel.grid.major.y = element_blank()) +
            theme(panel.grid.minor = element_blank()) +
            #theme(axis.line.x = element_line(color = "#2b2b2b", size = 1)) +
            theme(plot.title = element_text(face = "bold")) +
            theme(plot.subtitle = element_text(margin = margin(b = 10))) +
            theme(plot.caption = element_text(size = 8, margin = margin(t = 10))) +
            theme(axis.text.y = element_text(margin = margin(r = 0, l = 0)))
        
    })
    
    output$table <-  renderTable({
        
        kpi_db %>% 
            ## input date from ui
            
            filter(date == input$date) %>% 
            
            ## input GI unit from ui
            
            filter(GI_name == input$gi) %>% 
            
            
            select(KPI_name, result, unit, kpi_score, firmware_version) 
        
    })
    
    
    output$heatmap <- renderPlot({
        
        kpi_db %>%
            
            ### filter by GI
            
            filter(GI_name == input$gi2) %>% 
            
            ### filter by date_range
            
            filter(date >= input$daterange[1] & date <= input$daterange[2]) %>% 
            
            ### plot
            mutate(
                kpi_score = as.factor(kpi_score),
                date = as.factor(date),
                kpi_id = as.factor(kpi_id),
                GI_name = as.factor(GI_name)
            ) %>% 
            
            
            
            ggplot(aes(x = kpi_id, y = date, z = kpi_score)) +
            geom_tile(aes(fill = kpi_score)) +
            
            
            coord_fixed(ratio = 0.25) +
            
            scale_fill_brewer(name = "KPI score", type = "div", palette = "RdYlGn",
                              guide = guide_legend(direction = "horizontal", nrow = 1)) +
            labs(y = NULL, x = "KPI id",
                 title = "Key Performance Indicators: Daily scores",
                 subtitle = paste("Between ", input$daterange[1], " and ", input$daterange[2], " for ", input$gi2, ".", sep = "")) +
            
            #facet_wrap(~idIBC) +
            
            theme_minimal(base_family="Arial Narrow", base_size = 14) +
            theme(plot.title = element_text(face = "bold", size = 15)) +
            theme(plot.subtitle = element_text(margin = margin(b = 10), size = 13)) +
            theme(axis.text.y = element_text(margin = margin(r = 0, l = 0), size = 11)) +
            theme(axis.text.x = element_text(size = 12)) +
            guides(fill = guide_legend(keywidth = 0.7, keyheight = 0.7, direction = "horizontal", nrow = 1)) +
            theme(legend.position = "bottom")
        
        
    })
    
    output$timeseries <- renderPlot({
        
        total_kpi_scores %>% 
            
            ungroup() %>% 
            
            ### filter by GI
            
            filter(GI_name == input$gi2) %>% 
            
            ### filter by date_range
            
            filter(date >= input$daterange[1] & date <= input$daterange[2]) %>% 
            
            mutate(
                date = as.factor(date)
            ) %>% 
            
            
            
            ## plot
            
            ggplot(aes(x = date, y = total_kpi_score)) +
            scale_y_continuous(breaks = seq(0, 80, 10), limits = c(0, 80)) +
            #geom_hline(yintercept = mean(.$total_kpi_score), size = 0.5, color = "orange") +
            #geom_hline(yintercept = 80, size = 0.5, color = "darkgreen") +
            #geom_hline(yintercept = 40, size = 0.5, color = "yellow") +
            geom_lollipop(point.colour = "steelblue", point.size = 2) +
            labs(y = NULL, x = NULL,
                 title = "Total KPI scores",
                 subtitle = paste("Sum of daiy KPI scores between ", input$daterange[1], " and ", input$daterange[2], " for ", input$gi2, ".", sep = "")) +
            theme_minimal(base_family="Arial Narrow", base_size = 14) +
            theme(panel.grid.minor = element_blank()) +
            theme(panel.grid.major.x = element_blank()) +
            theme(plot.title = element_text(face = "bold", size = 15)) +
            theme(plot.subtitle = element_text(margin = margin(b = 10), size = 13)) +
            theme(axis.text.y = element_text(margin = margin(r = 0, l = 0), size = 12)) +
            theme(axis.text.x = element_text(size = 12, angle = 90, vjust = 0.5, hjust = 5))
        
        
    })
    
    output$table2 <- renderTable({
        
        total_kpi_scores %>% 
            ungroup() %>% 
            
            filter(GI_name == input$gi2) %>% 
            
            ### filter by date_range
            
            filter(date >= input$daterange[1] & date <= input$daterange[2]) %>% 
            
            arrange(desc(total_kpi_score)) %>% 
            slice(1:3) %>% 
            left_join(db_firmware) %>% 
            
            mutate(date = as.character(date)) %>% 
            
            unique()
        
    })
    
})


