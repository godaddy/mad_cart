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
      o.attributes.should == {"name" => 'whiskey', "description" => 'tasty', "external_id" => 2, "url" => 'path/to/whiskey'}
    end
    
    it "includes mapped attributes" do
      MadCart.configure do |config|
        config.attribute_map :my_models, :old_name => :new_name
      end
      
      o = MyModel.new(:name => 'whiskey', :description => 'tasty', :discarded => 'property', :old_name => 'is included')
      o.attributes.should == {"name" => 'whiskey', "description" => 'tasty', "new_name" => 'is included'}
    end
    
    it "allows two sources to map to the same model" do
      MadCart.configure do |config|
        config.include_attributes :my_models => [:new_name]
        config.attribute_map :my_models, :old_name => :new_name
      end
      
      source_a = {:name => 'whiskey', :description => 'tasty', :discarded => 'property', :old_name => 'has been renamed'}
      source_b = {:name => 'whiskey', :description => 'tasty', :discarded => 'property', :new_name => 'is included'}
      
      model_a = MyModel.new(source_a)
      model_a.attributes.should == {"name" => 'whiskey', "description" => 'tasty', "new_name" => 'has been renamed'}
      
      model_b = MyModel.new(source_b)
      model_b.attributes.should == {"name" => 'whiskey', "description" => 'tasty', "new_name" => 'is included'}
    end
  end

end
