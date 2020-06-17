#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse)
library(tidyquant)
library(timetk)
library(DT)
library(reticulate)
library(rtweet)
library(plotly)

source_python("get_stock_data.py")
source_python("predict.py")

ths <- tibble(stock = c("AAPL", "AMZN", "GOOG", "NFLX", "TSLA"),
              twitter = c("@apple", "@amazon", "@google", "@netflix", "@tesla"))


# Define UI for application that draws a histogram
ui <- fluidPage(
    
    # Application title
    titlePanel("Reticulated Stocks App"),
    
    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            selectInput("stock",
                      "Stock ticker symbol:",
                      selected = "AAPL",
                      choices = c("AAPL", "AMZN", "GOOG", "NFLX", "TSLA")),
            
            dateRangeInput("date",
                           "Date Range",
                           start = "2010-01-01",
                           end = Sys.Date()),
            
            numericInput("alpha",
                         "Alpha parameter for anomaly detection",
                         min = .01, 
                         max = .5, 
                         step = .01,
                         value = .05), 
            hr(),
            h2("Using R + Python together with reticulate"),
            p("This Shiny app includes elements running both R and Python together:"),
            tags$ul(
                tags$li("Python for retrieving and wrangling stock data"),
                tags$li("R for visualizing stock data"),
                tags$li("R for retrieving and wrangling Twitter data"),
                tags$li("Python for sentiment analysis of Twitter data")
            ),
            width = 4),
        
        # Show a plot of the generated distribution
        mainPanel(
            tabsetPanel(type = "tabs",
                        tabPanel("Summary",
                                 plotlyOutput("pricesPlot"),
                                 plotlyOutput("returnsPlot")),
                        tabPanel("Daily Return Anomalies",
                                 plotlyOutput("anomalyPlot"),
                                 dataTableOutput("anomalyTable")),
                        tabPanel("Sentiment",
                                 br(),
                                 htmlOutput("sentimentText"),
                                 hr(),
                                 dataTableOutput("tweetTable"))
            )
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    
    stockPrices <- reactive({
        py$prices %>% 
            rownames_to_column("date") %>% 
            mutate(date = as.Date(date)) %>% 
            pivot_longer(-date, "stock", values_to = "prices") %>% 
            filter(stock == input$stock) %>% 
            filter_by_time(date, input$date[1], input$date[2])
    })
    
    stockReturns <- reactive({
        py$returns %>% 
            rownames_to_column("date") %>% 
            mutate(date = as.Date(date)) %>% 
            pivot_longer(-date, "stock", values_to = "returns") %>% 
            filter(stock == input$stock) %>% 
            filter_by_time(date, input$date[1], input$date[2])
    })
    
    tweets <- reactive({
        search_tweets(filter(ths, stock == input$stock)$twitter, 10)
    })
    
    tweetSentiment <- reactive({
        scores <- map(tweets()$text, py$predict) %>% 
            map_dbl(list(2, 1))
        
        s <- tweets() %>% 
            mutate(score = scores) %>% 
            select(text, score) %>% 
            summarize(mean(score))
        
        return(paste0("\nAverage sentiment of last ", nrow(tweets()), " tweets is <b>", round(s[[1]]*100, 2), "</b> out of 100.\n"))
    })
    
    output$pricesPlot <- renderPlotly({
        stockPrices() %>%
            plot_time_series(date, prices, .smooth = FALSE,
                             .interactive = TRUE, .color_lab = "Year", .title = paste0(input$stock, " Daily Prices"))
    })
    
    output$returnsPlot <- renderPlotly({
        stockReturns() %>%
            plot_time_series(date, returns, .color_var = year(date),
                             .interactive = TRUE, .color_lab = "Year", .title = paste0(input$stock, " Daily Returns"))
    })
    
    output$anomalyPlot <- renderPlotly({
        stockReturns() %>% 
            plot_anomaly_diagnostics(date, returns, .interactive = TRUE, .alpha = input$alpha)
    })
    
    output$anomalyTable <- renderDataTable({
        stockReturns() %>% 
            tk_anomaly_diagnostics(date, returns) %>% 
            filter(anomaly == "Yes") %>% 
            select(date, observed, anomaly) %>% 
            arrange(-abs(observed))
    })
    
    output$sentimentText <- renderText({
        tweetSentiment()
    })
    
    output$tweetTable <- renderDataTable({
        tweets() %>% 
            select(created_at, text)
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
