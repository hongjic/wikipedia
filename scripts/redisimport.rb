# consumer

require 'redis'
require 'bunny'
require 'json'
require 'byebug'

connection_config = ENV["RABBITMQ_BIGWIG_URL"]
conn = Bunny.new(connection_config)
conn.start

ch = conn.create_channel
q = ch.queue("wikipedia")
redis = Redis.new

begin
  q.subscribe(:block => true) do |delivery_info, properties, body|
    # body is the string sent by producer.
    request = JSON.parse body
    key = request["key"]
    value = request["value"]
    puts key
    redis.set key, value
  end
rescue Interrupt => _
  puts "Interrupt "
  conn.close
  exit(0)
end
