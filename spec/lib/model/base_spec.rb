require "spec_helper"

describe MadCart::Store::Base do
  before(:each) do
    clear_config
    Object.send(:remove_const, :MyModel) if Object.const_defined?(:MyModel)
    class MyModel
      include MadCart::Model::Base
      required_attributes :name, :description
    end

    MadCart.configure do |config|
      config.include_attributes :my_models => [:external_id, :url]
    end
  end

  describe "attributes" do
    it "can be configured to include additional attributes" do
      MyModel.exposed_attributes
      o = MyModel.new(:name => 'whiskey', :description => 'tasty', :external_id => 2, :url => 'path/to/whiskey', :discarded => 'property')
      o.attributes.should == {"name" => 'whiskey', "description" => 'tasty', "external_id" => 2, "url" => 'path/to/whiskey'}
    end
  end

end
