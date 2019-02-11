#!/usr/bin/env ruby

require 'time'

#SENT_REGEX = /., \[(.*) #[0-9]*\].*(SENT).*reply_to":"(.*?)"/
SENT_REGEX = /., \[(.*) #[0-9]*\].*(SENT).*"method":"(.*?)",.*reply_to":"(.*?)"/
RECEIVED_REGEX = /., \[(.*) #[0-9]*\].*(RECEIVED): (.*?) .*/
#RECEIVED_REGEX = /., \[(.*) #[0-9]*\].(.).*(RECEIVED): (.*?) .*/
DATETIME_FORMAT = "%FT%H:%M:%S.%L"

messages = {}
dropped_messages = {}
open_sent = 0
total_sent = 0
total_received = 0

debug_file_path = ARGV[0]

File.readlines(debug_file_path).each do |line|
  matches = line.match(SENT_REGEX) || line.match(RECEIVED_REGEX)

  if matches
    if line.match(SENT_REGEX)
      time = Time.parse(matches[1])
      type = matches[2]
      method = matches[3]
      subject = matches[4]
    else
      time = Time.parse(matches[1])
      type = matches[2]
      method = 'not_ping'
      subject = matches[3]
    end

    if method != 'ping'
      if type == "SENT"
        total_sent += 1
        open_sent += 1

        messages[subject] = { req_id: subject,
            timestamp: time,
            total_sent: total_sent,
            open_sent: open_sent,
            method: method }
        #received
      else
        unless messages[subject].nil?
          # if messages[subject][:duration].nil?
          open_sent -= 1
          total_received += 1
          # end
          messages[subject][:duration] = ((time - messages[subject][:timestamp]) * 1000).to_i
          messages[subject][:total_received] = total_received
        end
      end
    end
  end

end

file = File.open("messages.csv", 'w')
file.write "req_id,timestamp,duration,total_sent,open_sent,method\n"

messages.values.each do |elem|
  if elem[:duration]
    file.write "#{elem[:req_id]},#{elem[:timestamp].strftime(DATETIME_FORMAT)},#{elem[:duration]},#{elem[:total_sent]},#{elem[:open_sent]},#{elem[:method]}\n"
  else
    dropped_messages[elem[:timestamp]] ||= 0
    dropped_messages[elem[:timestamp]] += 1
  end
end

file.close

file_dropped = File.open("dropped_messages.csv", 'w')
file_dropped.write "timestamp,count\n"

dropped_messages.each do |key, value|
  file_dropped.write "#{key.strftime(DATETIME_FORMAT)},#{value}\n"
end

file_dropped.close

exec("Rscript plot.R messages.csv dropped_messages.csv #{debug_file_path}.pdf")
