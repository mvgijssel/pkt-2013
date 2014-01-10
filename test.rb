class Rule

  attr_accessor :name, :questions, :matcher

  def initialize(name)

    self.name      = name
    self.questions = Array.new

  end

end

class Question

  attr_accessor :content, :answer

  def initialize(content)

    self.content = content

  end

end

class Answer

end

class TextAnswer < Answer

  attr_accessor :fact_name

  def initialize(fact_name)

    self.fact_name = fact_name

  end

end

class Matcher

  attr_accessor :type, :conditions

  def initialize(type)

    self.type       = type
    self.conditions = Array.new

  end

  def equals variable1, variable2

    self.conditions << [variable1, :==, variable2]

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

  def initialize

    super KnowledgeBase::engine :knowledge_base_engine

  end

  def add_rule(rule_object)

    # get the matcher
    matcher      = rule_object.matcher

    # get the matcher type (any / all)
    matcher_type = matcher.type

    # generate the ruleby conditions based on the matcher conditions
    conditions   = generate_conditions matcher.conditions

    #puts conditions.inspect

    # switch statement for the matcher type
    case matcher.type

      when :all # all the conditions must match


      when :any # one of the conditions must match


      else
        raise "Unknown matcher type #{matcher.type}"

    end


    #rule [Fact, :f_1, m.name == 'something', {m.value => :f_1_value}],
    #     [Fact, :f_2, m.name == 'else', m.value >= b(:f_1_value)] do |v|
    #
    #  #puts v.inspect
    #
    #end


    rule [Fact, :f, krek(:==)] do |v|

      puts 'SHINE'

    end

  end

  def krek(operator)

    case operator
      when :==
        m.name == 'test'
    end
  end

  # call this function to get all the possible rules
  # this is based on all the asserted facts and rules known
  def possible_rules

    # start the matching of the engine
    @engine.match

  end

  private

  def generate_conditions conditions

    conditions.map { |condition|

      var1     = condition[0]
      var2     = condition[2]
      operator = condition[1]

      if is_fact?(var1) && is_fact?(var2)

        return [
            [Fact, :f1, m.name == var1, {m.value => :f1_value}],
            [Fact, :f2, m.name >= var2, m.value == b(:f1_value)]
        ]

      end

      if is_fact?(var1) && !is_fact?(var2)

      end

      if !is_fact?(var1) && is_fact?(var2)

      end

      raise "There is no fact name in: #{var1} #{operator} #{var2}"

    }

  end

  def is_fact? variable

    true

  end

end

class RuleParser

  class << self

    def yml location, knowledge_base

      # load the yml file
      # create rules from the yml file like so:
      # maybe instead of objects, use a hash?

      # create the rule
      rule            = Rule.new 'rule1'

      # create a new question for each question asked
      question        = Question.new 'wat is de temperatuur?'

      # set the answering type for the question
      question.answer = TextAnswer.new('temperature')

      # add the question to the rule
      rule.questions << question

      # create a new condition object
      matcher = Matcher.new :all

      # fact :something equals 1
      matcher.equals ':something', '1'

      # set the condition on the rule
      rule.matcher = matcher

      # add a rule to the knownledge base
      knowledge_base.add_rule rule

    end

  end

end

# instantiate the knowledge base
k = KnowledgeBase.new

# parse the yml file and create rules in the knowledge base
RuleParser.yml("#{Rails::root}/rules.yml", k)

# add all the facts known (passed in the form)
#k.assert Fact.new


k.assert Fact.new 'something', '11'
k.assert Fact.new 'else', '12'
k.assert Fact.new 'test', '12'


# get all the possible rules based on known facts and rules
rules = k.possible_rules

# print the known rules
puts rules.inspect










