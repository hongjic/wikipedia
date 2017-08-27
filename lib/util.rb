module DocumentUtil
  def get_requestids document_list, start, number
    id_list = []
    document_list.documents[start, number].each { |document| id_list.push document.id }
    id_list
  end


  def load_documents id_list
    threads = []
    id_list.each do |id|
      threads << Thread.new {exec("docker exec -it big_cray /usr/local/hadoop/bin/hadoop jar /usr/local/hadoop/testCloud9-0.0.1-SNAPSHOT.jar testCloud9.testCloud9 10002 >> #{id}.txt") }
    end  
    threads.each {|thread| thread.join}
  end

  def get_document_by_id id
    document = `docker exec -it big_cray /usr/local/hadoop/bin/hadoop jar /usr/local/hadoop/testCloud9-0.0.1-SNAPSHOT.jar testCloud9.testCloud9 #{id}`
    i1 = document.index "====="
    document = document[i1 + 7, document.length]

    i2 = document.index ":"
    document_id = document[0, i2].to_i
    i3 = document.index "\n"
    document_name = document[i2 + 2, i3 - i2 - 2]
    document_content = document[i3 + 1, document.length]
    result = {}
    result.store "id", document_id
    result.store "name", document_name
    result.store "content", document_content
    result
  end

  def mark_on_document document, keyword_list
    keyword_list.each do |keyword|
      document = document.gsub(/(?<foo>#{keyword})/i, '<b>\k<foo></b>')
    end
    document
  end

  def mark_enter_on_document document
    document = document.gsub("\n", "</br>")
  end
end