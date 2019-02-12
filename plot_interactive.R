library(plotly)

args <- commandArgs(trailingOnly = TRUE) #c("/Users/cpi/scratch/bosh-director-logs-parser/messages.csv", "/Users/cpi/scratch/bosh-director-logs-parser/dropped_messages.csv", "/Users/cpi/scratch/bosh-director-logs-parser/index.html")
  #

data <- read.csv(file = args[1], header = TRUE, sep = ",")
data$timestamp <- as.POSIXct(data$timestamp, format = "%Y-%m-%dT%H:%M:%OS")

dropped_messages <- read.csv(file = args[2], header = TRUE, sep = ",")
dropped_messages$timestamp = as.POSIXct(dropped_messages$timestamp, format = "%Y-%m-%dT%H:%M:%OS")

dropped_msg <- plot_ly(dropped_messages, x = ~dropped_messages$timestamp, y = ~dropped_messages$count, type = "bar", showlegend = F)
dropped_msg <- layout(dropped_msg, yaxis = list(title = "# of dropped messages per 15s"), xaxis = list(title = "time"))

duration <- plot_ly(data, x = ~data$timestamp, y = ~data$duration, color = ~data$method, type = "scatter", mode = "markers", legendgroup =~ data$method)
duration <- layout(duration, yaxis = list(title = "duration [ms]"), xaxis = list(title = "time"))

total_amount <- plot_ly(data, x = ~data$timestamp, y = ~data$total_sent, color = ~data$method, type = "scatter", mode = "markers", legendgroup =~ data$method, showlegend = F)
total_amount <- layout(total_amount, yaxis = list(title = "total # of sent"), xaxis = list(title = "time"))

open_sent <- plot_ly(data, x = ~data$timestamp, y = ~data$open_sent, color = ~data$method, type = "scatter", mode = "markers", legendgroup =~ data$method, showlegend = F)
open_sent <- layout(open_sent, yaxis = list(title = "open # of sent"), xaxis = list(title = "time"))

html <- subplot(duration, total_amount, open_sent, dropped_msg, shareX = TRUE, titleY = TRUE, nrows = 4)
htmlwidgets::saveWidget(html, args[3])