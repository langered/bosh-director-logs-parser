data <- read.csv(file="messages.csv", header=TRUE, sep=",")
data$timestamp = strptime(data$timestamp, "%Y-%m-%dT%H:%M:%OS")
data$timestamp
plot(data, xaxt='n', las=2)
axis.POSIXct(1, at=data$timestamp, labels=format(data$timestamp, "%Y-%m-%dT%H:%M:%S"), las=2, cex.axis=0.5)
