module PKT

  # TODO: goals cannot have facts
  # TODO: goals cannot have questions
  # TODO: rule needs to have at least 1 fact OR 1 goal OR 1 question

  class Rule

    include Resettable

    attr_accessor :name, :questions, :result, :answered_facts

    # update the facts
    def update_from_params(params)

      # create a new array
      updated_facts = []

      # update the facts in the answer of the posted rule
      @questions.each do |question|

        # update the facts associated with the answer
        updated_facts.push *question.answer.update_facts_from_params(params)

      end

      # return the updated facts
      updated_facts

    end

    def initialize(name)

      self.name      = name.to_sym
      self.questions = Array.new


      self.answered_facts     = Array.new

    end

    def matcher=(value)

      # raise error when matcher already set
      raise "Matcher already set #{self.inspect}" unless @matcher.nil?

      @matcher = value

    end

    def matcher

      @matcher

    end

  end

end
