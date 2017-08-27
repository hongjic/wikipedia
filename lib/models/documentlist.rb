require 'byebug'
require 'set'

class DocumentList

  attr_accessor :keyword
  attr_accessor :documents
  attr_accessor :length

  def self.build_from_redis key
    document_list = DocumentList.new
    document_list.keyword = [key]
    document_list.deserialize_list IndexManager.instance.get key
    document_list
  end

  def deserialize line, sort = false
    @keyword = [line[0, line.index("\t")]]
    deserialize_list line, sort
  end

  def deserialize_list line, sort = false
    if (line == nil)
      @length = 0
      @documents = Array.new
      return
    end
    arr = line.scan /[(][0-9\s,]+[)]/
    @documents = Array.new
    arr.each do |str| 
      document = Document.new
      document.deserialize str, @keyword[0]
      @documents.push document
    end
    sort_documents_by_id 0, arr.length - 1 if sort
    @length = arr.length
  end

  def serialize_list 
    str = String.new
    @documents.each { |document| str += document.serialize }
    str
  end

  # execute operation #{op} with #{other}
  # op.class == Operator
  # other.class == DocumentList
  # execute_and_not, execute_and, execute_or
  # return a new object
  def operate op, other
    instance_eval("#{op.to_method}(other)")
  end

  def sort_documents_by_score left, right
    mid = left + (right - left) / 2;
    pivot = @documents[mid] # a document
    pivot_score = pivot.score
    i = left
    j = right
    while (i <= j)
      while (@documents[i].score > pivot_score)
        i += 1
      end
      while (@documents[j].score < pivot_score)
        j -= 1
      end
      if (i <= j)
        tmp = @documents[i]
        @documents[i] = @documents[j]
        @documents[j] = tmp
        i += 1
        j -= 1
      end
    end
    sort_documents_by_score left, j if j > left
    sort_documents_by_score i, right if right > i
  end

  def keep_part start, number
    if start >= @length 
      @documents = Array.new
      @length = 0
    else
      @length = @length - start
      @length = number if number < @length
      @documents = @documents[start, @length]
    end
  end

  def to_json_obj
    obj = {}
    obj["keyword"] = @keyword
    obj["length"] = @length
    obj["documents"] = Array.new
    @documents.each { |document| obj["documents"].push document.to_json_obj }
    obj
  end

  def get_document_infos
    threads = []
    @documents.each do |document| 
      threads << Thread.new { document.get_info }
    end
    threads.each { |thread| thread.join }
    # @documents.each do |document|
    #   document.get_info
    # end
  end

  private

    def execute_and_not other
      otherid_set = Set.new
      other.documents.each { |document| otherid_set.add document.id }
      new_obj = DocumentList.new
      new_obj.keyword = @keyword - other.keyword
      new_obj.documents = Array.new
      @documents.each { |document| new_obj.documents.push document if !otherid_set.include? document.id }
      new_obj.length = new_obj.documents.length
      new_obj
    end

    def execute_and other
      new_obj = DocumentList.new
      new_obj.keyword = @keyword | other.keyword
      new_obj.documents = Array.new
      i = 0
      j = 0
      # two pointer
      while i < @documents.length && j < other.documents.length
        if @documents[i].id < other.documents[j].id
          i += 1
        elsif @documents[i].id > other.documents[j].id
          j += 1
        else
          new_obj.documents.push @documents[i].execute_and(other.documents[j])
          i += 1
          j += 1
        end
      end
      new_obj.length = new_obj.documents.length
      new_obj
    end

    def execute_or other
      new_obj = DocumentList.new
      new_obj.keyword = @keyword | other.keyword
      new_obj.documents = Array.new
      i = 0
      j = 0
      while i < @documents.length || j < other.documents.length
        if (i >= @documents.length || @documents[i].id > other.documents[j].id)
          new_obj.documents.push other.documents[j]
          j += 1
        elsif (j >= other.documents.length || @documents[i].id < other.documents[j].id)
          new_obj.documents.push @documents[i]
          i += 1
        else
          new_obj.documents.push @documents[i].execute_or(other.documents[j])
          i += 1
          j += 1
        end
      end
      new_obj.length = new_obj.documents.length
      new_obj
    end

    def sort_documents_by_id left, right
      mid = left + (right - left) / 2;
      pivot = @documents[mid] # a document
      pivot_id = pivot.id
      i = left
      j = right
      while (i <= j)
        while (@documents[i].id < pivot_id)
          i += 1
        end
        while (@documents[j].id > pivot_id)
          j -= 1
        end
        if (i <= j)
          tmp = @documents[i]
          @documents[i] = @documents[j]
          @documents[j] = tmp
          i += 1
          j -= 1
        end
      end
      sort_documents_by_id left, j if j > left
      sort_documents_by_id i, right if right > i
    end
end