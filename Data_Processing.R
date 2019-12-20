library(readr)
library(tidyr)
library(tidytext)
library(lattice)
library(tibble)
library(ggplot2)
library(dplyr)
library(stringi)
library(stringr)
library(readtext)
library(data.table)
library(svMisc)
library(pbapply)

#clear workspace
rm(list = ls())

#turning of scientific notations for numbers
options(scipen=999)

if(!file.exists("./Data")){
  dir.create("./Data")
}
Url <- "https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip"

if(!file.exists("./Data/Coursera-SwiftKey.zip")){
  download.file(Url,destfile="./Data/Coursera-SwiftKey.zip",mode = "wb")
}

if(!file.exists("./Data/final")){
  unzip(zipfile="./Data/Coursera-SwiftKey.zip",exdir="./Data")
}

datapath <- paste0("./Data/final/en_US/",list.files("./Data/final/en_US/"))
datanames <- c("blogtext", "newstext", "twittertext")
data <- sapply(datapath, read_lines)
data <- sapply(data, function(x){stringi::stri_trans_general(x, "latin-ascii")})
names(data) <- datanames

#subsampling: 
set.seed(12233)
for (i in 1:3){
  assign(datanames[i], tibble(text = sample(data[[i]], length(data[[i]])*0.2)) %>%
           add_column(textsource = datanames[i])
  )
}

#no subsampling
#for(i in 1:3){
#  assign(datanames[i], tibble(text = data[[i]]) %>%
#            add_column(textsource = datanames[i])
#        )
#}


df <- bind_rows(blogtext, newstext, twittertext)

#Basig Cleaning
# Fix Contractions - get rid of contractions

fix.contractions <- function(doc) {
  doc <- gsub("won't", "will not", doc)
  doc <- gsub("can't", "can not", doc)
  doc <- gsub("n't", " not", doc)
  doc <- gsub("'ll", " will", doc)
  doc <- gsub("'re", " are", doc)
  doc <- gsub("'ve", " have", doc)
  doc <- gsub("'m", " am", doc)
  doc <- gsub("'d", " would", doc)
  # 's could be 'is' or could be possessive: it has no expansion
  doc <- gsub("'s", "", doc)
  return(doc)
}

# fix (expand) contractions
df$text <- sapply(df$text, fix.contractions)

# Remove Special Characters
removeSpecialChars <- function(x) gsub("[^a-zA-Z0-9 ]", " ", x)
df$text <- sapply(df$text, removeSpecialChars)

#create 100 subsets of the whole data with unigrams, bigrams, trigrams, fourgrams and fivegrams (subsets are used because of the large dataset)
n <- 100
nr <- nrow(df)
splitted_df <- split(df, rep(1:n, length.out = nrow(df), each = ceiling(nrow(df)/n)))
grams <- c("fivegramSubsets", "fourgramSubsets", "trigramSubsets", "bigramSubsets", "unigramSubsets")
sapply(paste0("./subsets/",grams), dir.create)
sapply(paste0("./subsets/", grams,"_by_textsource"), dir.create)

for(i in 1:n){
  progress(i)
  Sys.sleep(0.01)
  temp <- splitted_df[[i]] %>%
    unnest_tokens(predictor, text, token = "ngrams", n = 5)
  setDT(temp)
  sapply(grams[1:4], function(x){
    saveRDS(temp[,.N, by = .(textsource,predictor)], paste0("./",x,"_by_textsource/subset",i,".Rds"))
    temp <- separate(temp, predictor, into = c("predictor", "prediction"), sep = " (?=[^ ]+$)", extra = "merge") #split on last occurance of character pattern backslash
    temp_grouped <- temp[,.N, by = .(predictor,prediction)][order(-N)]
    saveRDS(temp_grouped, paste0("./subsets/",x,"/subset",i,".Rds"))
    temp <<- temp[,prediction:=NULL]
  })
  saveRDS(temp[,.N, by = .(textsource,predictor)], paste0("./unigramSubsets_by_textsource/subset",i,".Rds"))
  temp_grouped <-temp[,.N, by = .(predictor)][order(-N)]
  saveRDS(temp_grouped, paste0(".subsets/unigramSubsets/subset",i,".Rds"))
}


#combine subsets and store results in folder of shiny_app
rm(list = ls())
grams <- list("fivegram", "fourgram","trigram", "bigram", "unigram")

if(!file.exists("./Shiny_App")){
  dir.create("./Shiny_App")
}

#combine subsets and save grouped data without textsource information 
for(i in grams){
  filepaths <- list.files(paste0("./",i,"Subsets/"),full.names = TRUE)
  allsubsets <- pblapply(filepaths, readRDS) #use pblapply to show progress bar
  subsets_grouped <- rbindlist(allsubsets)
  if(paste0(i) != "unigram"){
    subsets_grouped <- subsets_grouped[, sum(N), by = .(predictor, prediction)][order(-V1)]
    saveRDS(subsets_grouped[V1 > 1], paste0(i,"_grouped","_20.Rds"))
  } else {
    subsets_grouped <- subsets_grouped[, sum(N), by = .(predictor)][order(-V1)]
    subsets_grouped[,prediction := predictor]
    subsets_grouped[,predictor := ""]
    saveRDS(subsets_grouped[V1 > 1], paste0("./Shiny_App/",i,"_grouped","_20.Rds"))
  }
}

#combine subsets and save top 10 ngrams by textsource information for graphs in app
for(i in grams){
  filepaths <- list.files(paste0("./",i,"Subsets_by_textsource/"),full.names = TRUE)
  allsubsets <- pblapply(filepaths, readRDS) #use pblapply to show progress bar
  subsets_grouped <- rbindlist(allsubsets)
    subsets_grouped <- subsets_grouped[, sum(N), by = .(textsource, predictor)][order(-V1)]
    subsets_grouped <- subsets_grouped %>%
      group_by(textsource) %>%
      slice(seq_len(8)) %>%
      ungroup() %>%
      arrange(textsource,V1) %>%
      mutate(row = row_number())
    saveRDS(subsets_grouped, paste0("./Shiny_App/", i,"top10_by_textsource_20.Rds"))
}

