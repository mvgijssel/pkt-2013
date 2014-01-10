class PagesController < ApplicationController

  def test



  end

  def home



    # solve returns the next question
    question = KnowledgeBase::Solver.solve(params, cookies)

    # there are no more questions, render the goal page
    if question.nil?

      @station1 = KnowledgeBase::Questions.instance.station1
      @station2 = KnowledgeBase::Questions.instance.station2
      @station3 = KnowledgeBase::Questions.instance.station3

      render('questions/goal')

    else

      @description = question.description

      render(question.view)

    end

  end

end
