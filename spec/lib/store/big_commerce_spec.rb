require "spec_helper"

describe MadCart::Store::BigCommerce do

  subject { MadCart::Store::BigCommerce.new(valid_credentials) }

  let(:valid_credentials) {
    { :api_key => '0ff0e3939f5f160f36047cf0caa6f699fe24bdeb',
      :store_url => 'store-cr4wsh4.mybigcommerce.com',
      :username => 'support@madmimi.com' }
  }

  describe "store" do

    it "expects to be instantiated with an api key, username and store url" do
      lambda { MadCart::Store::BigCommerce.new(:username => 'test', :store_url => 'test').connection }.should raise_error(ArgumentError)
      lambda { MadCart::Store::BigCommerce.new(:api_key => 'test', :username => 'test', :store_url => 'test').connection }.should_not raise_error
    end

    it "authenticates via basic auth" do
      connection = Faraday.new
      Faraday.stub(:new).and_return(connection)

      connection.should_receive(:basic_auth).with('username', 'api_key')

      MadCart::Store::BigCommerce.new(:api_key => 'api_key', :username => 'username', :store_url => 'url').connection
    end

  end

  describe "products" do

    context "retrieval" do

      it "returns products" do
        VCR.use_cassette('big_commerce_products') do
          products = subject.products(limit: 10)
          products.size.should == 10

          first_product = products.first
          first_product.should be_a(MadCart::Model::Product)
          first_product.name.should_not be_nil
          first_product.description.should_not be_nil
          first_product.image_url.should_not be_nil
        end
      end

      it "returns an empty array when there are no products" do
        VCR.use_cassette('big_commerce_no_records') do
          subject.products.should == []
        end
      end

    end

    context "count" do

      it "returns how many products there are" do
        VCR.use_cassette('big_commerce_products_count') do
          subject.products_count.should == 45
        end
      end

    end

  end

  describe "customers" do
    context "retrieval" do

      it "returns all customers" do
        VCR.use_cassette('big_commerce_customers') do
          customers = subject.customers

          customers.size.should be > 0
          customers.first.should be_a(MadCart::Model::Customer)
        end
      end

      it "returns an empty array whern there are no customers" do
        VCR.use_cassette('big_commerce_no_records') do
          subject.customers.should eql([])
        end
      end

    end
  end

  describe "store" do
    context "retrieval" do
      it "returns the store" do
        VCR.use_cassette('big_commerce_store') do
          subject.store.should_not be_nil
        end
      end
    end
  end

  describe "validating credentials" do

    it "succeeds if it can get time.json from big commerce" do
      VCR.use_cassette('big_commerce_time') do
        subject.should be_valid
      end
    end

    it "fails if it cannot get time.json from big commerce" do
      VCR.use_cassette('big_commerce_invalid_key') do
        api = MadCart::Store::BigCommerce.new(
          :api_key => 'an-invalid-key',
          :store_url => 'store-cr4wsh4.mybigcommerce.com',
          :username => 'support@madmimi.com'
        )

        api.should_not be_valid
      end
    end

  end

end
