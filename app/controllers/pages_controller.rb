class PagesController < ApplicationController

  def home

    # load the development files
    load "#{Rails.root}/lib/pkt_development.rb" if Rails.env.development?

    # get a knowledge base with specified label
    k = knowledge_base :pkt

    # assert facts from the parameters
    k.update_from_params params

    # get the current rule
    @rule = k.current_rule

    # if there is no next rule, render result
    if @rule.nil?

      # get the possible result rules
      @results = k.result

      # render the result page
      render :result

    else

      render :rule

    end

  end

end
