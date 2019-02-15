if(!require(plotly, warn.conflicts = FALSE)) {
  install.packages("plotly", repos = "http://cran.us.r-project.org")
}
args <- commandArgs(trailingOnly = TRUE)

data <- read.csv(file = args[1], header = TRUE, sep = ",")
data$timestamp <- as.POSIXct(data$timestamp, format = "%Y-%m-%dT%H:%M:%OS")

dropped_messages <- read.csv(file = args[2], header = TRUE, sep = ",")
dropped_messages$timestamp = as.POSIXct(dropped_messages$timestamp, format = "%Y-%m-%dT%H:%M:%OS")

title_size <- list(size = 16)

duration <- plot_ly(data, x = ~data$timestamp, y = ~data$duration, color = ~data$method, type = "scatter", mode = "markers", colors = "Dark2", legendgroup =~ data$method)
duration <- layout(duration, yaxis = list(title = "duration [ms]", titlefont = title_size), xaxis = list(title = "time"))

total_amount <- plot_ly(data, x = ~data$timestamp, y = ~data$total_sent, color = ~data$method, type = "scatter", mode = "markers", colors = "Dark2", legendgroup =~ data$method, showlegend = F)
total_amount <- layout(total_amount, yaxis = list(title = "total # of sent", titlefont = title_size), xaxis = list(title = "time"))

open_sent <- plot_ly(data, x = ~data$timestamp, y = ~data$open_sent, color = ~data$method, type = "scatter", mode = "markers", colors = "Dark2", legendgroup =~ data$method, showlegend = F)
open_sent <- layout(open_sent, yaxis = list(title = "open # of sent", titlefont = title_size), xaxis = list(title = "time", type = "date"))

dropped_msg <- plot_ly(dropped_messages, x = ~dropped_messages$timestamp, y = ~dropped_messages$count, type = "scatter", mode = "markers", colors = "Dark2", showlegend = F)
dropped_msg <- layout(dropped_msg, yaxis = list(title = "total # of dropped messages", titlefont = title_size), xaxis = list(title = "time"))

html <- subplot(duration, total_amount, open_sent, dropped_msg, shareX = TRUE, titleY = TRUE, nrows = 4)
htmlwidgets::saveWidget(html, args[3])
