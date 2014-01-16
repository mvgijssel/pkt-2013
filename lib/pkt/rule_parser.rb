module PKT

  # TODO: throw error on the same goal or rule name
  # TODO: central place with regular expressions what characters a fact / arithmetic / ... can contain
  class RuleParser

    def self.yml(location, knowledge_base)

      # load the yml file
      yml_config = YAML.load_file(location)

      # iterate each of the yml items
      yml_config.each do |rule_name, rule_content|

        # create the rule object
        rule = PKT::Rule.new rule_name

        # raise error if isn't iteratable?
        raise "Error in rule #{rule_name}: #{rule_content} does not contain any further definitions" unless rule_content.respond_to? :each

        # iterate the yml rule content
        rule_content.each do |name, value|

          case

            when value.nil?
              raise "Error in rule #{rule_name}: the content of #{name} is nill"

            when name == 'any'

              # it's an any matcher
              # always followed by an array of conditions
              matcher = Matcher.new :any

              # add the conditions
              add_conditions_to_matcher value, matcher

              # add the matcher to the rule
              rule.matcher = matcher

            when name == 'all'
              # it's an all matcher
              # always followed by an array of conditions
              matcher = Matcher.new :all

              # add the conditions
              add_conditions_to_matcher value, matcher

              # add the matcher to the rule
              rule.matcher = matcher

            # it's a goal -> can't contain questions AND facts
            when name == 'result'

              # fill in the goal variable
              rule.goal = value

            # it's a fact
            when name[0] == '$'

              # create a fact and add it to the rule
              rule.facts << knowledge_base.create_fact(name, value)

            # when value has iterable content, it's a question
            when value.respond_to?(:each)

              # create a new question
              question = Question.new name, rule

              # question can only contain single answer method
              value.each do |answer_method, answer_content|

                # create the answer object on the question
                question.answer = answer_class_from_string answer_method, answer_content, question

              end

              # add the question to the rule
              rule.questions << question

            # it's unknown content
            else

              raise "Error in rule #{rule_name}: unknown definition '#{name}: #{value}'. Wrong format question?"

          end

        end

        # add the rule to the database
        knowledge_base.add_rule rule

      end

    end

    private

    def self.answer_class_from_string(class_name, arguments, question)

      begin

        # get the class
        clazz = "PKT::Answer::#{class_name.camelize}".constantize

      rescue => e

        raise "Error in rule #{question.rule.name}: Couldn't find answer class '#{class_name}'."

      end

      # create a new class
      # noinspection RubyArgCount
      clazz.new arguments, question

    end

    def self.add_conditions_to_matcher(conditions, matcher)

      conditions.each do |condition|

        result = parse_condition condition

        case result[:operation]

          # TODO: refactor the way predicates are added to the system

          when 'equals'
            matcher.equals(result[:var1], result[:var2])

          when 'less'
            matcher.less(result[:var1], result[:var2])

          when 'greater'
            matcher.greater(result[:var1], result[:var2])

          when 'has'
            matcher.has(result[:var1])

          else
            raise "Unknown operation '#{result[:operation]}' in condition '#{condition}'"
        end

      end

    end

    def self.parse_condition (condition)

      result = /(?<operation>[a-zA-Z]+)\s*\(\s*(?<var1>[a-zA-Z0-9$]+)\s*(,\s*(?<var2>[a-zA-Z0-9$]+)\s*)?\)/.match(condition)

      raise "Syntax error in condition: #{condition}" if result.nil?

      {:var1 => result[:var1], :var2 => result[:var2], :operation => result[:operation]}

    end

  end

end