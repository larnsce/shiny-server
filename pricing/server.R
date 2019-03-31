


fd_feces <- 128 # median g/cap/day wet mass
fd_feces_dm <- 29 # median g/cap/day dry mass

# calculate moisture content of fresh feces

fd_feces_mc <- (fd_feces - fd_feces_dm) / fd_feces

fd_urine <- 1.42 # L/cap/day
fd_urine_dm <- 59 # g/cap/day

## calculate moisture content of excreta

fd_excreta_mc <- ((fd_urine * 1000 + fd_feces) - (fd_feces_dm + fd_urine_dm)) / (fd_urine * 1000 + fd_feces)

## excreta dry mass

fd_excreta_dm <- fd_feces_dm + fd_urine_dm

## capacity

op_capacity <- 18 # kg/hr DM

## pricing

price_usd_hr <- 50 # USD/hr

##

library(ggplot2)

#ggplot(data = data, mapping = aes(x = price, y = `USD/cap/day`)) +
#  geom_col()
#
#data <- tibble::tibble(
#  price = c("actual", "adjusted"),
#  `USD/cap/day` = c(0.24, 0.05)
#  ) 

#######



server <- function(input, output) {
  
  
  price_usd <- eventReactive(input$go, {
    
    input$price_usd_hr

  })
  
  capacity <- eventReactive(input$go, {
    
    input$op_capacity
    
  })
  
  
  data <- eventReactive(input$go, {
    
    tibble::tibble(
      price = c("actual", "adjusted"),
      `USD/cap/day` = c(
        round((price_usd_hr / op_capacity) * ((fd_feces_dm + fd_urine_dm) / 1000), 2),
        round((input$price_usd_hr / input$op_capacity) * ((fd_feces_dm + fd_urine_dm) / 1000), 2)
      ) 
    )
    
  })
  
  output$hist <- renderPlot({
    hist(rnorm(input$op_hours))
  })
  
  output$feedstock <- renderText({
    paste0(
      "The median wet mass production of feces per person is ", fd_feces, " g/cap/day, 
      with a median dry mass of ", fd_feces_dm, " g/cap/day. The resulting moisture content is ",
      round(fd_feces_mc * 100, 1), 
      "%. Median urine generation rates are estimated at ", 
      fd_urine, " L/cap/day or ", fd_urine * 1000, " g/cap/day with a dry solids content of ",
      fd_urine_dm, " g/cap/day. Therefore, one person produces ",
      fd_feces + fd_urine * 1000, " g of excreta (feces + urine) per day.",
      " This mixture has a moisture content of ",
      round(fd_excreta_mc * 100, 1), "%. The resulting dry mass is ",
      fd_feces_dm + fd_urine_dm, " g/cap/day."
    )
  })
  
  output$cost_cap <- renderText({
    paste0(
    "At an operating cost of ", price_usd_hr, " USD/hour and a capacity of ", 
    op_capacity, "kg/hr (dry mass), the cost per person and day is: ",
    round((price_usd_hr / op_capacity) * ((fd_feces_dm + fd_urine_dm) / 1000), 2),
    " USD/cap/day. "
  
    )
    
  })
  
  output$cost_cap_adj <- renderText({
    paste0(
      "At an operating cost of ", price_usd(), " USD/hour and a capacity of ", 
      capacity(), " kg/hr (dry mass), the cost per person and day is: ",
      round((price_usd() / capacity()) * ((fd_feces_dm + fd_urine_dm) / 1000), 2),
      " USD/cap/day. "
      
    )
    
  })
  
  output$compare_plot <- renderPlot({
    ggplot2::ggplot(data = data(), aes(x = price, y = `USD/cap/day`, fill = price)) +
      geom_col() +
      labs(x = "price category", y = "price [USD/cap/day]") +
      scale_y_continuous(breaks = seq(0, 1, 0.10), limits = c(0, 1)) +
      theme(panel.grid.minor = element_blank()) +
      theme_bw(base_size = 18)
  })

}

