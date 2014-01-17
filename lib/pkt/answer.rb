module PKT

  class Answer

    def initialize(content, question)

      self.question = question

      @facts = Hash.new

      parse_content content

    end

    # update the stored facts with the answer from the params
    def update_facts_from_params(params)

      # create empty array for the updated facts
      updated_facts = []

      # iterate all the facts stored by the answer
      @facts.each do |fact_name, fact|

        # check if the keys exists in the params
        if params.has_key? fact_name

          # get the posted value of the fact
          fact_value = params[fact_name]

          # TODO: check if posted value is valid

          # update the value of the fact
          fact.value = fact_value

          # add the fact to the updated facts array
          updated_facts << fact

        else

          # all facts should be posted to the application
          raise "Expected fact with name '#{fact_name}' to be posted, but doesn't exist in the posted parameters."

        end

      end

      # return the facts
      updated_facts

    end

    def facts

      @facts

    end

    # called when answer render only expects one fact
    def fact

      # return the first (and only?) fact
      fact_name, fact = @facts.first

      # return the fact
      fact

    end

    def question=(value)

      @question = value

    end

    def question

      @question

    end

    def parse_content(value)

      raise "The 'parse_content(value)' method should be overridden by the subclass"

    end

    def add_fact(fact_name, value = nil, label = nil)

      # TODO: when the value can be anything, needs validation!

      # when storing fact with the same name, this adds possible values to the fact
      if @facts.has_key?(fact_name)

        # retrieve the fact
        fact = @facts[fact_name]

        # add possible value to the fact
        # TODO: make difference to actual value and possible value

      else

        # TODO: what to do with the label?
        # create and store a new fact
        @facts[fact_name] = Fact.new(fact_name, value)

      end

    end

    def template

      template = self.class.to_s.underscore

    end

    def validate(content)

      # no validation, always true
      true

    end

  end

end