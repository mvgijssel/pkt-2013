module PKT

  class Fact

    include Resettable

    attr_accessor :name, :label, :value

    def initialize(name, value, label = nil)

      # store the fact name
      self.name  = name

      # store value the value directly
      # this way the setter doesn't get executed
      self.value = value

      # store the label
      self.label = label

    end

    # return the possible values array
    def possible_values

      @possible_values ||= Array.new

    end

  end

end