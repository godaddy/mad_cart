require "spec_helper"

describe MadCart::Store::Base do

  before(:each) do
    clear_config
    Object.send(:remove_const, :MyModel) if Object.const_defined?(:MyModel)
    class MyModel
      include MadCart::Model::Base
      required_attributes :name, :description
    end
  end

  describe "attributes" do
    it "can be configured to include additional attributes" do
      MadCart.configure do |config|
        config.include_attributes :my_models => [:external_id, :url]
      end

      o = MyModel.new(:name => 'whiskey', :description => 'tasty', :external_id => 2, :url => 'path/to/whiskey', :discarded => 'property')
      expect(o.attributes).to eql({"name" => 'whiskey', "description" => 'tasty', "external_id" => 2, "url" => 'path/to/whiskey'})
    end

    it "includes mapped attributes" do
      MadCart.configure do |config|
        config.attribute_map :my_models, :old_name => :new_name
      end

      o = MyModel.new(:name => 'whiskey', :description => 'tasty', :discarded => 'property', :old_name => 'is included')
      expect(o.attributes).to eql({"name" => 'whiskey', "description" => 'tasty', "new_name" => 'is included'})
    end

    it "allows two sources to map to the same model" do
      MadCart.configure do |config|
        config.include_attributes :my_models => [:external_id]
        config.attribute_map :my_models, :id => :external_id
      end

      source_a = {:name => 'whiskey', :description => 'tasty', :discarded => 'property', :id => 'has been renamed'}
      source_b = {:name => 'whiskey', :description => 'tasty', :discarded => 'property', :external_id => 'is included'}

      model_a = MyModel.new(source_a)
      expect(model_a.attributes).to eql({"name" => 'whiskey', "description" => 'tasty', "external_id" => 'has been renamed'})

      model_b = MyModel.new(source_b)
      expect(model_b.attributes).to eql({"name" => 'whiskey', "description" => 'tasty', "external_id" => 'is included'})
    end
  end
end
