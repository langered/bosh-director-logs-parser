#!/usr/bin/env ruby

require 'time'
require 'optparse'

SENT_REGEX = /., \[(.*) #[0-9]*\].*(SENT).*"method":"(.*?)",.*reply_to":"(.*?)"/
RECEIVED_REGEX = /., \[(.*) #[0-9]*\].*(RECEIVED): (.*?) .*/

messages = {}
open_sent = {}
total_sent = 0
total_received = 0
dropped_messages = 0

options = {}

OptionParser.new do |opt|
  opt.banner = "Usage: \n logs_parser.rb [options] <absolute path to log file>"
  opt.on('--filter FILTER', 'Provide a regex to filter out NATS methods, e.g. \'ping|get_state\'' ) { |o| options[:filter] = o }
end.parse!

debug_file_path = ARGV[0]

File.readlines(debug_file_path).each do |line|
  case line
  when SENT_REGEX
    time = Time.parse($1)
    type = $2
    method = $3
    subject = $4

    unless options[:filter] && method.match(options[:filter])
      total_sent += 1
      open_sent[method] ||= 0
      open_sent[method] += 1
      messages[subject] = { req_id: subject,
                            timestamp: time,
                            total_sent: total_sent,
                            open_sent: open_sent[method],
                            method: method }
    end

  when RECEIVED_REGEX
    time = Time.parse($1)
    type = $2
    subject = $3

    unless messages[subject].nil? || options[:filter] && messages[subject][:method].match(options[:filter])
      raise error("Multiple 'RECEIVED' for the same NATS subject: #{messages[subject]}") if messages[subject][:duration]

      total_received += 1
      open_sent[messages[subject][:method]] -= 1
      messages[subject][:total_received] = total_received
      messages[subject][:open_sent] = open_sent[messages[subject][:method]]
      messages[subject][:duration] = ((time - messages[subject][:timestamp]) * 1000).to_i
    end
  end
end

file = File.open("messages.csv", 'w')
file.write "req_id,timestamp,duration,total_sent,open_sent,method\n"

file_dropped = File.open("dropped_messages.csv", 'w')
file_dropped.write "timestamp,count\n"

messages.values.each do |elem|
  if elem[:duration]
    file.write "#{elem[:req_id]},#{elem[:timestamp].iso8601(3)},#{elem[:duration]},#{elem[:total_sent]},#{elem[:open_sent]},#{elem[:method]}\n"
  else
    dropped_messages += 1
    file_dropped.write "#{elem[:timestamp].iso8601(3)},#{dropped_messages}\n"
  end
end

file.close
file_dropped.close

exec("Rscript plot_interactive.R messages.csv dropped_messages.csv #{debug_file_path}.html; open #{debug_file_path}.html")
