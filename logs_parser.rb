#!/usr/bin/env ruby

require 'time'

SENT_REGEX = /., \[(.*) #[0-9]*\].*(SENT).*reply_to":"(.*?)"/
RECEIVED_REGEX = /., \[(.*) #[0-9]*\].*(RECEIVED): (.*?) .*/
DATETIME_FORMAT = "%FT%H:%M:%S.%L"

messages = {}
dropped_messages = {}
open_sent = 0
total_sent = 0
total_received = 0

File.readlines('task.debug').each do |line|
  matches = line.match(SENT_REGEX) || line.match(RECEIVED_REGEX)

  if matches
    time = Time.parse(matches[1])
    type = matches[2]
    subject = matches[3]

    if type == "SENT"
      total_sent += 1
      open_sent += 1

      messages[subject] = { timestamp: time }
      messages[subject][:req_id] = subject
      messages[subject][:total_sent] = total_sent
      messages[subject][:open_sent] = open_sent
    #received
    else
      unless messages[subject].nil?
        if messages[subject][:duration] == nil
          open_sent -= 1
          total_received += 1
        end
        messages[subject][:duration] = ((time - messages[subject][:timestamp]) * 1000).to_i
        messages[subject][:total_received] = total_received
      end
    end
  end

end

file = File.open("messages.csv", 'w')
file.write "req_id,timestamp,duration,total_sent,open_sent\n"

messages.values.each do |elem|
  if elem[:duration]
    file.write "#{elem[:req_id]},#{elem[:timestamp].strftime(DATETIME_FORMAT)},#{elem[:duration]},#{elem[:total_sent]},#{elem[:open_sent]}\n"
  else
    dropped_messages[elem[:timestamp]] ||= 0
    dropped_messages[elem[:timestamp]] += 1
  end
end

file_dropped = File.open("dropped_messages.csv", 'w')
file_dropped.write "timestamp,count\n"

dropped_messages.each do |key, value|
  file_dropped.write "#{key.strftime(DATETIME_FORMAT)},#{value}\n"
end
