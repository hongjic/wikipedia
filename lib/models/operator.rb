
class Operator

  attr_accessor :op_text

  def initialize str
    @op_text = str
  end

  def equal_to op
    @op_text == op.op_text
  end

  def to_method
    "execute_#{@op_text.gsub(' ', '_')}"
  end

end