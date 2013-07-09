module MadCart
  module Store
    class BigCommerce
      class InvalidStore < StandardError; end;
      class ServerError < StandardError; end;
      class InvalidCredentials < StandardError; end;
      
      include MadCart::Store::Base

      create_connection_with :create_connection, :requires => [:api_key, :store_url, :username]
      fetch :customers, :with => :get_customer_hashes
      fetch :products, :with => :get_products
      
      def valid?
        check_for_errors do
          connection.get('time.json')
        end
        return true
        
      rescue InvalidCredentials => e
        return false
      end

      private

      def make_customer_request(params={:min_id => 1})
        parse_response { connection.get('customers.json', params) }
      end
      
      def get_products(options={})
        product_hashes = connection.get('products.json', options).try(:body)
        return [] unless product_hashes
        
        threads, images = [], []
        product_hashes.each do |product|
          threads << Thread.new do
            url = "#{product["images"]["resource"][1..-1]}.json"
            images << parse_response { connection.get(url) }
          end
        end
        threads.each { |t| t.join }                

        product_hashes.map do |p|

          product_images = images.find { |i| i.first['product_id'] == p['id'] }
          thumbnail = product_images.find { |i| i["is_thumbnail"] }
          image     = product_images.sort_by{|i| i["sort_order"] }.find { |i| i["is_thumbnail"] }

          p.merge({ 
            :image_square_url => thumbnail['image_file'],
            :image_url => image['image_file'],
          })
        end
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
        return response.body
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
        @connection.response :json
        @connection.adapter Faraday.default_adapter
        @connection
      end
    end
  end
end
