class PagesController < ApplicationController

  def home

    # load the development files
    load "#{Rails.root}/lib/pkt_development.rb" if Rails.env.development?

    # get a knowledge base with specified label
    k = knowledge_base :pkt

    begin

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

    rescue => e

      # define hte error message
      @error_message = "Error while interacting with the knowledge base: #{e.message}. Current rule is: #{@rule.inspect}"

      # get the triggered rules
      @triggered_rules = k.triggered_rules

      # get all the facts
      @facts = k.facts

      # create a backtrace cleaner
      bc = ActiveSupport::BacktraceCleaner.new

      # remove the full paths from the backtrace
      bc.add_filter{ |line| line.sub(Rails.root.to_s, '') }

      # remove all the lines that do not start with /app or /lib
      bc.add_silencer{ |line| line !~ /(^\/app)|(^\/lib)/ }

      # clean the backtrace up
      @error_backtrace = bc.clean(e.backtrace) # will strip the Rails.root prefix and skip any lines from mongrel or rubygems

      # render the error page
      render :error

    end

  end

end
