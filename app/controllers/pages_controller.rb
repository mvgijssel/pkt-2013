class PagesController < ApplicationController

  def home

    # load the development files
    load "#{Rails.root}/lib/pkt_development.rb" if Rails.env.development?

    # get a knowledge base with specified label
    k = knowledge_base :pkt

    begin

      # assert facts from the parameters
      k.update_from_params params

    rescue => e

      flash.now[:warning] = "Error in updating the knowledge base from the params: #{e.inspect}"

    end


    begin

      # get the current rule
      @rule = k.current_rule

    rescue => e

      flash.now[:warning] = "Error in getting the current rule from the knowledge base: #{e.inspect}"

    end


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
