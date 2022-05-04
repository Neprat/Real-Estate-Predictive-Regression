# Real-Estate-Predictive-Regression

# Introduction
In this case study I will create an R Shiny application using a data set from the UCI Machine Learning Repository. I will look at a data frame that contains information about the market historical data of real estate, and then opening it in R. I will analyze the data set, determining what algorithm it uses! This topic is interesting to me because I want to learn more about ... I will then create a shiny app that performs a linear regression for the user selected independent variables.

# Part 1
The first major step of this case study was finding the data set to download. I chose to download one that went over the market historical data of real estate in valuation in Sindian District, New Taipei City, Taiwan. After downloading this data set from the UCI Machine Learning Repository,  I opened in R by using read_excel function from the readxl library. I also renamed the each column within the data frame to make it simpler to reference. I placed this excel file within the data folder.

# Part 2
The data frame is a regression data set, meaning that it contains a single response value Y, in this case being the house price of the unit area, and at least one predictor variable X that helps determine the output for Y. In this case, because there are multiple X variables, we can determine  that the Real Estate Data set is a Multivariate Regression. This mean that this data can be used to measure the degree to which the various independent variables and the house price of unit area are related to each other.

# Part 3
Since we are predicting a continuous outcome, we should start out by determining whether the regression is linear or logistic. Generally, in both types of problems, the input variables can be either continuous or discrete, and in this problem, the only discrete variable is X4. However, in linear regression, the variable being predicted is a continuous dependent variable, and in logistic regression, the variable being predicted is a categorial dependent variable. Because this problem is not a binary classification	problem with only a few different outcomes for the output Y, I concluded that this is a linear regression problem.

# Part 4
I then began to develop the shiny app by first importing the 
