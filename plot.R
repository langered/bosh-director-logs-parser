args = commandArgs(trailingOnly=TRUE)

pdf(args[3])

data <- read.csv(file=args[1], header=TRUE, sep=",")
data$color="black"

data$color[data$method=="get_task"]="gray"
data$color[data$method=="get_state"]="red"
data$color[data$method=="update_settings"]="blue"
data$color[data$method=="drain"]="brown"
data$color[data$method=="start"]="green"
data$color[data$method=="stop"]="purple"
data$color[data$method=="apply"]="gold"
data$color[data$method=="run_script"]="deeppink"
data$color[data$method=="upload_blob"]="orange"

data$timestamp = strptime(data$timestamp, "%Y-%m-%dT%H:%M:%OS")

dropped_messages <- read.csv(file=args[2], header=TRUE, sep=",")
dropped_messages$timestamp = strptime(dropped_messages$timestamp, "%Y-%m-%dT%H:%M:%OS")

attach(mtcars)
par(mfrow=c(3,1))

timeDescription = sprintf("from=\"%s\" to=\"%s\"", data$timestamp[1], tail(data$timestamp, n=1))

plot(data$timestamp, data$duration, xlab=timeDescription, col=data$color, ylab='duration in ms', xaxt='n')
axis.POSIXct(1, data$timestamp, format="%H:%M:%OS")
abline(v = as.POSIXct(dropped_messages$timestamp), col="lightpink")

plot(data$timestamp, data$total_sent, xlab=timeDescription, col=data$color, ylab='total sent', xaxt='n')
axis.POSIXct(1, data$timestamp, format="%H:%M:%OS")
abline(v = as.POSIXct(dropped_messages$timestamp), col="lightpink")
plot(data$timestamp, data$open_sent, xlab=timeDescription, col=data$color, ylab='open sent', xaxt='n')
axis.POSIXct(1, data$timestamp, format="%H:%M:%OS")
abline(v = as.POSIXct(dropped_messages$timestamp), col="lightpink")

dev.off()