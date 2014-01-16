require 'pkt/knowledge_base'
require 'pkt/rule_parser'

require 'pkt/answer'
require 'pkt/answer/checkbox'
require 'pkt/answer/radio'
require 'pkt/answer/text'

require 'pkt/controller_additions'
require 'pkt/model_additions'
require 'pkt/view_additions'

require 'pkt/question'
require 'pkt/fact'
require 'pkt/matcher'
require 'pkt/rule'

# the configuration of the knowledge base
PKT::KnowledgeBase.setup :pkt do |config|

  # can be a file or a directory
  config.yml << "#{Rails.root}/own_rules.yml"

  # secret key, created using SecureRandom.uuid
  config.secret = 'f3f41598-e5d9-461e-acf3-2846ba3a3104'

end