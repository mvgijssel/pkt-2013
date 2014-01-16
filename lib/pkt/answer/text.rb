module PKT

  module Answer

    class Text

      include PKT::Answer

      attr_accessor :fact_name

      def initialize(content)

        self.fact_name = content

      end

    end

  end

end