module PKT

  module Additions

    module Model

      module ClassMethods

      end

      module InstanceMethods

      end

      def self.included(base)

        base.send :include, InstanceMethods
        base.extend ClassMethods

      end

    end

  end

end

if defined? ActiveRecord::Base
  ActiveRecord::Base.class_eval do

    include PKT::Additions::Model

  end
end

