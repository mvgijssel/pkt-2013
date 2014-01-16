module PKT

  class Answer

    def initialize(content, question)

      self.question = question

      @options = Hash.new

      parse_content content

    end

    def facts

      @options

    end

    def fact

      # return the first (and only?) fact
       @options.first

    end

    def question=(value)

      @question = value

    end

    def question

      @question

    end

    def parse_content(value)

      raise "The content=(value) should be overridden by the subclass"

    end

    def add_option(fact_name, label = nil, value = nil)

      unless @options.has_key?(fact_name)

        # create a new array only when the key doesn't exist
        @options[fact_name] = []

      end

      unless label.nil? && value.nil?

        # create a new hash
        data = {}

        # set the label attribute
        data[:label] = label unless label.nil?

        # set the value attribute
        data[:value] = value unless value.nil?

        # add with the fact
        @options[fact_name] << data

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