#load "#{Rails.root}/lib/pkt_development.rb"
#
## get the knowledge base with label pkt
#k = PKT::KnowledgeBase.instance :pkt
#
## add the rules to the system
#k.add_rules
#
## get the current rule
#rule = k.current_rule
#
## print the rule
#puts rule

# TODO: register after initializer handler for adding rules to the knowledge base and creating a snapshot of specified objects

module Resettable

  module ClassMethods


  end

  module InstanceMethods

    attr_accessor :snapshot

    def capture

      # capture the instance variables
      # @captured_instance_variables = {}

      # make a deep copy of the value of the instance variables

      # use clone instead of dup

      #snapshot = {}

      # make a copy of the object itself
      @snapshot = self.dup

      # the object itself, Foo, is not interesting?
      # prevent triggers when restoring snapshot: setters and getters methods

      instance_variables.each do |var|

        # snapshot should not contain a reference to itself
        unless var == :@snapshot

          # get the value
          value = instance_variable_get var

          if value.duplicable?

            # duplicate the value
            @snapshot.instance_variable_set(var, value.clone)

          end

        end

      end

    end

    def restore

      @snapshot

      # reset the instance variables

      # onyl update changes variables


    end

  end

  def self.included(base)

    base.send :include, InstanceMethods
    base.extend ClassMethods

  end

end


class Foo

  attr_accessor :content

  def initialize(content)

    @content = content

  end

end

class Bar

  attr_accessor :content

  def initialize(content)

    @content = content

  end

  def capture

    copy = self.clone

    instance_variables.each do |var|

      value = instance_variable_get var

      if value.duplicable?

        copy.instance_variable_set var, value.clone

      end

    end

    @capture = copy

  end

  def restore

    @capture.instance_variables.each do |var|

      value = @capture.instance_variable_get var

      self.instance_variable_set var, value

    end

  end

end

class Baz

  attr_accessor :content

  def initialize(content)

    @content = content

  end

end





#b = Bar.new [Baz.new(1)]
#
#
#b.capture
#
## puts a.inspect
#puts b.inspect
#puts
#
#b.content << Baz.new(2)
#
#puts b.inspect
#puts
#
#b.restore
#
#puts b.inspect


# make sure the object id of the object stays the same


a = Bar.new [1,2,3]

b = Baz.new a.content

puts a.content.object_id

puts b.content.object_id























