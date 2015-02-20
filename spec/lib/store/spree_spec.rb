require "spec_helper"

describe MadCart::Store::Spree do

  let(:spree_cassette) { 'spree' }
  let(:spree_alternative_cassette) { 'spree_alternative' }
  let(:spree_no_records_cassette) { 'spree_no_records' }
  let(:spree_invalid_key_cassette) { 'spree_invalid_key' }

  let(:valid_credentials) {
    {
      :api_key => 'd1202dea0f624d1c2f0c8544f5dffe4b24bbcaf3a9601cc5',
      :store_url => 'localhost:3001'
    }
  }

  let(:valid_alternative_credentials) {
    {
      :api_key => '3d5216bcb9253377d7d354222a55bd32751f7fccc963b4ea',
      :store_url => 'localhost:3002'
    }
  }

  describe "store" do

    it "expects to be instantiated with an api key and store url" do
      lambda { MadCart::Store::Spree.new(:store_url => 'test').connection }.should raise_error(ArgumentError)
      lambda { MadCart::Store::Spree.new(:api_key => 'test', :store_url => 'test').connection }.should_not raise_error
    end

  end

  describe "products" do

    context "retrieval" do

      context "basic spree installation" do
        it "returns all products" do
          VCR.use_cassette(spree_cassette, :record => :new_episodes) do
            api = MadCart::Store::Spree.new(valid_credentials)

            api.products.size.should == 58

            first_product = api.products.first

            first_product.should be_a(MadCart::Model::Product)
            first_product.name.should_not be_nil
            first_product.description.should_not be_nil
            first_product.image_url.should_not be_nil
            first_product.additional_attributes['price'].should_not be_nil
          end
        end
      end

      context "alternative spree installation" do
        it "returns all products" do
          VCR.use_cassette(spree_alternative_cassette, :record => :new_episodes) do
            api = MadCart::Store::Spree.new(valid_alternative_credentials)

            api.products.size.should == 148

            first_product = api.products.first

            first_product.should be_a(MadCart::Model::Product)
            first_product.name.should_not be_nil
            first_product.description.should_not be_nil
            first_product.image_url.should_not be_nil
            first_product.additional_attributes['price'].should_not be_nil
          end
        end
      end

      it "returns an empty array when there are no products" do
        VCR.use_cassette(spree_no_records_cassette) do
          api = MadCart::Store::Spree.new(valid_credentials)
          api.products.should == []
        end
      end

    end

    context "count" do

      it "returns how many products there are" do
        VCR.use_cassette(spree_cassette, :record => :new_episodes) do
          api = MadCart::Store::Spree.new(valid_credentials)
          api.products_count.should == 58
        end
      end

    end

  end

  describe "customers" do
    context "retrieval" do

      it "returns all customers" do
        VCR.use_cassette(spree_cassette, :record => :new_episodes) do
          api = MadCart::Store::Spree.new(valid_credentials)

          api.customers.size.should be > 0
          api.customers.first.should be_a(MadCart::Model::Customer)
        end
      end

      it "returns an empty array when there are no customers" do
        VCR.use_cassette(spree_no_records_cassette) do
          api = MadCart::Store::Spree.new(valid_credentials)

          api.customers.should eql([])
        end
      end

    end

    describe "validating credentials" do

      it "succeeds if it can get orders.json from Spree" do
        VCR.use_cassette(spree_cassette, :record => :new_episodes) do
          api = MadCart::Store::Spree.new(valid_credentials)

          api.should be_valid
        end
      end

      it "fails if it cannot get orders.json from Spree" do
        VCR.use_cassette(spree_invalid_key_cassette) do
          api = MadCart::Store::Spree.new(
            :api_key => 'an-invalid-key',
            :store_url => valid_credentials[:store_url]
          )

          api.should_not be_valid
        end
      end

    end
  end

end
