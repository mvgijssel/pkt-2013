module PKT

  module Additions

    module Controller

      module ClassMethods

      end

      module InstanceMethods

        def knowledge_base(label)

          PKT::KnowledgeBase.instance label

        end

      end

      def self.included(base)

        # include is a private method, so use send method
        base.send(:include, InstanceMethods)

        # add class level methods
        base.extend ClassMethods

        # before each request reset the knowledge bases
        # if classes are cached need to manually reset the knowledge base
        if Rails.application.config.cache_classes

          base.send(:before_filter) { |c| PKT::KnowledgeBase.reset }

        end

      end

    end

  end

end

if defined? ActionController::Base
  ActionController::Base.class_eval do

    include PKT::Additions::Controller

  end
end