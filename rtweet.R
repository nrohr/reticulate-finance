library(rtweet)
library(tidyverse)
library(reticulate)

source_python("predict.py")

tweets <- search_tweets("AAPL", 10)

map(tweets$text, py$predict) %>% 
map_dbl(list(2, 1))

s <- tweets %>% 
  mutate(score = scores) %>% 
  select(text, score) %>% 
  summarize(mean(score))

paste0("Average sentiment of last 10 tweets is ", round(s[[1]]*100, 2), " out of 100.")
