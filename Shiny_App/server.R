library(shiny)
library(data.table)
library(stringr)
library(ggplot2)
library(gplots)

fivegram_grouped <- readRDS("fivegram_grouped_20.Rds")
fourgram_grouped <- readRDS("fourgram_grouped_20.Rds")
trigram_grouped <- readRDS("trigram_grouped_20.Rds")
bigram_grouped <- readRDS("bigram_grouped_20.Rds")
unigram_grouped <- readRDS("unigram_grouped_20.Rds")

fivegram_textsource_top10 <- readRDS("fivegramtop10_by_textsource_20.Rds")
fourgram_textsource_top10 <- readRDS("fourgramtop10_by_textsource_20.Rds")
trigram_textsource_top10 <- readRDS("trigramtop10_by_textsource_20.Rds")
bigram_textsource_top10 <- readRDS("bigramtop10_by_textsource_20.Rds")
unigram_textsource_top10 <- readRDS("unigramtop10_by_textsource_20.Rds")


fivegram_model <- function(words){
  words <- tolower(words)
  number_words <- length(unlist(strsplit(words, " ")))
  splitted_words <- unlist(strsplit(words, " "))
  if(number_words > 4){words <- str_c(splitted_words[(number_words-3):number_words], collapse = " ")}
  if(nrow(fivegram_grouped[predictor == words]) > 0){
    head(fivegram_grouped[predictor == words, .(predictor,prediction)],1)
  } else if(nrow(fourgram_grouped[predictor == str_c(rev(rev(splitted_words)[1:3]),collapse = " ")]) > 0){
    head(fourgram_grouped[predictor == str_c(rev(rev(splitted_words)[1:3]),collapse = " "), .(predictor,prediction)],1)
  } else if(nrow(trigram_grouped[predictor == str_c(rev(rev(splitted_words)[1:2]), collapse = " ")]) > 0){
    head(trigram_grouped[predictor == str_c(rev(rev(splitted_words)[1:2]), collapse = " "), .(predictor,prediction)],1)
  } else if(nrow(bigram_grouped[predictor== rev(splitted_words)[1]]) > 0){
    head(bigram_grouped[predictor== rev(splitted_words)[1],.(predictor,prediction)],1)
  } else{
    (head(unigram_grouped[,.(predictor, prediction)],1))
  }
}

plot_alternatives <- function(predictorinput, n_alternatives){
  predictor_length <- length(unlist(strsplit(predictorinput, " ")))
  if(predictor_length == 4){
    df <- (head(fivegram_grouped[predictor == predictorinput, .(prediction, V1)],n_alternatives))
  } else if(predictor_length == 3){
    df <- (head(fourgram_grouped[predictor == predictorinput, .(prediction, V1)],n_alternatives))
  } else if(predictor_length == 2){
    df <- (head(trigram_grouped[predictor == predictorinput, .(prediction, V1)],n_alternatives))
  } else if(predictor_length == 1 & predictorinput != ""){
    df <- (head(bigram_grouped[predictor == predictorinput, .(prediction, V1)],n_alternatives))
  } else if(predictorinput == ""){
    df <- (head(unigram_grouped[predictor == "", .(prediction, V1)],n_alternatives))
  } 
  if(length(df$prediction) == 1){
    textplot("None", halig = "center", cex = 2, col = "red")
  } else {
  ggplot(df, aes(x= reorder(prediction, V1), y= V1)) +
    geom_bar(stat="identity", fill = "#F9A602") +
    theme(legend.position = "none", 
          plot.title = element_text(hjust = 0.5),
          panel.grid.major = element_blank()) +
    xlab("") + 
    ylab("Song Count") +
    ggtitle(paste0("Most frequently Words following: ", "\"",predictorinput,"\"")) +
    coord_flip() +
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
          panel.background = element_blank(), axis.line = element_blank(),
          axis.title.x=element_blank(),
          axis.text.x=element_blank(),
          axis.ticks.x=element_blank(),
          axis.ticks.y=element_blank(),
          axis.text.y=element_text(size = 14))
  }
}

theme_graphs <- function() 
{
  theme(plot.title = element_text(hjust = 0.5),
        axis.text.x = element_blank(), 
        axis.ticks = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        legend.position = "none")
}

colfunc <- colorRampPalette(c("#FDEECA", "#F9A602"))

plot_ngrams <- function(ngram_data){
  ngram_data %>%
  ggplot(aes(row, V1, fill = textsource)) +
  geom_col(show.legend = NULL) +
  labs(x = NULL, y = "Count") + 
  theme_classic(base_size = 12) +
  facet_wrap(~textsource, scales = "free") +
  scale_x_continuous(  
    breaks = ngram_data$row, 
    labels = ngram_data$predictor) +
  coord_flip() +
  theme(plot.title = element_text(lineheight=.8, face="bold")) +
  scale_fill_manual(values = colfunc(3))   
}


shinyServer(
  function(input, output) {
    model <- eventReactive(input$goButton, {
      fivegram_model(input$wordinput)
    })
    output$text <- renderPrint({"Prediction:"})
    output$prediction <- renderPrint({
      cat(paste("Prediction:", model()$prediction))
    })
    output$predictor <- renderPrint({
      cat(paste("Words used for Prediction:", model()$predictor))
    })
    output$wordplot <- renderPlot({
      plot_alternatives(model()$predictor, input$slider)
    })
    output$ngramsplot <- renderPlot({
      plot_ngrams(get(input$n_gram_size))
    })
  }
)

