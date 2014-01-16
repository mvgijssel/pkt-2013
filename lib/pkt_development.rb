load 'pkt/knowledge_base.rb'
load 'pkt/rule_parser.rb'

load 'pkt/answer.rb'
load 'pkt/answer/checkbox.rb'
load 'pkt/answer/radio.rb'
load 'pkt/answer/text.rb'

load 'pkt/additions/controller.rb'
load 'pkt/additions/model.rb'
load 'pkt/additions/view.rb'

load 'pkt/question.rb'
load 'pkt/fact.rb'
load 'pkt/matcher.rb'
load 'pkt/rule.rb'

# the configuration of the knowledge base
PKT::KnowledgeBase.setup :pkt do |config|

  # can be a file or a directory
  config.yml << "#{Rails.root}/app/rules/testing.yml"

  # secret key, created using SecureRandom.uuid
  config.secret = 'f3f41598-e5d9-461e-acf3-2846ba3a3104'

end