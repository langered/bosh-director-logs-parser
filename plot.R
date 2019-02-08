args = commandArgs(trailingOnly=TRUE)

pdf(args[3])

data <- read.csv(file=args[1], header=TRUE, sep=",")
data$timestamp = strptime(data$timestamp, "%Y-%m-%dT%H:%M:%OS")

attach(mtcars)
par(mfrow=c(2,2))

timeDescription = sprintf("from=\"%s\"\nto=\"%s\"", data$timestamp[1], tail(data$timestamp, n=1))
plot(data$timestamp, data$duration, xlab=timeDescription, ylab='duration in ms')
plot(data$timestamp, data$total_sent, xlab=timeDescription, ylab='total sent')
plot(data$timestamp, data$open_sent, xlab=timeDescription, ylab='open sent')

dropped_messages <- read.csv(file=args[2], header=TRUE, sep=",")
dropped_messages$timestamp = strptime(dropped_messages$timestamp, "%Y-%m-%dT%H:%M:%OS")

timeDescriptionDroppedMessages = sprintf("from=\"%s\"\nto=\"%s\"", dropped_messages$timestamp[1], tail(dropped_messages$timestamp, n=1))

plot(dropped_messages$timestamp, dropped_messages$count, xlab=timeDescriptionDroppedMessages)

dev.off()