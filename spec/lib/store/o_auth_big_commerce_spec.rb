require "spec_helper"

describe MadCart::Store::OAuthBigCommerce do

  subject { MadCart::Store::OAuthBigCommerce.new(valid_credentials) }

  let(:valid_credentials) do
    {
      :client_id    => 'db7uvk7wc5vstd3f1pw5ma1af13p93n',
      :store_hash   => 'stores/cr4wsh4',
      :access_token => 'q3l1fqfz08jqlxtvmavzgr8cjhmqaww'
    }
  end

  describe "store" do
    it "expects to be instantiated with an client id, store hash and access token" do
      expect{
        MadCart::Store::OAuthBigCommerce.new(
          :client_id => 'test', :store_hash => 'test'
        ).connection
      }.to raise_error(ArgumentError)

      expect{
        MadCart::Store::OAuthBigCommerce.new(
          :client_id => 'test', :store_hash => 'test', :access_token => "madeYouLook"
        ).connection
      }.not_to raise_error
    end

    context "retrieval" do
      it "returns the store" do
        VCR.use_cassette('o_auth_big_commerce_store') do
          expect(subject.store).not_to be_nil
        end
      end
    end
  end
end
