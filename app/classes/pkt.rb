module PKT

  class Rule

    attr_accessor :name, :questions, :is_goal

    def initialize(name, is_goal = false)

      self.name      = name.to_sym
      self.questions = Array.new
      self.is_goal   = is_goal

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

  class Question

    attr_accessor :content, :answer

    def initialize(content)

      self.content = content

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

  class Answer

  end

  class TextAnswer < Answer

    attr_accessor :fact_name

    def initialize(content)

      self.fact_name = content

    end

  end

  class RadioAnswer < Answer

    def initialize (content)


    end

  end

  class CheckboxAnswer < Answer

    def initialize (content)

    end

  end

  class Matcher

    attr_accessor :type, :conditions

    def initialize(type)

      self.type       = type
      self.conditions = Array.new

    end

    def equals var1, var2

      self.conditions << [var1, :==, var2]

    end

    def less var1, var2

      self.conditions << [var1, :<, var2]

    end

    def greater var1, var2

      self.conditions << [var1, :>, var2]

    end

  end

  class Fact
    attr_accessor :name, :value

    def initialize(name, value)
      self.name  = name
      self.value = value
    end
  end

  class KnowledgeBase < Ruleby::Rulebook

    # add class level methods for creating the Ruleby engine
    extend Ruleby

    attr_accessor :possible_rules

    def initialize

      super KnowledgeBase::engine :knowledge_base_engine

      @possible_rules = Array.new

    end

    def add_rule(rule_object)

      case

        when rule_object.matcher.nil?

          # rule can be fired directly
          @possible_rules << rule_object

        when rule_object.is_goal

          # TODO: implement goal

        else

          # get the matcher
          matcher      = rule_object.matcher

          # get the matcher type (any / all)
          matcher_type = matcher.type

          # generate the ruleby conditions based on the matcher conditions
          conditions   = create_conditions matcher.conditions

          # switch statement for the matcher type
          # TODO: implement matcher types
          case matcher_type

            when :all # all the conditions must match

            when :any # one of the conditions must match

            else
              raise "Unknown matcher type #{matcher.type}"

          end

          # star to convert array to arguments
          rule *conditions do |v|

            # when rule is applicable, add to possible rules
            @possible_rules << rule_object

          end

      end

    end

    # call this function to get all the possible rules
    # this is based on all the asserted facts and rules known
    def possible_rules

      # start the matching of the engine
      @engine.match

      # return the possible rules
      @possible_rules

    end

    private

    def create_conditions(conditions)

      conditions.map { |item| create_condition item }

    end

    def create_condition(item)

      var1     = item[0]
      var2     = item[2]
      operator = item[1]

      if is_fact?(var1) && is_fact?(var2)

        return [
            [Fact, :f1, m.name == var1, {m.value => :f1_value}],
            [Fact, :f2, m.name == var2, operation(m.value, operator, b(:f1_value))]
        ]

      end

      if is_fact?(var1) && !is_fact?(var2)

        return [Fact, :f1, m.name == var1, m.value == var2]

      end

      if !is_fact?(var1) && is_fact?(var2)

        return [Fact, :f1, m.name == var2, m.value == var1]

      end

      raise "There is no fact name in: #{var1} #{operator} #{var2}"

    end

    def operation(var1, operator, var2)

      case operator
        when :==
          var1 == var2
        when :>
          var1 > var2
        when :<
          var1 < var2
        else
          raise "Unknown operator #{operator}"

      end

    end

    def is_fact? variable

      # only works on strings
      if variable.is_a? String

        return variable[0] == '$'

      end

      # otherwise return false
      false

    end

  end

  class RuleParser

    class << self

      def yml location, knowledge_base

        # load the yml file
        # create rules from the yml file like so:
        # maybe instead of objects, use a hash?

        yml_config = YAML.load_file(location)

        yml_config.each do |rule_name, rule_content|

          # create the rule object
          rule = Rule.new rule_name

          # raise error if isn't iteratable?
          raise "Error in rule #{rule_name}: #{rule_content} does not contain any further definitions" unless rule_content.respond_to? :each

          # iterate the yml rule content
          rule_content.each do |name, value|

            case

              when value.nil?
                raise "Error in rule #{rule_name}: the content of #{name} is nill"

              when name == 'any'
                # it's an any matcher
                # TODO: implement handling of a single condition
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

              when name == 'goal' # it's a goal -> can't contain questions AND facts

                # TODO: implement goal handling

              when name[0] == '$' # it's a fact

                #TODO: implement fact handling

              else # it's a question

                   # create a new question
                question = Question.new name

                # question can only contain single answer method
                value.each do |answer_method, answer_content|

                  case answer_method

                    when 'text'

                      question.answer = TextAnswer.new answer_content

                    when 'radio'

                      question.answer = RadioAnswer.new answer_content

                    when 'checkbox'

                      question.answer = CheckboxAnswer.new answer_content

                    else
                      raise "Error in rule #{rule_name}: unknown answer method #{answer_method}"
                  end

                end

                rule.questions << question

            end

          end

          # add the rule to the database
          knowledge_base.add_rule rule

        end

      end

      private

      def is_question?(value)

        case value
          when 'any'
          when 'all'


        end

      end

      def add_conditions_to_matcher(conditions, matcher)

        conditions.each do |condition|

          result = parse_condition condition

          case result[:operation]

            # TODO: implement seperate classes for different classes
            when 'equals'
              matcher.equals(result[:var1], result[:var2])

            when 'less'
              matcher.less(result[:var1], result[:var2])

            when 'greater'
              matcher.greater(result[:var1], result[:var2])

            else
              raise "Unknown operation #{result[:operation]} in condition #{condition}"
          end

        end

      end

      def parse_condition (condition)

        result = /(?<operation>[a-zA-Z]+)\s*\(\s*(?<var1>[a-zA-Z0-9$]+)\s*(,\s*(?<var2>[a-zA-Z0-9$]+)\s*)?\)/.match(condition)

        raise "Syntax error in condition: #{condition}" if result.nil?

        {:var1 => result[:var1], :var2 => result[:var2], :operation => result[:operation]}

      end

    end

  end

end