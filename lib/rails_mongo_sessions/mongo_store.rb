module ActionDispatch
  module Session
    class MongoStore < AbstractStore
      attr_accessor :collection
      
      def initialize(app, options = {})
        require 'mongo'
        
        unless options[:collection]
          raise "To avoid creating multiple connections to MongoDB, " +
                "the Mongo Session Store will not create it's own connection" +
                "to MongoDB - you must pass in a collection with the :collection option"
        end
        
        @collection = options[:collection].respond_to?(:call) ? options[:collection].call || options[:collection]
        
        super
      end

      private
      def get_session(env, sid)
        sid ||= generate_sid
        session = collection.find_one('_id' => sid) || {}
        [sid, session]
      end

      def set_session(env, sid, session_data)
        options = env['rack.session.options']
        collection.update({'_id' => sid}, session_data, true)
        sid
      end    
    end
  end
end