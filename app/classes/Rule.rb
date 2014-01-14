module PKT

  class Rule

    attr_accessor :name, :questions, :goal

    def initialize(name)

      self.name      = name.to_sym
      self.questions = Array.new

    end

    def matcher=(value)

      # raise error when matcher already set
      raise "Matcher already set #{self.inspect}" unless @matcher.nil?

      @matcher = value

    end

    def matcher

      @matcher

    end

  end

end
