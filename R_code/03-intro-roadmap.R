## ---- echo=FALSE, eval=TRUE, fig.align="center"-------------------------------
library(visNetwork)
nodes <- data.frame(id = c("W", "A", "Y"))
nodes$label <- nodes$id
edges <- data.frame(from = c("W", "W", "A"), to = c("A", "Y", "Y"))
network <- visNetwork(nodes, edges, height = "300px", width = "200px") %>%
  visEdges(arrows = list(to = TRUE)) %>%
  visLayout(randomSeed = 25)
network


## ----load_washb_data_intro, message=FALSE, warning=FALSE----------------------
library(tidyverse)

# read in data
dat <- read_csv("https://raw.githubusercontent.com/tlverse/tlverse-data/master/wash-benefits/washb_data.csv")
dat


## ----skim_washb_data, results="asis", echo=FALSE------------------------------
library(knitr)
library(skimr)

# optionally disable sparkline graphs for PDF output
if (is_latex_output()) {
  kable(skim_no_sparks(dat), format = "latex")
} else if (is_html_output()) {
  skim(dat)
}

