module PKT

  module Resettable

    mattr_accessor :objects
    self.objects = Array.new

    def self.capture

      self.objects.each do |object|

        object.capture

      end

    end

    def self.restore

      self.objects.each do |object|

        object.restore

      end

    end

    module InstanceMethods

      attr_accessor :snapshot

      def initialize(*args)

        # regiter the object with callback
        PKT::Resettable.objects << self

        super *args

      end

      def capture

        @copy = self.clone

        self.instance_variables.each do |var|

          # TODO: really hacky, behaviour should be implemented differently
          unless var == :@copy || var == :@engine

            value = self.instance_variable_get var

            if value.duplicable?

              @copy.instance_variable_set var, value.clone

            end

          end

          #puts "#{self.class}: #{var} #{instance_variable_get(var).object_id} #{@copy.instance_variable_get(var).object_id}"

        end

      end

      def restore

        @copy.instance_variables.each do |var|

          value = @copy.instance_variable_get var

          if value.duplicable?

            self.instance_variable_set(var, @copy.instance_variable_get(var).clone)

          else

            self.instance_variable_set(var, @copy.instance_variable_get(var))

          end

        end

      end

    end

    def self.included(base)

      #base.send :include, InstanceMethods

      # with the prepend method, methods from the module take precedence to the class methods
      # only in ruby 2.0+
      base.send :prepend, InstanceMethods
      #base.extend ClassMethods

    end

  end

end