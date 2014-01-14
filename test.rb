## doesn't work
#Foo::Bar.do_stuff_1
#
## does work
#Foo::Bar.do_stuff_2
#
## does work
#Foo::Bar.new.do_stuff_3

# create a new knowledge base
k = PKT::KnowledgeBase.new

# create rules using yml file
PKT::RuleParser.yml "#{Rails.root}/rules.yml", k

# get all the possible rules based on known facts and rules
rules = k.possible_rules

# assert the facts of the rule
rules[0].assert_facts k

