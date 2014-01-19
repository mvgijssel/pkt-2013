module PKT

  class Fact

    include Resettable

    attr_accessor :name, :value

    def initialize(name, value)

      # store the fact name
      self.name  = name

      # store the converted value
      self.value = value

    end

  end

end