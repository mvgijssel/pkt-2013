class PagesController < ApplicationController

  def home

    # instantiate the knowledge base
    k = PKT::KnowledgeBase.new

    # parse the yml file and create rules in the knowledge base
    PKT::RuleParser.yml("#{Rails::root}/own_rules.yml", k)

    # get the previous answered rules
    answered_rules = answered_rules_from_params

    # if there is a new rule posted, add it to the answered rules
    unless params[:current_rule].nil?

      # get the rule posted, strong parameters posts everything in hashes :/
      # TODO: change the parameter is handled, not hash
      posted_rule                 = params[:current_rule].keys[0]

      # get the facts posted by the rule
      facts                       = facts_from_params

      # add the current rule and facts to the answered rules
      answered_rules[posted_rule] = facts

    end

    # assert the newly posted facts
    assert_facts_from_rules answered_rules, k

    # get all the possible rules based on known facts and rules
    rules = k.possible_rules

    # remove the rules that already have been answered
    rules = remove_answered_rules rules, answered_rules

    # there are no possible rules
    if rules.count > 0

      # create instance variable for rendering
      # get the first NON goal rule?
      @rule          = rules[0]

      # update the instance variable answered
      @answered_data = answered_rules

      # get the first rule and render
      render :question

    else

      # get the goals
      @goals = k.goals

      # render the goal view
      render :goal

    end

  end

  private

  def answered_rules_from_params

    puts 's'

    if params[:answered].nil?
      HashWithIndifferentAccess.new
    else

      decoded = JSON.parse(params[:answered])

      HashWithIndifferentAccess.new decoded
    end

  end

  def assert_facts_from_rules rules, knowledge_base

    rules.each do |rule_name, facts|

      facts.each do |fact|

        knowledge_base.assert PKT::Fact.new(fact[:name], convert_variable(fact[:value]))

      end

    end

  end

  def convert_variable var

    # if it returns nil, it is a string
    if /^[0-9]+$/.match(var).nil?

      var

    else # otherwise it is a integer

      var.to_i

    end

  end

  def facts_from_params

    facts = []

    params.each do |name, value|

      if name[0] == '$'

        facts << {:name => name, :value => value}

      end

      if name == 'checkbox'

        value.each do |name, value|

          if name[0] == '$'

            facts << {:name => name, :value => value}

          end

        end

      end

    end

    # return facts
    facts

  end

  def remove_answered_rules rules, answered_rules

    rules.reject { |rule|
      answered_rules.has_key? rule.name
    }

  end

end
