# header ------------------------------------------------------------------


# load libraries ----------------------------------------------------------

library(shiny)
library(shinydashboard)

# user interface ----------------------------------------------------------


header <- dashboardHeader(title = "Biomass Controls")
        
sidebar <- dashboardSidebar(
            
            sidebarMenu(
                menuItem("Overview", tabName = "dashboard", icon = icon("th-large")),
                menuItem("Analysis", tabName = "plots", icon = icon("bar-chart-o")),
                menuItem("Who is Biomass Controls?", icon = icon("external-link"), 
                         href = "https://www.biomasscontrols.com/")
            )
        )


# create tab items --------------------------------------------------------

## dashboard type layout
tab_dashboard <- tabItem(tabName = "dashboard",
                        
                        fluidRow(
                            
                            box(title = "Please select here:", status = "warning", solidHeader = TRUE, 
                                
                                dateInput(inputId = "date",
                                          label = "Pick a date.",
                                          value = Sys.Date() - 1,
                                          min = "2017-01-01",
                                          max = Sys.Date() - 1,
                                          weekstart = 1),
                                
                                selectInput(inputId = "gi", 
                                            label = "Pick a unit",
                                            choices = c(
                                                "GI#1 Putnam" = "GI#1", 
                                                "GI#2 Narsapur" = "GI#2", 
                                                "GI#3 Warangal" = "GI#3", 
                                                "GI#4 Wai" = "GI#4",                                             
                                                "GI#5 Putnam" = "GI#5",
                                                "GI#7 Putnam" = "GI#7",
                                                "GI Putnam" = "GI#Putnam"
                                                ))),
                            box(title = "Overview plot", status = "success", solidHeader = TRUE,
                                
                                plotOutput("bar")),
                            
                            box(title = "Overview data table", status = "success", solidHeader = TRUE, 
                                
                                tableOutput("table"))
                            )
                        )


## here we will have the heatmap
tab_plots <- tabItem(tabName = "plots",
                     
                     
                     fluidRow(
                         
                         column(width = 2,
                                
                                box(title = "Please select here:", status = "warning", solidHeader = TRUE, width = 12, 
                             
                             dateRangeInput(inputId = "daterange",
                                            label = "Pick a date range", 
                                            start = Sys.Date() - 60, 
                                            end = Sys.Date() - 1, 
                                            min = "2017-01-01",
                                            max = Sys.Date() - 1, 
                                            weekstart = 1), 
                             
                             selectInput(inputId = "gi2", 
                                         label = "Pick a unit",
                                         choices = c(
                                             "GI#1 Putnam" = "GI#1",
                                             "GI#2 Narsapur" = "GI#2", 
                                             "GI#3 Warangal" = "GI#3", 
                                             "GI#4 Wai" = "GI#4",
                                             "GI#5 Putnam" = "GI#5",
                                             "GI#7 Putnam" = "GI#7",
                                             "GI Putnam" = "GI#Putnam"
                                             )))),
                         
                         column(width = 4,
                                
                                box(title = "Heatmap", status = "success", solidHeader = TRUE, width = 12, 
                             
                             plotOutput("heatmap", height = 700)
                             )
                         ),
                         
                         column(width = 6,
                                
                                box(title = "Timeseries", status = "success", solidHeader = TRUE, width = 12, 
                             
                             plotOutput("timeseries")

                         ),
                         
                            box(title = "Top three runs", status = "success", solidHeader = TRUE, width = 12,
                             
                             tableOutput("table2"))
                         )
                         )
                     )



## bring all items together
# tab_items <- tabItems(tabItem() tab_dashboard, tab_plots)


# make body ---------------------------------------------------------------

body <- dashboardBody(
    tags$head(includeScript("google-analytics.js")), 
    tabItems(
        tab_dashboard,
        tab_plots
    )
    )

# build the page ----------------------------------------------------------

shinyUI(
    dashboardPage(
        header, sidebar, body, skin = "green",
        )
)
    
    
