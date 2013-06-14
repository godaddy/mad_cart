require "spec_helper"

describe MadCart::Model::Customer do

  before(:each) do
    clear_config
  end

  it "returns the default attributes" do
    attrs = {"first_name" => 'Bob', "last_name" => 'Sagat', "email" => 'bob@sagat.com'}
    c = MadCart::Model::Customer.new(attrs)

    c.attributes.should eql(attrs)
  end

  it "allows attributes to be overwritten" do
    MadCart.configure do |config|
      config.attribute_map :customers, {:first_name => :name}
    end

    c = MadCart::Model::Customer.new(:first_name => 'Bob', :last_name => 'Sagat', :email => 'bob@sagat.com')

    c.attributes.should eql({"name" => 'Bob', "last_name" => 'Sagat', "email" => 'bob@sagat.com'})
  end

  it "exposes all additional attributes provided by the api" do
    c = MadCart::Model::Customer.new("first_name" => 'Bob', "last_name" => 'Sagat', "email" => 'bob@sagat.com', "with" => 'some', "additional" => 'fields' )

    c.additional_attributes.should eql({"with" => 'some', "additional" => 'fields'})
  end

  describe "validation" do

    before(:each) do
      @args = {:first_name => 'first_name',
               :last_name => 'last_name',
               :email => 'email'
      }
    end

    it "requires first_name" do
      @args.delete(:first_name)
      lambda{ MadCart::Model::Customer.new(@args)  }.should raise_error(ArgumentError)
    end

    it "requires last_name" do
      @args.delete(:last_name)
      lambda{ MadCart::Model::Customer.new(@args)  }.should raise_error(ArgumentError)
    end

    it "requires email" do
      @args.delete(:email)
      lambda{ MadCart::Model::Customer.new(@args)  }.should raise_error(ArgumentError)
    end

  end

end
