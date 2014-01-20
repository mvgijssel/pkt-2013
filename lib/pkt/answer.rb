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

          case

            # should run validation method
            when fact.value.nil? && fact.possible_values.empty?

              # validate the value
              if validate fact_value

                # validation passes, store the value
                fact.value = fact_value

              else

                # validation doesn't pass, throw error
                raise ArgumentError, "The value '#{fact_value}' isn't a valid input for question '#{question.content}''"

              end

            when fact.value.nil? && fact.possible_values.count > 0

              match = false

              fact.possible_values.each do |possible_value|

                # convert to string, because posted is string
                if possible_value[:value].to_s == fact_value.to_s

                  match = true
                  fact.value = fact_value
                  fact.label = possible_value[:label]

                end

              end

              unless match

                raise ArgumentError, "The value '#{fact_value}' isn't a valid input for question '#{question.content}''"

              end

              fact.value = fact_value

            else
              # just save it
              # update the value of the fact
              fact.value = fact_value

          end

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

        unless fact.possible_values.count > 0

          # add the current value and label
          fact.possible_values << {:value => fact.value, :label => fact.label}

          # set the current value to nil
          fact.value = nil

          # set the label to nil
          fact.label = nil

        end

        # add the value and label to the possible values
        fact.possible_values << {:value => value, :label => label}

      else

        # create and store a new fact
        @facts[fact_name] = Fact.new(fact_name, value, label)

      end

    end

    # get the template name to render
    def template

      template = self.class.to_s.underscore

    end

    # validate
    def validate(content)

      # no validation, always true
      raise "Validate method should be implemented by subclass"

    end

  end

end