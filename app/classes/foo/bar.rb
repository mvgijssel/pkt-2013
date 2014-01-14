module Foo

  class Bar

    class << self

      def do_stuff_1

        puts "class level: #{Baz.new.class}"

      end

    end

    def self.do_stuff_2

      puts "class level: #{Baz.new.class}"

    end

    def do_stuff_3

      puts "Instance level: #{Baz.new.class}"

    end

  end

end