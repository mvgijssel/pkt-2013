module PKT

  class Answer

    class Text < Answer

      # sets the content
      def parse_content(content)

        add_option content

      end

      # overrides the module validation
      def validate(content)

         false

      end

    end

  end

end