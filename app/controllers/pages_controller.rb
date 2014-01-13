class PagesController < ApplicationController

  def home

    # instantiate the knowledge base
    k = PKT::KnowledgeBase.new

    # parse the yml file and create rules in the knowledge base
    PKT::RuleParser.yml("#{Rails::root}/rules.yml", k)

    # add all the facts known (passed in the form)
    # TODO: implement fact assertion

    # get all the possible rules based on known facts and rules
    rules = k.possible_rules

    # get the first rule and render
    render :question, :rule => rules.first

  end

end
