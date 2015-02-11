module MadCart
  module Store
    class Spree
      include MadCart::Store::Base

      PRODUCTS_PER_PAGE = 50
      ORDERS_PER_PAGE   = 50

      create_connection_with :create_connection, :requires => [:api_key, :store_url]
      fetch :customers, :with => :get_customer_hashes
      fetch :products, :with => :get_products

      def valid?
        check_for_errors do
          connection.get('orders.json')
        end
        return true
      rescue InvalidCredentials => e
        return false
      end

      def products_count
        (parse_response { connection.get('products.json') })["total_count"]
      end

      private

      def make_order_request(params={})
        params = params.reverse_merge({ :page => 1, :per_page => ORDERS_PER_PAGE })
        parse_response { connection.get('orders.json', params) }
      end

      def make_product_request(params={})
        params = params.reverse_merge({ :page => 1, :per_page => PRODUCTS_PER_PAGE })
        parse_response { connection.get('products.json', params) }
      end

      def get_products(options={})
        product_hashes = []

        loop(:make_product_request, :products) do |r|
          product_hashes << r
        end

        product_hashes.map do |product|
          if product["master"]["images"]
            image = product["master"]["images"].first
            product = product.merge({
              :url              => connection.build_url("/products/#{ product["slug"] }").to_s,
              :image_square_url => connection.build_url(image["product_url"]).to_s,
              :image_url        => connection.build_url(image["large_url"]).to_s
            })
          end

          product
        end
      end

      def get_customer_hashes
        orders = []

        loop(:make_order_request, :orders) do |r|
          orders << {
            order_number: r["number"],
            user_email:   r["email"]
          }
        end

        orders.reverse.select{ |r| r[:user_email].present? }.uniq{ |r| r[:user_email] }.map do |r|
          c = parse_response { connection.get("orders/#{ r[:order_number] }.json") }
          if c['email']
            {
              first_name: c['bill_address'].try(:[], 'firstname'),
              last_name:  c['bill_address'].try(:[], 'lastname'),
              email:      c['email'],
              id:         c['email']
            }
          end
        end.compact
      end

      def loop(source, items_key, &block)
        response    = send(source, { :page => 1 })
        items       = response[items_key.to_s]
        pages_count = response['pages']

        (2..pages_count).each do |page|
          items += send(source, { :page => page })[items_key.to_s]
        end

        items.each(&block)
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
       "http://#{store_domain}/api/"
      end

      def empty_body?(response)
        true if response.status == 204 || response.body.nil?
      end

      def create_connection(args={})
        Faraday.new(:url => api_url_for(args[:store_url])) do |connection|
          connection.response :json
          connection.adapter Faraday.default_adapter
          connection.headers['X-Spree-Token'] = args[:api_key]
        end
      end
    end
  end
end
