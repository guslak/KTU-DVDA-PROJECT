library(shiny)
library(tidyverse)
library(h2o)
h2o.init()

# Define UI for application that draws a histogram
ui <- fluidPage(
  titlePanel("DVDA projektas"),
  
  sidebarLayout(sidebarPanel(fileInput("file", "Upload CSV file"),
      
      numericInput("amount_current_loan", 
                   "Current loan amount", 
                   value = 0, 
                   min = 0, 
                   max = 99999999, 
                   step = 1000),
      selectInput("term", 
                  "Loan term", 
                  c("short", "long"), 
                  "good"),
      numericInput("yearly_income", 
                   "Yearly income", 
                   value = 0, 
                   min = 0, 
                   max = 99999999, 
                   step = 200),
      sliderInput("bankruptcies",
                  "Bankruptcies", 
                  value = 0, 
                  min = 0, 
                  max = 50),
      numericInput("years_current_job", 
                   "Current job (years)", 
                   value = 1, 
                   min = 1, 
                   max = 20, 
                   step = 1),
      numericInput("monthly_debt", 
                   "Monthly debt", 
                   value = 0, 
                   min = 0, 
                   max = 99999999, 
                   step = 50),
      sliderInput("credit_problems", 
                   "Credit problems", 
                   value = 0, 
                   min = 0, 
                   max = 200, 
                   step = 1),
      actionButton("calculate_button", "Calculate"),
      br(),
      br(),
      a("Logout", href = "javascript:window.location.reload(true);")
    ),
     mainPanel(tabsetPanel(tabPanel("File", dataTableOutput("fileTable")),
      
      )
    )
  ),
  tags$style(HTML("
    #calculate_button { background-color: #9245A0; color: white;padding: 10px 50px;}

  "))
)

# Define server logic
server <- function(input, output) {
  model <- h2o.loadModel("C:/Users/lakom/Desktop/Magistras-DVDA/projektas/KTU-DVDA-PROJECT-main/project/4-model/my_best_automlmode_new")
  
  input_data <- eventReactive(input$calculate_button, {
    data <- data.frame(
      amount_current_loan = input$amount_current_loan,
      term = factor(input$term),
      yearly_income = input$yearly_income,
      bankruptcies = input$bankruptcies,
      years_current_job = input$years_current_job,
      monthly_debt = input$monthly_debt,
      credit_problems = input$credit_problems,
    )
    data.frame(column = names(data),value = unlist(data) )
  })
  
  output$inputTable <- renderTable({
    input_data()
  })
  
  prediction_data <- eventReactive(input$calculate_button, 
    {
    inputData <- data.frame(amount_current_loan = input$amount_current_loan,term = factor(input$term),
      yearly_income = input$yearly_income,
      bankruptcies = input$bankruptcies,
      years_current_job = input$years_current_job,
      monthly_debt = input$monthly_debt,
      credit_problems = input$credit_problems,
    )
    
    predictions <- h2o.predict(model, as.h2o(inputData))
    as.data.frame(predictions)
  })
  
  output$predictionTable <- renderDataTable({
    prediction_data()
  })
  
  output$fileTable <- renderDataTable({
    req(input$file)
    test_data <- h2o.importFile(input$file$datapath)
    predictions <- h2o.predict(model, test_data)
    predictions %>%
      as_tibble() %>%
      mutate(id = row_number(), y = p0) %>%
      select(id, y)
  })
  
}

# Run the application 
shinyApp(ui = ui, server = server)