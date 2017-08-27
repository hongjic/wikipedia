# producer

require 'redis'
require 'bunny'
require 'json'
require './lib/util'
require './lib/models/document'
require './lib/models/documentlist'
require 'byebug'

redis = Redis.new
conn = Bunny.new(ENV["RABBITMQ_BIGWIG_URL"])
conn.start
ch = conn.create_channel
q = ch.queue "wikipedia"

# path name generation
base_path = 'index/'
file_names = []
(97..122).each do |i|
  c = i.chr
  file_names.push base_path + c 
end
file_names.push base_path + 'other'
arr = []
t_start = Time.now.to_f
file_names.each do |filename|
  if File.exist? filename
    t_filestart = Time.now.to_f

    File.open(filename, 'r') do |file|
      while line = file.gets
        document_list = DocumentList.new
        document_list.deserialize line, true

        obj = {key: document_list.keyword, value: document_list.serialize_list}
        q.publish JSON.generate obj
      end
    end
    t_fileend = Time.now.to_f
    puts "#{filename} time: #{t_fileend - t_filestart}s"
    arr.push t_fileend - t_filestart
  end
end

sum = 0
arr.each { |ele| sum += ele }
sum2 = 0
arr.each { |ele| sum2 += ele*ele }
puts "average expect of the worst case: #{sum2/sum}s"