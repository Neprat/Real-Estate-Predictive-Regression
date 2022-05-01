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