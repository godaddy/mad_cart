require "spec_helper"

describe "configuration" do

  # use a clean instance for each test
  before(:each) do
    clear_config
  end

  describe "stores" do

    it "does not require store to be added if credentials are passed to constructor" do
      lambda{ MadCart::Store::BigCommerce.new({:api_key => 'a_fake_key', :store_url => '/path/to/store', :username => 'bob'}) }.should_not raise_error
    end

    it "allows config values to be set for a store" do
      config_data = {:arbitrary => 'data'}
      MadCart.configure do |config|
        config.add_store :big_commerce, config_data
      end

      MadCart.config.big_commerce.should == config_data
    end

    it "gives returns nil if there's no config" do
      MadCart.config.missing_store.should be_nil
    end

  end

  describe "models" do
    it "allows custom attribute names to be set" do
      lambda {
        MadCart.configure do |config|
          config.attribute_map :products, {"name" => "title"}
        end
      }.should_not raise_error

      MadCart.config.attribute_maps["products"].should == {"name" => "title"}
    end

    it "allows additional attributes to be included in models" do
      MadCart.configure do |config|
        config.include_attributes :products => [:external_id, :url]
      end

      MadCart.config.included_attributes[:products].should == [:external_id, :url]
    end

  end

end
