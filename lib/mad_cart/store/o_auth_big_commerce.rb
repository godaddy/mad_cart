module MadCart
  module Store
    class OAuthBigCommerce < BigCommerce
      create_connection_with :create_connection, :requires => [:store_hash, :access_token, :client_id]

      def api_url_for(store_hash)
        "https://api.bigcommerce.com/#{store_hash}/v2/"
      end

      def create_connection(args={})
        options = DEFAULT_CONNECTION_OPTIONS.merge(
          :url => api_url_for(args[:store_hash])
        )
        Faraday.new(options) do |connection|
          connection.headers["X-Auth-Client"] = args[:client_id]
          connection.headers["X-Auth-Token"]  = args[:access_token]
          connection.response :json
          connection.adapter Faraday.default_adapter
        end
      end
    end
  end
end
