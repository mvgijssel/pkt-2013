# TODO: data validation of the yml file, input text cannot be empty for example! and numbers etc
# TODO: refactor code so predicates like equals() are classes
# TODO: refactor goal to action / result
# TODO: when goal is rendered show decision tree
# TODO: printing of facts in questions / goal statement
# TODO: when fact already exists and new value is assigned MODIFY the fact, do not assert new one
# TODO: should have a initializer for loading the rules in the database AND for configuration
# TODO: convert to gem and add install rake task
# TODO: the generator task should create a initializer with configuration + a rules directory in the app directory with a rules.yml file

module PKT

  class KnowledgeBase < Ruleby::Rulebook

    # add class level methods for creating the Ruleby engine
    extend Ruleby

    # make the class resettable
    #include Resettable

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

      # add the rules from the yml files
      # TODO: the add rules should be called somewhere else
      instance(knowledge_base_label).add_rules

      # TODO: should be rails hook (or something?), after application initializers have been called
      # only if cache classes in enabled in the configuration / environment

    end

    # get the knowledge base with the specified label
    def self.instance(label)

      # create or retrieve the knownledge base with the specified label
      @@instances[label] ||= KnowledgeBase.new label

    end

    def self.reset

      @@instances.each do |label, instance|

        instance.reset

      end

    end

    public

    # all the rules that are already triggered
    attr_accessor :triggered_rules

    private

    # flag if the engine has already run the match method
    attr_accessor :engine_has_matched

    # one or more yml locations
    attr_accessor :yml_locations

    # instance level variable
    attr_accessor :question_rules

    # stores the results
    attr_accessor :result_rules

    # array for rules to start with
    attr_accessor :start_rules

    # stores all the rules
    attr_accessor :rules

    # secret key for encryption / decryption
    attr_accessor :secret_key

    # initial rules
    attr_accessor :initial_rules

    # facts which have been asserted
    attr_accessor :has_asserted

    public

    # create a new knowledge base
    def initialize(label)

      # pass a new engine with name :knowledge_base_engine to the super class
      super KnowledgeBase::engine label

      # these only change when new rules are added, so upon initialization / setup
      # changes ONCE upon starting the server
      # don't change each request
      @yml_locations      = nil
      @fact_rules         = Array.new
      @start_rules        = Array.new
      @rules              = {}

      # instantiate variables
      @engine_has_matched = false
      @question_rules     = Array.new
      @result_rules       = Array.new
      @triggered_rules    = Array.new
      @has_asserted       = Hash.new

    end

    # get all the asserted facts
    def answered_facts

      @engine.facts

    end

    # function is called when new request starts
    # otherwise instance variables are kept between requesting causing a lot of errors
    def reset

      # retract all the facts asserted by the request
      @engine.facts.each do |fact|

        @engine.retract fact

      end

    end

    # add one or multiple yml locations
    def yml

      # return @yml_locations OR return an empty array and store this array in @yml_locations
      @yml_locations ||= []

    end

    # set the secret key
    def secret=(value)

      @secret_key=value

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

      # store the rule
      @rules[rule_object.name] = rule_object

      case

        # rule which asserts facts without conditions or questions
        when rule_object.matcher.nil? && rule_object.questions.empty?

          # add the rule to the fact rules array, contains rules with only facts
          @fact_rules << rule_object

        when rule_object.matcher.nil? && rule_object.questions.count > 0

          # rules can be triggered directly
          @start_rules << rule_object

        else

          # get the matcher
          matcher      = rule_object.matcher

          # get the matcher type (any / all)
          matcher_type = matcher.type

          # generate the ruleby conditions based on the matcher conditions
          conditions   = create_conditions matcher.conditions

          # switch statement for the matcher type
          case matcher_type

            # all the conditions must match
            when :all

              # star to convert array to arguments
              rule AND *conditions do |v|

                # when rule is applicable, add to possible rules
                rule_handler rule_object

              end

            # one of the conditions must match
            when :any

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

    # TODO: should be a single statement to update the knowledge base with new data
    # TODO: after the update statement different current_rule / result apply
    # TODO: knowledge base can be reset at any time

    # update knowledge base from the params hash
    def update_from_params(params)

      if params.has_key? :triggered_rules

        # all the posted triggered rules
        posted_triggered_rules = triggered_rules_from_encrypted(params[:triggered_rules])

        # trigger all the triggered rules?
        posted_triggered_rules.each do |rule|

          # trigger all the previous triggered rules
          trigger rule

        end

      end

      # do some checks for stuff needed in the params
      if params.has_key? :current_rule

        # get the posted rule
        posted_rule   = retrieve_rule(params[:current_rule])

        # update the questions from the params
        updated_facts = posted_rule.update_from_params params

        # prepend the submitted facts to the posted rule
        # prepend causes the submitted facts to be processed earlier
        # so rule facts can have submitted facts in their equasion
        posted_rule.answered_facts.unshift *updated_facts

        # trigger the posted rule
        trigger posted_rule

      end

    end

    # get the next rule
    def current_rule

      # start the matching of the ruleby engine if not yet called
      unless @engine_has_matched

        # first assert all the facts from the fact rules
        # these are rules without conditions and only facts
        # when doing this while adding the rules something weird happens and instead of 1 match, stuff matches 22+ times
        @fact_rules.each do |rule|

          trigger rule

        end

        # add start rules to the question rules when they are not yet handled
        @start_rules.each do |rule|

          # when rule not yet triggered
          unless triggered? rule

            # add to the possible questions
            @question_rules << rule

          end

        end

        # match the rules using the ruleby engine
        # TODO: still causes memory leak when cached as class and required by application controller
        @engine.match

        # set the matched flag
        @engine_has_matched = true

      end

      # get the first of the question rules
      @question_rules.first

    end

    # get all the result rules
    def result

      # start the matching of the ruleby engine if not yet called
      unless @engine_has_matched

        # TODO: should match the engine / all possible rules instead of raise error
        raise "Knowledge base hasn't been updated"

        #@engine.match
        #@engine_has_matched = true
      end

      # return the result array
      @result_rules

    end

    # retrieve a rule created defined as defined in the yml file
    def retrieve_rule(rule_name)

      # convert to symbol
      rule_name = rule_name.to_sym

      # raise error if rule doesn't exist
      raise "Rule with name '#{rule_name}' doesn't exist" unless @rules.has_key? rule_name

      # return the rule
      @rules[rule_name]

    end

    # retrieve a fact asserted in the knowledge base
    def retrieve_fact(fact_name)

      facts = engine.retrieve Fact

      facts = facts.select { |fact| fact.name == fact_name }

      raise "Fact with name #{fact_name} is unknown or not yet asserted." if facts.empty?

      raise "There is more than 1 fact (#{facts.count} total) with name #{fact_name}" if facts.count > 1

      # return single fact
      facts.first

    end

    # return a hash of the triggered rules
    def triggered_rules_to_encrypted

      # instantiate array
      array = []

      @triggered_rules.each do |rule|

        # create a new hash
        hash  = {:name => rule.name, :facts => {}}

        # get the facts answered by the rule
        facts = rule.answered_facts

        # iterate all the facts
        facts.each do |fact|

          hash[:facts][fact.name] = fact.value

        end

        # add the hash to the array
        array << hash

      end

      # return the encrypted array
      string    = array.to_json

      # encrypt the data
      encrypted = encrypt(string)

    end

    # get triggered rules from the hash
    def triggered_rules_from_encrypted(encrypted)

      # create a new rules array
      rules  = Array.new

      # decrypt the data
      string = decrypt(encrypted)

      # get the array back
      array  = JSON.parse string

      # iterate the array
      array.each do |hash|

        # get the rule back
        rule          = retrieve_rule hash['name']

        # update the rule
        updated_facts = rule.update_from_params hash['facts']

        # update the answered facts already on the rule, the facts defined outside a question
        rule.answered_facts.each do |fact|

          # check if the posted hash has the fact in the answered rule
          if hash['facts'].has_key? fact.name

            # update the fact with the value
            fact.value = hash['facts'][fact.name]

          else

            # trigger error when the fact doesn't exist on the rule
            raise "Fact with name '#{fact.name}' should have been posted, but doesn't exist."

          end

        end

        # add the facts to the rule, order doesn't matter because they all don't have facts in them anymore
        # TODO: check if answered_facts are updated properly -> no memory leaks?
        rule.answered_facts.push *updated_facts

        # add to the array
        rules << rule

      end

      # return the rules array
      rules

    end

    private

    # encrypt string using secret key
    def encrypt(string)

      # get the message encryptor
      encryptor = ActiveSupport::MessageEncryptor.new(@secret_key)

      # encrypt the string
      encryptor.encrypt_and_sign(string)

    end

    # decrypt string using secret key
    def decrypt(string)

      # get the message decryptor
      decryptor = ActiveSupport::MessageEncryptor.new(@secret_key)

      # decrypt the string
      decryptor.decrypt_and_verify(string)

    end

    # gets called when the conditions of a rule match
    def rule_handler(rule_object)

      # only rules that are not yet triggered should be processed
      unless triggered? rule_object

        case

          # when there are no questions and no goals
          when rule_object.questions.empty? && rule_object.result.nil?

            # trigger the rule, thus asserting facts and storing in triggered rules
            trigger rule_object

          # when the goal is NOT nil
          when !rule_object.result.nil?

            # add to the result rules
            @result_rules << rule_object

          # otherwise add to the question rules
          else

            # add to the possible questions
            @question_rules << rule_object

        end

      end

    end

    # evaluates the value of the fact
    def convert_fact_value(value)

      # TODO: check if contains only numbers -> convert to Integer or Float or Fixnum?

      # only when the type of the value is a string
      if value.is_a? String

        # replace each fact name with the value of that fact
        k     = value.gsub(/\$[a-zA-Z0-9]+/) { |match|

          # get the fact from the knowledge base
          fact = retrieve_fact match

          # return the value of the fact
          fact.value

        }

        # TODO: eval is security risk, create sandbox? or allow less operators?
        value = eval(k)

      end

      # return the value
      value

    end

    # trigger a rule, asserting the facts and adding to the triggered_rules
    def trigger(rule_object)

      # only when not yet triggered trigger the rule
      unless triggered? rule_object

        # assert all the facts stored in the rule
        assert_facts_from_rule rule_object

        # add the rule to the triggered rules
        @triggered_rules << rule_object

      end

    end

    # assert all the facts stored in a rule
    def assert_facts_from_rule(rule_object)

      # get the facts from the rule
      facts = rule_object.answered_facts

      # iterate all the facts
      facts.each do |fact|

        # TODO: also convert string to int etc here!!!
        # tha value gets updated here, so needs to be reset


        # something can crash during conversion
        fact.value = convert_fact_value fact.value


        # if already exist, update fact
        if @has_asserted.has_key? fact.name

          # update the fact
          already_asserted       = @has_asserted[fact.name]

          # update the already asserted fact
          already_asserted.value = fact.value

          # modify the fact in the engine
          @engine.modify already_asserted

        else

          # let the ruleby engine assert the fact
          @engine.assert fact

          # add the fact to the has asserted
          @has_asserted[fact.name] = fact

        end

      end

    end

    # determine if rule is already triggered
    def triggered? (rule_object)

      # check if the rule is in the triggered rules array
      triggered_rules.include? rule_object

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

    # converts the variable into proper type
    def convert_variable(var)

      if var.is_a?(String)

        case
          when !!/^[0-9]+$/.match(var)

            # convert to an integer
            Integer var

          when !!/^[0-9.]+$/.match(var)

            # convert to a float
            Float var

          else

            # otherwise just return the var
            var
        end

      else

        # not a string, return the var
        var

      end

    end

    # return the appropriate operation
    # Ruleby overrides the comparison operators so this returns a Ferrari object
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

    # check to see if variable is a fact
    def is_fact? variable

      # only works on strings
      if variable.is_a? String

        return variable[0] == '$'

      end

      # otherwise return false
      false

    end

  end

end