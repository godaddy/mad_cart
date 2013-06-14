require "spec_helper"

describe MadCart::Store::Etsy do

  before(:each) { clear_config } 

  describe "retrieving products" do

    context "the store doesn't exist" do
      let(:invalid_store_name) { 'a_made_up_store' }
      let(:store) { MadCart::Store::Etsy.new(:store_name => invalid_store_name, :api_key => '4j3amz573gly866229iixzri') }

      it "raises an exception" do
        VCR.use_cassette('etsy_store_listings') do
          expect { store.products }.to raise_exception MadCart::Store::InvalidStore
        end
      end
    end

    context "the store does exist" do

      before(:each) do
        MadCart.configure do |config|
          config.add_store :etsy, {:api_key => 'a_made_up_key'}
        end
      end

      it "returns products" do
        VCR.use_cassette('etsy_store_listings') do
          api = MadCart::Store::Etsy.new(:store_name => 'a_made_up_store')
          api.products.size.should == 1

          first_product = api.products.first

          first_product.should be_a(MadCart::Model::Product)
          first_product.name.should_not be_nil
          first_product.description.should_not be_nil
          first_product.image_url.should_not be_nil
        end
      end

    end

  end

end

