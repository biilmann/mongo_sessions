#require 'action_dispatch/middleware/session/abstract_store'
require 'rack/session/abstract/id'

module MongoSessions
  module MongoStore
    def collection
      @collection
    end

    def initialize(app, options = {})
      require 'mongo'

      unless options[:collection]
        raise "To avoid creating multiple connections to MongoDB, " +
              "the Mongo Session Store will not create it's own connection " +
              "to MongoDB - you must pass in a collection with the :collection option"
      end

      @collection = options[:collection].respond_to?(:call) ? options[:collection].call : options[:collection]

      super
    end

    def destroy(env)
      if sid = current_session_id(env)
        collection.remove({'_id' => sid})
      end
    end

    def destroy_session(env, sid, options)
      collection.remove({'_id' => sid})
    end

    private
    def get_session(env, sid)
      sid ||= generate_sid
      data = collection.find_one('_id' => sid)
      [sid, data ? unpack(data['s']) : {}]
    end

    def set_session(env, sid, session_data, options = {})
      sid ||= generate_sid
      collection.update({'_id' => sid}, {'_id' => sid, 't' => Time.now, 's' => pack(session_data), 'user_id' => session_data['user_id']}, {:upsert => true})
      sid
    end

    def pack(data)
      [Marshal.dump(data)].pack("m*")
    end

    def unpack(packed)
      return nil unless packed
      Marshal.load(packed.unpack("m*").first)
    end
  end
end
