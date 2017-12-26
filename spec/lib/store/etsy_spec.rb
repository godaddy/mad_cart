require "spec_helper"

describe MadCart::Store::Etsy do

  before(:each) { clear_config }

  describe "retrieving products" do
    context "the store doesn't exist" do
      let(:invalid_store_name) { 'MadeUpStore' }
      let(:store) { MadCart::Store::Etsy.new(:store_name => invalid_store_name, :api_key => '4j3amz573gly866229iixzri') }

      it "raises an exception" do
        VCR.use_cassette('etsy_store_does_not_exist') do
          expect { store.products }.to raise_exception MadCart::Store::InvalidStore
        end
      end
    end

    context "the store does exist" do
      before(:each) do
        MadCart.configure do |config|
          config.add_store :etsy, {:api_key => '4j3amz573gly866229iixzri'}
        end
      end

      it "returns products" do
        VCR.use_cassette('etsy_store_listings') do
          api = MadCart::Store::Etsy.new(:store_name => 'FabBeads')
          products = api.products(:includes => "MainImage")
          expect(products.size).to eql(25) # the etsy product limit

          first_product = products.first

          expect(first_product).to be_a(MadCart::Model::Product)
          expect(first_product.name).not_to be_nil
          expect(first_product.description).not_to be_nil
          expect(first_product.image_url).not_to be_nil
          expect(first_product.additional_attributes['price']).to eql(BigDecimal.new('2.5'))
        end
      end

      context "new format image api" do
        it "returns products" do
          VCR.use_cassette('etsy_store_listings_new_format_image') do
            api = MadCart::Store::Etsy.new(:store_name => 'TheBeadsofDreams')
            products = api.products(:includes => "MainImage")
            expect(products.size).to eql(25) # the etsy product limit

            first_product = products.first

            expect(first_product).to be_a(MadCart::Model::Product)
            expect(first_product.name).not_to be_nil
            expect(first_product.description).not_to be_nil
            expect(first_product.image_url).not_to be_nil
            expect(first_product.additional_attributes['price']).to eql(BigDecimal.new('2.2'))
          end
        end
      end

      context "pagination" do
        it "defaults to page one" do
          VCR.use_cassette('etsy_store_listings') do
            api = MadCart::Store::Etsy.new(:store_name => 'FabBeads')

            expect(api.connection).to receive(:listings).with(:active, {:page => 1}).and_return([])
            api.products
          end
        end

        it "returns the page requested" do
          VCR.use_cassette('etsy_store_listings') do
            api = MadCart::Store::Etsy.new(:store_name => 'FabBeads')

            expect(api.connection).to receive(:listings).with(:active, {:page => 2}).and_return([]) # Trusting the Etsy gem, not testing that it works
            api.products(:page => 2)
          end
        end
      end

      context "validating credentials" do
        it "succeeds if it can get a connection object" do
          VCR.use_cassette('etsy_store_listings') do
            api = MadCart::Store::Etsy.new(:store_name => 'FabBeads')

            expect(api).to be_valid
          end
        end

        it "fails if it cannot get a connection object" do
          VCR.use_cassette('etsy_store_listings') do
            api = MadCart::Store::Etsy.new(:store_name => 'FabBeads')
            allow(api).to receive(:create_connection).and_return(nil)

            expect(api).not_to be_valid
          end
        end
      end
    end
  end
end

