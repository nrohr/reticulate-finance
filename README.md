# R + Python with `reticulate`

This repository contains some examples of how you can use R and Python together with the [`reticulate`](https://rstudio.github.io/reticulate/) R package. `reticulate` allows for interoperability between R and Python, allowing you to use Python code and functions in R scripts, R Markdown docs and R Notebooks, and Shiny applications.

This repo includes:

* _reticulate_rmarkdown.Rmd_ - an R Notebook showing how you can wrangle stock data with Python and visualize using `ggplot2` in R
* _app.R_ - a Shiny app that uses Python and R to wrangle and visualize stock data, and also runs sentiment analysis on Twitter data using the `rtweet` R package and the `spaCy` Python package for NLP
* other supporting scripts and artefacts used in the above examples

If you have any questions about these materials, please feel free to email [financial-services@rstudio.com](mailto:financial-services@rstudio.com).
