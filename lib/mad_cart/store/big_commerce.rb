module MadCart
  module Store
    class BigCommerce
      include MadCart::Store::Base

      create_connection_with :create_connection, :requires => [:api_key, :store_url, :username]
      fetch :customers, :with => :get_customer_hashes

      private

      def make_customer_request(params={:min_id => 1})
        parse_response { connection.get('customers.json', params) }
      end

      def get_customer_hashes
        result = []
        loop(:make_customer_request) {|c| result << c }
        return result
      end

      def loop(source, &block)

        items = send(source, :min_id => 1)

        while true
          items.each &block
          break if items.count < 200
          items = send(source, :min_id => items.max_id + 1 )
        end

      end

      def parse_response(&block)
        response = check_for_errors &block
        return [] if empty_body?(response)
        return JSON.parse(response.body)
      end

      def check_for_errors(&block)
        response = yield

        case response.status
        when 401
          raise InvalidCredentials
        when 500
          raise ServerError
        end

        response
      rescue Faraday::Error::ConnectionFailed => e
        raise InvalidStore
      end

      def api_url_for(store_domain)
       "https://#{store_domain}/api/v2/"
      end

      def empty_body?(response)
        true if response.status == 204 || response.body.nil?
      end

      def create_connection(args={})
        @connection = Faraday.new(:url => api_url_for(args[:store_url]))
        @connection.basic_auth(args[:username], args[:api_key])
        @connection
      end
    end
  end
end
