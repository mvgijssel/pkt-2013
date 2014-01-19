module PKT

  class Answer

    class Checkbox < Answer

      def parse_content(content)

         content.each do |fact_name, fact_label|

           add_fact(fact_name, 0, fact_label)

         end

      end

    end

  end

end