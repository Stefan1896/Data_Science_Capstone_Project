Next Word Prediction
========================================================
author: Stefan Werner
date: 12/12/2019
autosize: true

The Task 
========================================================

This application was created for the final assignment of the Data Science Specialization from the Johns Hopkins University. The project was also sponsored by SwiftKey.

The task was to create a language prediction model based on data from news, twitter and blogs. The data can be found [here](https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip). The next word shall be predicted based on a number of previous words.

![img1](jhu.png) ![img2](coursera.jpg) 


Prediction algorithm  
========================================================

- For prediction, a [Katz's back-off model](https://en.wikipedia.org/wiki/Katz%27s_back-off_model) was used
- Therefore, the prediction is based on the frequency of previous words as found in the data as following. If there is no match in one step, the next step was done
  1. Return most frequent word in data following last 4 words of input
  2. Return most frequent word in data following last 3 words of input
  3. Return most frequent word in data following last 2 words of input
  4. Return most frequent word in data independently from other words
  

Prediction algorithm specification  
========================================================

- A **n-gram** in general is a contiguous sequence of n words from a given sample of text or speech
- The highest order n-grams in the model were fivegrams
- For every n-gram in the data, the frequency of its occurance was saved
- N-grams with frequency counts < 2 were deleted due to faster compuation
- Only 20% of the total dataset was used due to faster computation

The App
========================================================

- A [shiny App](https://swerner1896.shinyapps.io/Backoff_Prediction_Model/) was build to provide an interactive interface to use the prediction algorithm
- In addition to next word prediction, you can get information about common alternatives to the predicted next word 
- In another tab there is also information about the most common n-grams in the data

![app](app_example.png)




========================================================
&nbsp;

&nbsp;
# Thank you!
