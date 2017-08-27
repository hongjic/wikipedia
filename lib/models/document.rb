
class Document

  attr_accessor :id
  attr_accessor :score
  attr_accessor :positions
  attr_accessor :info

  def initialize
    @positions = Hash.new
  end

  def deserialize line, keyword
    line = line[1, line.length - 2]

    @id = line[0, line.index(',')].to_i
    line = line[line.index(' ') + 1, line.length]
    deserialize_positions line, keyword
  end

  def deserialize_positions line, keyword
    first_positions = Array.new
    line.split(' ').each { |pos| first_positions.push pos.to_i }
    @score = first_positions.length
    @positions.store keyword, first_positions
  end

  def serialize 
    st = "#{@id},#{@score}"
    @positions.values[0].each { |pos| st += " #{pos}"}
    st = '(' + st + ')'
    st
  end

  # return new obj
  def execute_and other
    new_obj = Document.new
    new_obj.id = @id
    new_obj.score = @score + other.score
    new_obj.positions = @positions.merge other.positions
    new_obj
  end

  # return new obj
  def execute_or other
    new_obj = Document.new
    new_obj.id = @id
    new_obj.score = @score + other.score
    new_obj.positions = @positions.merge other.positions
    new_obj
  end

  # get 
  def get_info
    info = DocumentUtil::get_document_by_id @id
    summary = ""
    @positions.keys.each do |keyword|
      index = info["content"].index /#{keyword}/i
      key_len = keyword.length
      summary += "...#{info["content"][index - 20, 20]}<b>#{info["content"][index, key_len]}</b>#{info["content"][index + key_len, 20]}..."
    end
    @info = {}
    @info.store "id", info["id"]
    @info.store "name", info["name"]
    @info.store "summary", summary.gsub("\n", " ")
  end

  def to_json_obj
    obj = {}
    obj["id"] = @id
    obj["score"] = @score
    obj["positions"] = @positions
    obj["info"] = @info if @info != nil
    obj
  end

end