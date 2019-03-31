# 01-two-inputs

library(shiny)

ui <- fluidPage(
  
  tags$h3("Biogenic Refinery CBS - Pricing and Capacity"),
  
  tags$hr(),
  
  tags$h4("Operations and people served"),
  
  sliderInput(inputId = "op_hours", 
              label = "Choose hours of operation per day:", 
              value = 8, min = 0, max = 24, step = 1),
  sliderInput(inputId = "op_days", 
              label = "Choose days of operation per week:", 
              value = 5, min = 0, max = 7, step = 1),
  sliderInput(inputId = "op_weeks", 
              label = "Choose weeks of operation per year:", 
              value = 50, min = 0, max = 52, step = 1),
  sliderInput(inputId = "op_community", 
              label = "Choose number of people to serve:", 
              value = 8000, min = 0, max = 80000, step = 8000),
  
  tags$hr(),
  
  tags$h3("Assumptions - Feedstock Characteristics"),
  
  fluidRow(
    column(6,
           
           tags$p(textOutput("feedstock")),
           
           tags$hr(),
           
           tags$h3("Results - Cost per person and day"),
           
           tags$p(textOutput("cost_cap")),
           
           tags$p("None of the above set of parameters in 'Operations and people served'  
           has an impact on the cost per person and day. 
           Only decreasing the cost per hour or increasing the capacity of the Biogenic Refinery 
           could decrease the cost per person and day."),
           
           tags$p("Try it out yourself below."),
           
           tags$hr()
           
    )
  ),
  
  tags$h3("Make adjustments"),
  
  sliderInput(inputId = "price_usd_hr",
              label = "Adjust the price [USD/hr]",
              value = 50, min = 0, max = 100, step = 5),
  
  sliderInput(inputId = "op_capacity",
              label = "Adjust the operating capacity [kg/hr]:",
              value = 18, min = 0, max = 72, step = 9),
  
  tags$p(actionButton(inputId = "go",
                      label = "Update")),
  
  tags$p(
    tags$strong("Tip:"), 
    "Try operating cost of",
    tags$strong("20 USD/hr"),
    "and treatment capacity of",
    tags$strong("36 kg/hr.")
  ),
  
  
  fluidRow(
    column(6,
           
           tags$hr(),
           
           tags$h3("Results - After adjustments"),
           
           tags$p(textOutput("cost_cap_adj")),
           
           plotOutput("compare_plot")
           
    )
  )
)
