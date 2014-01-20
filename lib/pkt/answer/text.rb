module PKT

  class Answer

    class Text < Answer

      # sets the content
      def parse_content(content)

        # add a fact with only a name, so the value can be anything
        # the content contains the fact name
        add_fact content

      end

      # overrides the module validation
      def validate(content)

        case
          when content.is_a?(Numeric)
            true
          when content.is_a?(String)
            content =~ /^[0-9]+$/
          else
            raise "Unknown class '#{content.class}' of content '#{content.inspect}'"
        end

      end

    end

  end

end