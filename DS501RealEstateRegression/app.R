#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
library(shiny)
library(shinyWidgets)
library(shinydashboard)
library(shinycssloaders)
library(DT)
library(ggplot2)
library(ggpubr)
library(stargazer)
library(corrplot)
library(recipes)
library(dplyr)
library(tidyr)
library(readxl)
library(parsnip)
library(rsconnect)
RealEstateExcel <- read_excel("data/Real estate valuation data set.xlsx") 
RealEstateDataset <- data.frame(RealEstateExcel)
names(RealEstateDataset) <- c("Number","X1","X2","X3","X4","X5","X6","Y")
NewEstateDataset <- RealEstateDataset[-c(1,6,7)]
RealEstateDataset <- RealEstateDataset[-c(1)]

AttributeChoices <- c("X1","X2","X3","X4")
DependentChoice <- c("Y")

ui = fluidPage(
  titlePanel("Douglas Koethe Regression App"),
  navbarPage("R Shiny Regression App",
             tabPanel("Welcome",
                      icon=icon("door-open"),
                      fluidPage(
                                h1("Welcome to the Real Estate Shiny Dashboard!"),
                                p("To see the market historical data of real estate in valuation in Sindian District, New Taipei City, Taiwan, please switch over to the Data Frame tab. You can see a summary of the data in the Data Frame Summary tab."),
                                p("To look at the correlation between variables, please switch to the Plot tab."),
                                p("To perform a regression analysis, please switch to Regression tab, and choose Y for the dependent variable. After that, you can choose one or more independent varibles to obtain a regression analysis."),
                                p("By choosing different inputs and outputs in the Regression tab, the Scatter Plot can be modified in the Scatter Plot tab. However, it only works if only one independent variable is selected."),
                                p("By choosing different inputs and outputs in the Regression tab, the Predicted value for the dependent variable can be changed. We can see how it compares to the original dependent value in the Prediction tab."),
                                br(),
                                h4("The inputs in the Real Estate Data Frame are as follows:"),
                                p("X1=the transaction date (for example, 2013.250=2013 March, 2013.500=2013 June, etc.)"),
                                p("X2=the house age (unit: year)"),
                                p("X3=the distance to the nearest MRT station (unit: meter)"),
                                p("X4=the number of convenience stores in the living circle on foot (integer)"),
                                p("X5=the geographic coordinate, latitude. (unit: degree)"),
                                p("X6=the geographic coordinate, longitude. (unit: degree)"),
                                br(),
                                h4("The output in the Real Estate Data Frame is as follows:"),
                                p("Y= house price of unit area (10000 New Taiwan Dollar/Ping, where Ping is a local unit, 1 Ping = 3.3 meter squared)"),
                                )),
             tabPanel("Data Frame",
                      icon=icon("table"),
                      DTOutput("Data")),
             tabPanel("Data Frame Summary",
                      icon=icon("table"),
                      verbatimTextOutput("Summ"),
                      verbatimTextOutput("SummMax")),
             tabPanel("Correlation Plot",
                      icon=icon("chart-bar"),
                      plotOutput("Correlation")),
             tabPanel("Regression",
                      icon=icon("calculator"),
                      selectInput(inputId="dependent", h3("Dependent Variable"),
                                  choices = as.list(DependentChoice)),
                      uiOutput("indep"),
                      verbatimTextOutput("RegOut")),
             tabPanel("Scatter Plot",
                      icon=icon("chart-bar"),
                      plotOutput("Scatter")),
             tabPanel("Prediction",
                      icon = icon("chart-bar"),
                      DTOutput("Prediction"),
                      plotOutput("PredictionPlot")
             ),
  ))

# Define server logic 
server <- function(input, output) {
  
  InputDataset <- reactive({
    RealEstateDataset
  })
  
  PredictedValues <- reactive({
    RealEstateDataset
  })
  
  output$Data <- renderDT(
    InputDataset())
  
  output$Summ <-
    renderPrint(
      stargazer(
        InputDataset(),
        type = "text",
        title = "Mean and Standard Deviation",
        digits = 4,
        out = "table1.txt"
      )
    )
  
  output$SummMax <- renderPrint(
  summary(InputDataset()))
  
  cormat <- reactive({
    round(cor(NewEstateDataset), 1)
  })
  
  output$Correlation <- renderPlot(corrplot(
      cormat(),
      method = "number",
      type = "lower",
      order = "original",
    ))
  
  output$Scatter <- renderPlot({
    req(input$indep)
    req(input$dependent)
    ggplot(data = NewEstateDataset, aes_string(x=input$indep, y=input$dependent))+ geom_point() + stat_cor(method = "pearson", label.x = 2, label.y = 0)  + labs(title = "Scatter Plot of Independent Variable VS Dependent Variable")
  })
 
  output$indep <- renderUI({
    selectInput(inputId = "indep", h3("Independent Variables"), 
                multiple = TRUE, choices = as.list(AttributeChoices))
  })

  recipe_formula <- reactive({
    req(input$indep)
    req(input$dependent)
    NewEstateDataset %>%
      recipe() %>%
      update_role(!!!input$dependent, new_role = "outcome") %>%
      update_role(!!!input$indep, new_role = "predictor") %>%
      prep() %>% 
      formula()
  })
  
  lm_reg <- reactive(
    lm(recipe_formula(),RealEstateDataset)
  )
  
  output$RegOut = renderPrint({
    summary(lm_reg())
  })
  
  
  output$PredictionPlot = renderPlot({
    plot(x = RealEstateDataset$Y,
         y = lm_reg()$fitted.values,      
         xlab = "Original Values",
         ylab = "Predicted Values",
         main = "Regression fits of Predicted Value vs Original Value")
  })
}

shinyApp(ui = ui, server = server)
deployApp()
