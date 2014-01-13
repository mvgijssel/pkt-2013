require 'ruleby'

module KnowledgeBase

  class Solver

    # include Ruleby module as class level methods
    # gives access to the engine method
    extend Ruleby

    class << self

      def solve(params, cookies)

        # instantiate an engine
        engine :engine do |e|

          # instantiate the questions class
          q = Questions.new e

          # create the questions in memory
          q.create


          if params[:commit].nil?

            cookies[:data] = ''

          else

            unless cookies[:data].blank?

              data = JSON.parse(cookies[:data])

              data.each do |key, value|

                q.answer(key, value, cookies)

              end

            end

            q.answer(params[:tag], params, cookies)

          end

          # run the matching of the engine
          e.match

          # get the next question
          return q.next

        end

      end

    end

  end


  class Fact

    attr_accessor :name, :value

    def initialize(name, value)

      @name = name
      @value = value

    end

  end

  class Question

    attr_accessor :tag, :description, :condition, :available

    def initialize(tag, description, condition = nil)

      @tag = tag
      @description = description
      @condition = condition

      # if nil, available is true
      @available = !!condition.nil?

      # register the question with the questions
      Questions.instance.register self

    end

    def view

      "questions/#{@tag}"

    end

  end

  class Questions < Ruleby::Rulebook

    class << self

      def instance

        @instance

      end

      def instance=(value)

        @instance = value

      end

    end

    def answer(tag, params, cookies)

      question = @hash[tag.to_sym]

      data = {tag => params}.to_json

      cookies[:data] = {
          :value => data,
          :expires => 4.years.from_now
      }

      self.send(question.tag, params)

      question.available = false

    end

    attr_accessor :engine, :questions, :hash, :station1, :station2, :station3

    def initialize engine

      @station1 = 0
      @station2 = 0
      @station3 = 0

      @questions = Array.new
      @hash = Hash.new

      @engine = engine
      self.class.instance = self

      super

    end

    def next

      a = @questions.find_all { |question| question.available }

      # return the first element
      a[0]

    end

    def register(question)

      @hash[question.tag] = question

      @questions << question

      unless question.condition.nil?

        rule question.condition do |v|

          # make the question available when the condition matches
          question.available = true

        end

      end

    end

    def create

      Question.new(
          :initieel,
          'Voer de initiele waarden in',
      )

      Question.new(
          :alkmaar,
          'Staat Alkaar aan?',
          [Fact, :f, m.name == :temperatuur, m.value > 10]
      )

    end

    def initieel(params)

      engine.assert Fact.new(:temperatuur, params[:temperatuur].to_i)

    end

    def alkmaar(params)

      if params[:ingeschakeld] == 'ja'

        @station1 += 0.5

      else

        @station2 += 0.3
        @station3 += 0.3

      end


    end

  end


end