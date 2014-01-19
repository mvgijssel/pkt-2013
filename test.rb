load "#{Rails.root}/lib/pkt_development.rb"

# get the knowledge base with label pkt
k = PKT::KnowledgeBase.instance :pkt

# add the rules to the system
k.add_rules

# get the current rule
rule = k.current_rule

# print the rule
puts rule