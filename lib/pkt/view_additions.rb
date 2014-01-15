module PKT

  module ViewAdditions

    module ClassMethods

    end

    module InstanceMethods

      def knowledge_base_fields

        # get the knowledge base
        # TODO: should not hardcode the label
        k = PKT::KnowledgeBase.instance :pkt

        # render an hidden_field_tag with the current rule
        k.current_rule

        # render an hidden_field_tag with the previous rules



      end

    end

    def self.included(base)

      base.send :include, InstanceMethods
      base.extend ClassMethods

    end

  end

end

if defined? ActionView::Base
  ActionView::Base.class_eval do

    include PKT::ViewAdditions

  end
end