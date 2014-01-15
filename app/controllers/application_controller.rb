class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception


  # TODO: this temporarily should be removed when converted to a gem
  load "#{Rails.root}/lib/pkt_development.rb"


end
