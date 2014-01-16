load 'pkt/answer.rb'
load 'pkt/answer/checkbox.rb'
load 'pkt/answer/radio.rb'
load 'pkt/answer/text.rb'

load 'pkt/controller_additions.rb'
load 'pkt/model_additions.rb'
load 'pkt/view_additions.rb'

load 'pkt/question.rb'
load 'pkt/fact.rb'
load 'pkt/matcher.rb'
load 'pkt/rule.rb'

load 'pkt/knowledge_base.rb'
load 'pkt/rule_parser.rb'


# the configuration of the knowledge base
# TODO: should be placed in an initializer
PKT::KnowledgeBase.setup :pkt do |config|

  # can be a file or a directory
  config.yml << "#{Rails.root}/rules.yml"

  # secret key, created using SecureRandom.uuid
  config.secret = 'f3f41598-e5d9-461e-acf3-2846ba3a3104'

end