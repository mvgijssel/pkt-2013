module PKT

  class Fact
    attr_accessor :name, :value

    def initialize(name, value)
      self.name  = name
      self.value = value
    end



    #def assert(knowledge_base)
    #
    #  # evaluate the value of the fact, can contain arithmetic
    #  if @value.is_a? String
    #
    #    k = @value.gsub(/\$[a-zA-Z0-9]+/) { |match|
    #
    #      # get the fact from the knowledge base
    #      fact = knowledge_base.retrieve_fact match
    #
    #      # return the value of the fact
    #      fact.value
    #
    #    }
    #
    #    # TODO: high security risk using eval, make sure the string here only contains arithmetic. or sandbox it?
    #    @value = eval(k)
    #
    #  end
    #
    #  knowledge_base.assert self
    #
    #end
  end

end