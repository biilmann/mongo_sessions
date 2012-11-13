#require 'action_dispatch/middleware/session/abstract_store'
require 'rack/session/abstract/id'

module MongoSessions
  module MongoStore
    def collection
      @collection
    end

    def initialize(app, options = {})
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
        if collection.respond_to?(:remove)
          collection.remove({'_id' => sid})
        else
          # moped
          collection.where('_id' => sid).remove
        end
      end
    end

    def destroy_session(env, sid, options)
      if collection.respond_to?(:remove)
        collection.remove({'_id' => sid})
      else
        # moped
        collection.where('_id' => sid).remove
      end
    end

    private
    def get_session(env, sid)
      sid ||= generate_sid
      data = collection.where('_id' => sid).first
      [sid, data ? unpack(data['s']) : {}]
    end

    def set_session(env, sid, session_data, options = {})
      sid ||= generate_sid

      new_data = {'_id' => sid, 't' => Time.now, 's' => pack(session_data), 'user_id' => session_data['user_id']}

      if collection.respond_to?(:update)
        collection.update({'_id' => sid}, new_data, {:upsert => true})
      else
        # moped
        collection.where('_id' => sid).update(new_data, [:upsert])
      end

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
