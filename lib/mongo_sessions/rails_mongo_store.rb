require 'mongo_sessions/mongo_store'
require 'action_dispatch/middleware/session/abstract_store'

module ActionDispatch
  module Session
    class MongoStore < Rack::Session::Abstract::ID
      include MongoSessions::MongoStore
    end
  end
end