module PKT

  class Question

    attr_accessor :content, :answer, :rule

    def initialize(content, rule)

      @content = content
      @rule = rule

    end

    def answer=(value)

      # raise error when answer already set
      raise "Question answer already set: #{@answer.inspect} on question #{self.inspect}" unless @answer.nil?

      @answer = value

    end

    def answer

      raise "Answer not set on question #{self.inspect}" if @answer.nil?

      @answer

    end

  end

end