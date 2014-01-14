# TODO: data validation of the yml file
# TODO: refactor goals to results / actions
# TODO: refactor code so predicates like equals() are classes
# TODO: refactor goal to action / result
# TODO: when goal is rendered show decision tree

module PKT

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

        # TODO: replace when with if statement
        when rule_object.matcher.nil?

          # rule can be fired directly
          @possible_rules << rule_object

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

              # star to convert array to arguments
              rule AND *conditions do |v|

                # when rule is applicable, add to possible rules
                @possible_rules << rule_object

              end

            when :any # one of the conditions must match

              # star to convert array to arguments
              rule OR *conditions do |v|

                # when rule is applicable, add to possible rules
                @possible_rules << rule_object

              end

            else
              raise "Unknown matcher type #{matcher.type}"

          end



      end

    end

    # call this function to get all the possible rules
    # this is based on all the asserted facts and rules known
    def possible_rules

      # start the matching of the engine
      @engine.match

      # reject all rules that ARE goals
      @possible_rules.reject { |rule| !rule.goal.nil? }

    end

    def goals

      # reject all the rules that are NOT goals
      @possible_rules.reject { |rule| rule.goal.nil? }

    end

    private

    def create_conditions(conditions)

      conditions.map { |item| create_condition item }

    end

    def create_condition(item)

      var1     = convert_variable(item[0])
      var2     = convert_variable(item[2])
      operator = item[1]

      if is_fact?(var1) && is_fact?(var2)

        return [ AND(
                     [Fact, :f1, m.name == var1, {m.value => :f1_value}],
                     [Fact, :f2, m.name == var2, operation(m.value, operator, b(:f1_value))]
                 )]

      end

      if is_fact?(var1) && !is_fact?(var2)

        return [Fact, :f1, m.name == var1, operation(m.value, operator, var2)]

      end

      if !is_fact?(var1) && is_fact?(var2)

        return [Fact, :f1, m.name == var2, operation(m.value, operator, var1)]

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

    def convert_variable var

      # if it returns nil, it is a string
      if /^[0-9]+$/.match(var).nil?

        var

      else # otherwise it is a integer

        var.to_i

      end

    end

  end

end