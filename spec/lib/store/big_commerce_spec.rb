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
      expect {
        MadCart::Store::BigCommerce.new(:username => 'test', :store_url => 'test').connection
      }.to raise_error(ArgumentError)
      expect {
        MadCart::Store::BigCommerce.new(:api_key => 'test', :username => 'test', :store_url => 'test').connection
      }.not_to raise_error
    end

    it "authenticates via basic auth" do
      connection = MadCart::Store::BigCommerce.new(:api_key => 'api_key', :username => 'username', :store_url => 'url').connection
      expect(connection.headers['Authorization']).not_to be_nil
    end
  end

  describe "products" do
    context "retrieval" do
      it "returns products" do
        VCR.use_cassette('big_commerce_products') do
          products = subject.products(limit: 10)
          expect(products.size).to eql(10)

          first_product = products.first
          expect(first_product).to be_a(MadCart::Model::Product)
          expect(first_product.name).not_to be_nil
          expect(first_product.description).not_to be_nil
          expect(first_product.image_url).not_to be_nil
        end
      end

      it "returns an empty array when there are no products" do
        VCR.use_cassette('big_commerce_no_records') do
          expect(subject.products).to eql([])
        end
      end

      it "returns an empty array when there are no images for any products" do
        VCR.use_cassette('big_commerce_products_no_images') do
          expect(subject.products).to eql([])
        end
      end
    end

    context "count" do
      it "returns how many products there are" do
        VCR.use_cassette('big_commerce_products_count') do
          expect(subject.products_count).to eql(45)
        end
      end
    end
  end

  describe "customers" do
    context "retrieval" do
      it "returns all customers" do
        VCR.use_cassette('big_commerce_customers') do
          customers = subject.customers

          expect(customers.size).to be > 0
          expect(customers.first).to be_a(MadCart::Model::Customer)
        end
      end

      it "returns an empty array whern there are no customers" do
        VCR.use_cassette('big_commerce_no_records') do
          expect(subject.customers).to eql([])
        end
      end
    end
  end

  describe "store" do
    context "retrieval" do
      it "returns the store" do
        VCR.use_cassette('big_commerce_store') do
          expect(subject.store).not_to be_nil
        end
      end
    end
  end

  describe "validating credentials" do
    it "succeeds if it can get time.json from big commerce" do
      VCR.use_cassette('big_commerce_time') do
        expect(subject).to be_valid
      end
    end

    it "fails if it cannot get time.json from big commerce" do
      VCR.use_cassette('big_commerce_invalid_key') do
        api = MadCart::Store::BigCommerce.new(
          :api_key => 'an-invalid-key',
          :store_url => 'store-cr4wsh4.mybigcommerce.com',
          :username => 'support@madmimi.com'
        )

        expect(api).not_to be_valid
      end
    end

    it "fails if it cannot connect to the big commerce server" do
      VCR.use_cassette('big_commerce_server_error') do
        api = MadCart::Store::BigCommerce.new(
          :api_key => 'an-invalid-key',
          :store_url => 'store-cr4wsh4.mybigcommerce.com',
          :username => 'support@madmimi.com'
        )

        expect(api).not_to be_valid
      end
    end

    it "fails if it cannot parse the response from the big commerce server" do
      VCR.use_cassette('big_commerce_time') do
        allow(subject.connection).to receive(:get).and_raise(Faraday::ParsingError.new(""))
        expect(subject).not_to be_valid
      end
    end
  end
end
