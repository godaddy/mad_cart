require 'spec_helper'

describe MadCart::Store::BigCommerce do # rubocop:disable Metrics/BlockLength
  BigCommerce = MadCart::Store::BigCommerce

  subject { BigCommerce.new(valid_credentials) }

  let(:valid_credentials) do
    {
      api_key: '0ff0e3939f5f160f36047cf0caa6f699fe24bdeb',
      store_url: 'store-cr4wsh4.mybigcommerce.com',
      username: 'support@madmimi.com'
    }
  end

  describe 'store' do
    it 'expects to be instantiated with an api key, username and store url' do
      expect(
        -> { BigCommerce.new(username: 'test', store_url: 'test').connection }
      ).to raise_error(ArgumentError)
      expect(
        lambda {
          BigCommerce
            .new(api_key: 'test', username: 'test', store_url: 'test')
            .connection
        }
      ).not_to raise_error
    end

    it 'authenticates via basic auth' do
      expect_any_instance_of(Faraday::Connection).to receive(:basic_auth).with('username', 'api_key')

      BigCommerce
        .new(api_key: 'api_key', username: 'username', store_url: 'url')
        .connection
    end
  end

  describe 'products' do # rubocop:disable Metrics/BlockLength
    context 'retrieval' do
      it 'returns products' do
        VCR.use_cassette('big_commerce_products') do
          products = subject.products(limit: 10)
          expect(products.size).to eq(10)

          first_product = products.first
          expect(first_product).to be_a(MadCart::Model::Product)
          expect(first_product.name).not_to be_nil
          expect(first_product.description).not_to be_nil
          expect(first_product.image_url).not_to be_nil
        end
      end

      it 'returns an empty array when there are no products' do
        VCR.use_cassette('big_commerce_no_records') do
          expect(subject.products).to eq([])
        end
      end

      it 'returns an empty array when there are no images for any products' do
        VCR.use_cassette('big_commerce_products_no_images') do
          expect(subject.products).to eq([])
        end
      end
    end

    context 'count' do
      it 'returns how many products there are' do
        VCR.use_cassette('big_commerce_products_count') do
          expect(subject.products_count).to eq(45)
        end
      end
    end
  end

  describe 'customers' do
    context 'retrieval' do
      it 'returns all customers' do
        VCR.use_cassette('big_commerce_customers') do
          customers = subject.customers

          expect(customers.size).to be > 0
          expect(customers.first).to be_a(MadCart::Model::Customer)
        end
      end

      it 'returns an empty array whern there are no customers' do
        VCR.use_cassette('big_commerce_no_records') do
          expect(subject.customers).to eql([])
        end
      end
    end
  end

  describe 'store' do
    context 'retrieval' do
      it 'returns the store' do
        VCR.use_cassette('big_commerce_store') do
          expect(subject.store).not_to be_nil
        end
      end
    end
  end

  describe 'validating credentials' do # rubocop:disable Metrics/BlockLength
    it 'succeeds if it can get time.json from big commerce' do
      VCR.use_cassette('big_commerce_time') do
        expect(subject).to be_valid
      end
    end

    it 'fails if it cannot get time.json from big commerce' do
      VCR.use_cassette('big_commerce_invalid_key') do
        api = BigCommerce.new(
          api_key: 'an-invalid-key',
          store_url: 'store-cr4wsh4.mybigcommerce.com',
          username: 'support@madmimi.com'
        )

        expect(api).not_to be_valid
      end
    end

    it 'fails if it cannot connect to the big commerce server' do
      VCR.use_cassette('big_commerce_server_error') do
        api = BigCommerce.new(
          api_key: 'an-invalid-key',
          store_url: 'store-cr4wsh4.mybigcommerce.com',
          username: 'support@madmimi.com'
        )

        expect(api).not_to be_valid
      end
    end

    it 'fails if it cannot parse the response from the big commerce server' do
      VCR.use_cassette('big_commerce_time') do
        allow(subject.connection)
          .to(receive(:get) { raise Faraday::ParsingError, '' })
        expect(subject).not_to be_valid
      end
    end
  end
end
