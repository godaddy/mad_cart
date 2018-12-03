module MadCart
  module Store
    class BigCommerce
      include MadCart::Store::Base

      create_connection_with :create_connection, :requires => [:api_key, :store_url, :username]
      fetch :customers, :with => :get_customer_hashes
      fetch :products, :with => :get_products
      fetch :store, :with => :get_store

      def valid?
        valid_by_path?('time.json')
      end

      def products_count
        (parse_response { connection.get('products/count.json') })["count"]
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
            if product["images"]
              url = "#{product["images"]["resource"][1..-1]}.json"
              images << parse_response { connection.get(url) }
            end
          end
        end
        threads.each { |t| t.join }

        product_hashes.map do |p|
          product_images = images.find { |i| i.first.try(:[], 'product_id') == p['id'] } || []
          image          = product_images.sort_by{|i| i["sort_order"] }.find { |i| i["is_thumbnail"] }
          next if image.nil?

          p.merge({
            :url              => connection.build_url("#{p['custom_url']}").to_s,
            :image_square_url => image.try(:[], "thumbnail_url"),
            :image_url        => image.try(:[], "standard_url")
          })
        end.compact
      end

      def get_customer_hashes
        result = []
        for_each(:make_customer_request) {|c| result << c }
        result
      end

      def for_each(source, &block)
        items = send(source, :min_id => 1)

        loop do
          items.each(&block)
          break if items.count < 50
          items = send(source, :min_id => items.last['id'] + 1 )
        end

      end

      def get_store
        parse_response { connection.get('store.json') }
      end

      def api_url_for(store_domain)
       "https://#{store_domain}/api/v2/"
      end

      def create_connection(args={})
        Faraday.new(DEFAULT_CONNECTION_OPTIONS.merge(:url => api_url_for(args[:store_url]))) do |connection|
          connection.basic_auth(args[:username], args[:api_key])
          connection.response :json
          connection.adapter Faraday.default_adapter
        end
      end
    end
  end
end
