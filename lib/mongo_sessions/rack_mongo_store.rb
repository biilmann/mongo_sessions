require 'mongo_sessions/mongo_store'
require 'rack/session/abstract/id'

module Rack
  module Session
    class MongoStore < Rack::Session::Abstract::ID
      include MongoSessions::MongoStore
    end
  end
end