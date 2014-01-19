module PKT

  class Answer

    class Radio < Answer

      def parse_content(content)

        fact_name, options = content.first

        options.each do |value, label|

          add_fact fact_name, value, label

        end

      end

    end

  end

end