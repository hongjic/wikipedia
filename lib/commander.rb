require 'algorithms'
require 'singleton'
require 'byebug'

# valid operators: "and", "or"
# all words are in down case
# 因为not操作不好做。 不可能把所有其他id都纳入进来

class Commander

  include Singleton
  attr_accessor :op_priority

  def initialize
    @op_priority = {"and" => 2, "and not" => 2, "or" => 1, "(" => 0}
  end

  def exec command
    @workflow = Array.new
    @op_stack = Containers::Stack.new
    generate_workflow command
    exec_workflow
  end

  private

    def exec_workflow
      document_list1 = DocumentList.build_from_redis @workflow[0]
      document_list2 = nil
      len = @workflow.length
      (1 .. @workflow.length - 1).each do |i|
        if @workflow[i].class == Operator.itself
          document_list1 = document_list1.operate(@workflow[i], document_list2) # command pattern
        else
          document_list2 = DocumentList.build_from_redis @workflow[i]
        end
      end
      document_list1
    end


    def generate_workflow command
      len = command.length
      st = ""
      i = 0

      while i < len
        ch = command[i]
        if (ch >= 'a' and ch <= 'z')
          st += ch
          p command
          if (i == command.length - 1)
            i = check_string st, command, i
            st = ""
          end
        else
          if !st.empty?
            i = check_string st, command, i
            st = ""
          end
          @op_stack.push(Operator.new('(')) if ch == '('
          if (ch == ')')
            while (op = @op_stack.pop).op_text != '('
              @workflow.push op
            end
          end
        end
        i += 1
      end

      while @op_stack.next != nil
        @workflow.push @op_stack.pop
      end
    end

    # whether it is a value or an operator 
    # if it is an "and", check whether there is a not behind
    def check_string str, command, index
      if (str != "and" && str != "or") # a value
        @workflow.push str
      else
        # if there is "not" behind an "and"
        if str == "and" && index + 1 < command.length && command[index + 1, 3] == "not"
          str = "and not"
          index += 3
        end
        if @op_stack.empty? || @op_priority[str] > @op_priority[@op_stack.next.op_text]
          @op_stack.push Operator.new(str)
        else
          @workflow.push @op_stack.pop #output top
          @op_stack.push Operator.new(str)
        end
      end
      index
    end

end