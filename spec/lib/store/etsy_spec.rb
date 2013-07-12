require "spec_helper"

describe MadCart::Store::Etsy do

  before(:each) { clear_config } 

  describe "retrieving products" do

    context "the store doesn't exist" do
      let(:invalid_store_name) { 'MadeUpStore' }
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
          config.add_store :etsy, {:api_key => '4j3amz573gly866229iixzri'}
        end
      end

      it "returns products" do
        VCR.use_cassette('etsy_store_listings') do
          api = MadCart::Store::Etsy.new(:store_name => 'FabBeads')
          products = api.products(:includes => "MainImage")
          products.size.should == 25 # the etsy product limit

          first_product = products.first

          first_product.should be_a(MadCart::Model::Product)
          first_product.name.should_not be_nil
          first_product.description.should_not be_nil
          first_product.image_url.should_not be_nil
        end
      end
      
      context "pagination" do
        
        it "defaults to page one" do
          VCR.use_cassette('etsy_store_listings') do
            api = MadCart::Store::Etsy.new(:store_name => 'FabBeads')
          
            api.connection.should_receive(:listings).with(:active, {:page => 1}).and_return([])
            api.products
          end
        end
        
        it "returns the page requested" do
          VCR.use_cassette('etsy_store_listings') do
            api = MadCart::Store::Etsy.new(:store_name => 'FabBeads')
            
            api.connection.should_receive(:listings).with(:active, {:page => 2}).and_return([]) # Trusting the Etsy gem, not testing that it works
            api.products(:page => 2)
          end
        end
              
      end

      context "validating credentials" do

        it "succeeds if it can get a connection object" do
          VCR.use_cassette('etsy_store_listings', :record => :new_episodes) do
            api = MadCart::Store::Etsy.new(:store_name => 'FabBeads')

            api.should be_valid
          end
        end

        it "fails if it cannot get a connection object" do
          VCR.use_cassette('etsy_store_listings', :record => :new_episodes) do
            api = MadCart::Store::Etsy.new(:store_name => 'FabBeads')
            api.stub!(:create_connection).and_return(nil)

            api.should_not be_valid
          end
        end

      end

    end

  end

end

