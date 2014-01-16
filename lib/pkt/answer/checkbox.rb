module PKT

  module Answer

    class Checkbox

      include PKT::Answer

      attr_accessor :options

      def initialize (content)

        @options = content

      end

    end

  end

end