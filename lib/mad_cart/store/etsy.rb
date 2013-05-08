require 'etsy'
require 'money'

module MadCart
  module Store
    class Etsy
      include MadCart::Store::Base
      
      create_connection_with :create_connection, :requires => [:store_name, :api_key]
      fetch :products, :with => :get_products
      format :products, :with => :format_products

      private
      def get_products
        connection.listings(:active, {:includes => 'Images'})
      end

      def format_products(listing)
        {
           :external_id => listing.id,
           :name => listing.title,
           :description => listing.description,
           :price => "#{listing.price} #{listing.currency}".to_money.format,
           :url => listing.url,
           :currency_code => listing.currency,
           :image_url => listing.image.full,
           :square_image_url => listing.image.square
        }
      end

      def create_connection(args)
        ::Etsy.api_key = args[:api_key] if !::Etsy.api_key || (::Etsy.api_key != args[:api_key])
        ::Etsy.environment = :production
        return ::Etsy::Shop.find(args[:store_name]).first
      end

    end
  end
end

