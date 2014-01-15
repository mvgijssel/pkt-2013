# TODO: data validation of the yml file, input text cannot be empty for example! and numbers etc
# TODO: refactor goals to results / actions
# TODO: refactor code so predicates like equals() are classes
# TODO: refactor goal to action / result
# TODO: when goal is rendered show decision tree
# TODO: introduce concept of Question Rule / Goal Rule and Fact Rule
# TODO: printing of facts in questions / goal statement
# TODO: when fact already exists and new value is assigned MODIFY the fact, do not assert new one
# TODO: should have a initializer for loading the rules in the database AND for configuration
# TODO: convert to gem and add install rake task
# TODO: the generator task should create a initializer with configuration + a rules directory in the app directory with a rules.yml file

module PKT

  class KnowledgeBase < Ruleby::Rulebook

    # add class level methods for creating the Ruleby engine
    extend Ruleby

    # cattr is class level variables
    # mattr is module level variables
    # stores all the instances of the knowledge base in a hash
    cattr_accessor :instances
    @@instances = {}

    # method which passes a block, to configure the Knowledgebase
    # maybe instead of returning an instance, return a hash. Because now each time an instance gets created
    def self.setup(knowledge_base_label)

      # the argument passed in the block is the KnowledgeBase class
      yield instance(knowledge_base_label)

    end

    # get the knowledge base with the specified label
    def self.instance(label)

      # create or retrieve the knownledge base with the specified label
      @@instances[label] ||= KnowledgeBase.new label

    end

    private

    # flag if the engine has already run the match method
    attr_accessor :engine_has_matched

    # one or more yml locations
    attr_accessor :yml_locations

    # instance level variable
    attr_accessor :question_rules

    # stores the results
    attr_accessor :result_rules

    # for the fact rules, rules that contain only facts and should be run immediatly
    attr_accessor :fact_rules

    # all the rules that are already triggered
    attr_accessor :triggered_rules

    public

    # create a new knowledge base
    def initialize(label)

      # pass a new engine with name :knowledge_base_engine to the super class
      super KnowledgeBase::engine label

      # instantiate variables
      @engine_has_matched = false
      @yml_locations = nil
      @question_rules = Array.new
      @result_rules = Array.new
      @fact_rules = Array.new
      @triggered_rules = Array.new

    end

    # read the yml files and add rules to the knowledge base using the parser
    def add_rules

      raise 'Not a single yml location is defined for rules' if yml.empty?

      yml.each do |location|

        RuleParser.yml location, self

      end

    end

    # add a rule to the knowledge base
    def add_rule(rule_object)

      case

        # rule which asserts facts without conditions or questions
        when rule_object.matcher.nil? && rule_object.questions.empty?

          # assert all the facts
          rule_object.assert_facts self

        when rule_object.matcher.nil? && rule_object.questions.count > 0

          # rule can be fired directly
          @question_rules << rule_object

        else

          # get the matcher
          matcher = rule_object.matcher

          # get the matcher type (any / all)
          matcher_type = matcher.type

          # generate the ruleby conditions based on the matcher conditions
          conditions = create_conditions matcher.conditions

          # switch statement for the matcher type
          # TODO: implement matcher types
          case matcher_type

            when :all # all the conditions must match

              # star to convert array to arguments
              rule AND *conditions do |v|

                # when rule is applicable, add to possible rules
                rule_handler rule_object

              end

            when :any # one of the conditions must match

              # star to convert array to arguments
              rule OR *conditions do |v|

                # when rule is applicable, add to possible rules
                rule_handler rule_object

              end

            else
              raise "Unknown matcher type #{matcher.type}"

          end

      end

    end

    # add one or multiple yml locations
    def yml

      # return @yml_locations OR return an empty array and store this array in @yml_locations
      @yml_locations ||= []

    end

    # assert facts from the params hash
    def assert_facts_from_params(params)

      # the params should be converted to rules and associated facts




    end

    # get the next rule
    def next_rule

      # start the matching of the ruleby engine if not yet called
      unless @engine_has_matched
        @engine.match
        @engine_has_matched = true
      end

      # return the first of the question rules
      @question_rules.first

    end

    # get all the result rules
    def result

      # start the matching of the ruleby engine if not yet called
      unless @engine_has_matched
        @engine.match
        @engine_has_matched = true
      end

      # return the result array
      @result_rules

    end

    # retrieve a rule created defined as defined in the yml file
    def retrieve_rule(rule_name)

    end

    # retrieve a fact asserted in the knowledge base
    def retrieve_fact(fact_name)

      facts = engine.retrieve Fact

      facts = facts.select { |fact| fact.name == fact_name }

      raise "Fact with name #{fact_name} is unknown or not yet asserted." if facts.empty?

      raise "There is more than 1 fact (#{facts.count} total) with name #{fact_name}" if facts.count > 1

      # return single fact
      facts[0]

    end

    private

    def rule_handler(rule_object)

      case

        when rule_object.questions.empty? && rule_object.goal.nil?

          # when there are no questions and no goals
          # add to the fact rules
          # TODO: ALSO should be added to globally asserted facts / fired rules so followup rules still have the data
          @fact_rules << rule_object

          # trigger rule when not already triggered -> function for checking

        @triggered_rules << rule_object # something like this?

          # should be triggered while still executing engine.match!!

        when !rule_object.goal.count.nil?

          # when the goal is defined
          @result_rules << rule_object

        else

          # otherwise add to the question rules
          @question_rules << rule_object

      end

    end

    # map actual conditions to the triplets passed here
    def create_conditions(conditions)

      conditions.map { |item| create_condition item }

    end

    # create and return a condition
    def create_condition(item)

      var1 = convert_variable(item[0])
      var2 = convert_variable(item[2])
      operator = item[1]

      if is_fact?(var1) && is_fact?(var2)

        return [AND(
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
        when :has
          # TODO: other way conditions are handled!
          var1
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

    # TODO: should be moved to a central location, now if defined twice
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