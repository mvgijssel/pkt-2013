require 'pkt/resettable'
require 'pkt/knowledge_base'
require 'pkt/rule_parser'

require 'pkt/answer'
require 'pkt/answer/checkbox'
require 'pkt/answer/radio'
require 'pkt/answer/text'

require 'pkt/additions/controller'
require 'pkt/additions/model'
require 'pkt/additions/view'

require 'pkt/question'
require 'pkt/fact'
require 'pkt/matcher'
require 'pkt/rule'

# the configuration of the knowledge base
PKT::KnowledgeBase.setup :pkt do |config|

  # can be a file or a directory
  config.yml << "#{Rails.root}/app/rules/pkt-2013.yml"

  # secret key, created using SecureRandom.uuid
  config.secret = 'f3f41598-e5d9-461e-acf3-2846ba3a3104'

end

# capture the states of all resettable objects


if Rails.application.config.cache_classes

  PKT::Resettable.capture

end
