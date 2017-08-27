require 'sinatra'
require 'redis'
require 'algorithms'
require 'json'
require './lib/commander'
require './lib/indexcaching'
require './lib/util'
require './lib/models/document'
require './lib/models/documentlist'
require './lib/models/operator'

# valid operators: "and", "or", "and not", "()" 
# there must be a "and" before "not"

include DocumentUtil

get '/' do
  "Hello World"
end

# parameters: command, start, number
get '/search' do
  @command = params[:command]
  start = params[:start].to_i
  number = params[:number].to_i
  document_list = Commander.instance.exec @command
  document_list.sort_documents_by_score 0, document_list.length - 1 if document_list.length > 0
  document_list.keep_part start, number
  document_list.get_document_infos
  @list = document_list.to_json_obj
  erb :search
end

get '/documents/:id' do
  id = params[:id].to_i
  keyword_list = params[:keywords]
  document = DocumentUtil::get_document_by_id id
  # st = exec "docker exec -it big_cray /usr/local/hadoop/bin/hadoop jar /usr/local/hadoop/testCloud9-0.0.1-SNAPSHOT.jar testCloud9.testCloud9 10002"
  document["content"] = DocumentUtil::mark_on_document document["content"], keyword_list
  document["content"] = DocumentUtil::mark_enter_on_document document["content"]
  @document = document
  erb :document
end