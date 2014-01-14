module PKT

  class Fact
    attr_accessor :name, :value

    def initialize(name, value)
      self.name  = name
      self.value = value
    end
  end

end