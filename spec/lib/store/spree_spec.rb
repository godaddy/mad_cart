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
      expect { MadCart::Store::Spree.new(:store_url => 'test').connection }.to raise_error(ArgumentError)
      expect { MadCart::Store::Spree.new(:api_key => 'test', :store_url => 'test').connection }.not_to raise_error
    end
  end

  describe "products" do
    context "retrieval" do
      context "basic spree installation" do
        it "returns all products" do
          VCR.use_cassette(spree_cassette) do
            api = MadCart::Store::Spree.new(valid_credentials)

            expect(api.products.size).to eql(58)

            first_product = api.products.first

            expect(first_product).to be_a(MadCart::Model::Product)
            expect(first_product.name).not_to be_nil
            expect(first_product.description).not_to be_nil
            expect(first_product.image_url).not_to be_nil
            expect(first_product.additional_attributes['price']).not_to be_nil
          end
        end
      end

      context "alternative spree installation" do
        it "returns all products" do
          VCR.use_cassette(spree_alternative_cassette) do
            api = MadCart::Store::Spree.new(valid_alternative_credentials)

            expect(api.products.size).to eql(148)

            first_product = api.products.first

            expect(first_product).to be_a(MadCart::Model::Product)
            expect(first_product.name).not_to be_nil
            expect(first_product.description).not_to be_nil
            expect(first_product.image_url).not_to be_nil
            expect(first_product.additional_attributes['price']).not_to be_nil
          end
        end
      end

      it "returns an empty array when there are no products" do
        VCR.use_cassette(spree_no_records_cassette) do
          api = MadCart::Store::Spree.new(valid_credentials)
          expect(api.products).to eql([])
        end
      end

    end

    context "count" do

      it "returns how many products there are" do
        VCR.use_cassette(spree_cassette) do
          api = MadCart::Store::Spree.new(valid_credentials)
          expect(api.products_count).to eql(58)
        end
      end

    end

  end

  describe "customers" do
    context "retrieval" do

      it "returns all customers" do
        VCR.use_cassette(spree_cassette) do
          api = MadCart::Store::Spree.new(valid_credentials)

          expect(api.customers.size).to be > 0
          expect(api.customers.first).to be_a(MadCart::Model::Customer)
        end
      end

      it "returns an empty array when there are no customers" do
        VCR.use_cassette(spree_no_records_cassette) do
          api = MadCart::Store::Spree.new(valid_credentials)

          expect(api.customers).to eql([])
        end
      end

    end

    describe "validating credentials" do
      it "succeeds if it can get orders.json from Spree" do
        VCR.use_cassette(spree_cassette) do
          api = MadCart::Store::Spree.new(valid_credentials)

          expect(api).to be_valid
        end
      end

      it "fails if it cannot get orders.json from Spree" do
        VCR.use_cassette(spree_invalid_key_cassette) do
          api = MadCart::Store::Spree.new(
            :api_key => 'an-invalid-key',
            :store_url => valid_credentials[:store_url]
          )

          expect(api).not_to be_valid
        end
      end
    end
  end
end
