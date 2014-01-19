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

        # return if content contains only numbers
        content =~ /^[0-9]+$/

      end

    end

  end

end