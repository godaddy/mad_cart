require 'spec_helper'

describe 'configuration' do # rubocop:disable Metrics/BlockLength
  # use a clean instance for each test
  before(:each) do
    clear_config
  end

  describe 'stores' do
    it 'does not require store be added if creds are passed to constructor' do
      expect(lambda {
        MadCart::Store::BigCommerce.new(
          api_key: 'a_fake_key',
          store_url: '/path/to/store',
          username: 'bob'
        )
      }).not_to raise_error
    end

    it 'allows config values to be set for a store' do
      config_data = { arbitrary: 'data' }
      MadCart.configure do |config|
        config.add_store :big_commerce, config_data
      end

      expect(MadCart.config.big_commerce).to eq(config_data)
    end

    it "gives returns nil if there's no config" do
      expect(MadCart.config.missing_store).to be_nil
    end
  end

  describe 'models' do
    it 'allows custom attribute names to be set' do
      expect(lambda {
        MadCart.configure do |config|
          config.attribute_map :products, 'name' => 'title'
        end
      }).not_to raise_error

      expect(MadCart.config.attribute_maps['products']).to eq('name' => 'title')
    end

    it 'allows additional attributes to be included in models' do
      MadCart.configure do |config|
        config.include_attributes products: %i[external_id url]
      end

      expect(MadCart.config.included_attributes[:products])
        .to eq(%i[external_id url])
    end
  end
end
