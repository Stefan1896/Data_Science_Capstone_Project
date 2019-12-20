library(shiny)
library(shinydashboard)
library(shinyWidgets)

sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem("Prediction", tabName = "prediction_tab", icon = icon("angle-double-right")),
    menuItem("Data", icon = icon("th"), tabName = "data"),
    menuItem("Data Exploration", icon = icon("search"), badgeLabel = "link", badgeColor = "green", 
              href = "http://rpubs.com/swerner1896/561739"),
    menuItem("Presentation", icon = icon("file-powerpoint"), badgeLabel = "link", badgeColor = "green", 
             href = "http://rpubs.com/swerner1896/561701"),
    menuItem("Github", icon = icon("file-code-o"), badgeLabel = "link", badgeColor = "green", 
             href = "https://github.com/Stefan1896/Data_Science_Capstone_Project")
  )
)

body <- dashboardBody(
  chooseSliderSkin("Flat"),
  tabItems(
    tabItem(tabName = "prediction_tab",
            fluidRow(
              br(),
              column(width = 12, offset = 2, box(
                status = "warning",
                title = HTML('<span class="fa-stack fa-lg" style="color:#F9A602">
                                        <i class="fa fa-square fa-stack-2x"></i>
                                        <i class="fa fa-keyboard-o fa-inverse fa-stack-1x"></i>
                                        </span> <span style="font-weight:bold;font-size:20px">
                                          Type in a Phrase</span>'),
                width = 6,
                textInput("wordinput", label = "", value = ""),
                actionButton("goButton", "Go!"),
                h3(textOutput("prediction")),
                hr(),
                h5(textOutput("predictor"))
              )
              )
            ),
            fluidRow(
              br(),
              column(width = 12, offset = 0, box(
                status = "warning",
                title = HTML('<span class="fa-stack fa-lg" style="color:#F9A602">
                                        <i class="fa fa-square fa-stack-2x"></i>
                                        <i class="fa fa-chart-bar fa-inverse fa-stack-1x"></i>
                                        </span> <span style="font-weight:bold;font-size:20px">
                                          Common Alternatives</span>'),
                plotOutput("wordplot", height = "200px"),
                setSliderColor("#F9A602",1),
                sliderInput("slider", "max Number of Words shown:",
                            min = 1, max = 10,
                            value = 5),
                width = 4
                ),
                box(
                  title = HTML('<span class="fa-stack fa-lg" style="color:grey">
                                        <i class="fa fa-square fa-stack-2x"></i>
                                        <i class="fa fa-info fa-inverse fa-stack-1x"></i>
                                        </span> <span style="font-weight:bold;font-size:20px">
                                          Instructions</span>'),
                  width = 6,
                  h4(tags$b("Input")),
                  "Please enter any number of words in the box above to see which word will be predicted next. 
                  The app may take a few seconds to load the first prediction. In the graph on the left, you see the most 
                  common alternatives to the predicted word. If you want to change the number of words shown in 
                  the graph, just change the value in the slider.",
                  hr(),
                  "In the menu on the left, you can get more information about the data and the source code. Click on Data to see the 
                  most common n-grams in the dataset. The data used is derived from texts of news, twitter and blogs. Click on source code to be redirected to a github-page containing all the code and
                  calculations done"
                )
              )
            )
            
    ),
    
    tabItem(tabName = "data",
            h2("Most common n-grams by textsource"),
            selectInput("n_gram_size", "Select size of n-gram:",
                        c("5-gram" = "fivegram_textsource_top10",
                          "4-gram" = "fourgram_textsource_top10",
                          "3-gram" = "trigram_textsource_top10",
                          "2-gram" = "bigram_textsource_top10",
                          "1-gram" = "unigram_textsource_top10")),
            br(),
            br(),
            column(width = 12, plotOutput("ngramsplot", width = "80%"))
    )
  )
)

# Put them together into a dashboardPage
dashboardPage(
  skin = "yellow",
  dashboardHeader(title = "Next word prediction"),
  sidebar,
  body
)